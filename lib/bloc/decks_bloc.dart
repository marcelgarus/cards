import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaml/yaml.dart';
import 'model.dart';
import 'resource_manager.dart';

class DecksBloc {
  List<Deck> decks = <Deck>[];
  List<Deck> get unlockedDecks => decks.where((d) => d.isUnlocked).toList();
  List<Deck> get selectedDecks => decks.where((d) => d.isSelected).toList();

  final decksSubject = BehaviorSubject<List<Deck>>();
  final unlockedDecksSubject = BehaviorSubject<List<Deck>>();
  final selectedDecksSubject = BehaviorSubject<List<Deck>>();


  Future<void> initialize(Locale locale) async {
    final List<Deck> loadedDecks = await _loadDecks(locale);

    // Load unlocked decks.
    final Set<String> unlocked = await _loadUnlockedDecks();
    for (final deck in loadedDecks) {
      deck.isUnlocked = unlocked.contains(deck.id);
    }

    // Load selected decks.
    final Set<String> selected = await _loadSelectedDecks();
    for (final deck in loadedDecks) {
      deck.isSelected = selected.contains(deck.id);
    }

    decks = loadedDecks;
    decksSubject.add(decks);
    unlockedDecksSubject.add(unlockedDecks);
    selectedDecksSubject.add(selectedDecks);
  }

  void dispose() {
    decksSubject.close();
    unlockedDecksSubject.close();
    selectedDecksSubject.close();
  }


  void buy(Deck deck) {
    deck.isUnlocked = true;
    deck.isSelected = true;
    unlockedDecksSubject.add(unlockedDecks);
    selectedDecksSubject.add(selectedDecks);
    _saveUnlockedDecks(unlockedDecks);
    _saveSelectedDecks(selectedDecks);
  }

  void selectDeck(Deck deck) {
    deck.isSelected = true;
    selectedDecksSubject.add(selectedDecks);
    _saveSelectedDecks(selectedDecks);
  }

  void deselectDeck(Deck deck) {
    deck.isSelected = false;
    selectedDecksSubject.add(selectedDecks);
    _saveSelectedDecks(selectedDecks);
  }


  /// Returns a list of all decks of a given language.
  static Future<List<Deck>> _loadDecks(Locale locale) async {
    if (locale == null)
      return [];

    final decks = <Deck>[];

    final root = ResourceManager.getRootDirectory(locale);
    final filename = '$root/decks.yaml';
    final yaml = loadYaml(await rootBundle.loadString(filename));

    for (final deck in yaml['decks'] ?? []) {
      decks.add(Deck(
        id: deck['id'] ?? '<no id>',
        file: '$root/deck_${deck['id'] ?? 'id'}.txt',
        name: deck['name'] ?? '<no name>',
        coverImage: deck['image'] ?? '',
        color: deck['color'] ?? '<color>',
        description: deck['description'] ?? '<description>',
        price: deck['price'] ?? 0,
        probability: deck['probability'] ?? 1.0
      ));
    }

    return decks;
  }

  static void _saveUnlockedDecks(List<Deck> decks) {
    ResourceManager.saveStringList(
      'unlocked_decks',
      decks.map((d) => d.id).toList()
    ).catchError((e) {
      print('An error occurred while saving $decks as unlocked decks: $e');
    });
  }

  static Future<Set<String>> _loadUnlockedDecks() async {
    return (await ResourceManager.loadStringList('unlocked_decks'))?.toSet()
        ?? Set();
  }

  static void _saveSelectedDecks(List<Deck> decks) {
    ResourceManager.saveStringList(
      'selected_decks',
      decks.map((d) => d.id).toList()
    ).catchError((e) {
      print('An error occurred while saving $decks as selected decks: $e');
    });
  }

  static Future<Set<String>> _loadSelectedDecks() async {
    return (await ResourceManager.loadStringList('selected_decks'))?.toSet()
        ?? Set();
  }
}

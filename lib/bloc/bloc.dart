import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:rxdart/subjects.dart';
import 'model.dart';
import 'locale_bloc.dart';
import 'players_bloc.dart';
import 'decks_bloc.dart';
import 'my_cards_bloc.dart';
import 'game_bloc.dart';


/// The gateway between Flutter Widgets and actual business logic.
class Bloc {
  Bloc() {
    _initialize();
  }

  /// Using this method, any widget in the tree below a BlocProvider can get
  /// access to the bloc.
  static Bloc of(BuildContext context) {
    final BlocProvider inherited = context.ancestorWidgetOfExactType(BlocProvider);
    return inherited?.bloc;
  }

  static const version = '0.0.1';

  final localeBloc = LocaleBloc();
  final playersBloc = PlayersBloc();
  final decksBloc = DecksBloc();
  final myCardsBloc = MyCardsBloc();
  final gameBloc = GameBloc();

  Configuration _configuration;

  // Output stream subjects.
  final _configurationSubject = BehaviorSubject<Configuration>();
  final _canResumeSubject = BehaviorSubject<bool>(seedValue: false);

  // Actual output streams. Some have subjects above.
  Stream<Locale> get locale => localeBloc.localeSubject.stream;
  Stream<List<String>> get players => playersBloc.playersSubject.stream;
  Stream<List<Deck>> get decks => decksBloc.decksSubject.stream;
  Stream<List<Deck>> get unlockedDecks => decksBloc.unlockedDecksSubject.stream;
  Stream<List<Deck>> get selectedDecks => decksBloc.selectedDecksSubject.stream;
  Stream<List<GameCard>> get myCards => myCardsBloc.myCardsSubject.stream;
  Stream<Configuration> get configuration => _configurationSubject.stream;
  Stream<bool> get canResume => _canResumeSubject.stream;
  Stream<Card> get frontCard => gameBloc.frontCardSubject.stream;
  Stream<Card> get backCard => gameBloc.backCardSubject.stream;

  void updateLocale(Locale locale) => localeBloc.updateLocale(locale);
  void addPlayer(String player) => playersBloc.addPlayer(player);
  void removePlayer(String player) => playersBloc.removePlayer(player);
  void selectDeck(Deck deck) => decksBloc.selectDeck(deck);
  void deselectDeck(Deck deck) => decksBloc.deselectDeck(deck);
  GameCard createNewCard() => myCardsBloc.createNewCard();
  void updateCard(GameCard card) => myCardsBloc.updateCard(card);
  void deleteCard(GameCard card) => myCardsBloc.deleteCard(card);
  void nextCard() async => gameBloc.nextCard(_configuration);


  void _initialize() async {
    print('Initializing the BLoC.');

    // TODO: Add error handling
    localeBloc.initialize();
    playersBloc.initialize();
    decksBloc.initialize(localeBloc.locale);
    myCardsBloc.initialize();

    locale.listen((locale) {
      decksBloc.initialize(locale);
      gameBloc.stop();
    });
    players.listen((players) => _updateConfiguration());
    selectedDecks.listen((decks) => _updateConfiguration());
    myCards.listen((cards) => _updateConfiguration());
    configuration.listen((config) => _updateCanResume());
  }

  void dispose() {
    _configurationSubject.close();
    _canResumeSubject.close();
  }

  void _updateConfiguration() {
    _configuration = Configuration(
      players: playersBloc.players ?? [],
      decks: decksBloc.selectedDecks ?? [],
      myCards: myCardsBloc.myCards ?? []
    );
    _configurationSubject.add(_configuration);
  }

  void _updateCanResume() async {
    _canResumeSubject.add(_configuration.isValid && gameBloc.isActive);
  }

  void start() async {
    print('Starting the game.');

    if (_configuration.isValid) {
      print('Configuration is valid. Starting gameBloc.');
      gameBloc.start(_configuration);
      _updateCanResume();
    }
  }
}

class BlocProvider extends StatelessWidget {
  BlocProvider({ @required this.bloc, @required this.child }) :
      assert(bloc != null),
      assert(child != null);
  
  final Widget child;
  final Bloc bloc;

  @override
  Widget build(BuildContext context) => child;
}

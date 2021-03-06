import 'package:flutter/material.dart';

abstract class Utils {
  static ThemeData mainTheme = ThemeData(
    primaryColor: Colors.black,
    accentColor: Colors.amber,
    iconTheme: IconThemeData(color: Colors.pink),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    backgroundColor: Colors.black,
    cardColor: Colors.white,
    canvasColor: Colors.white,
  );

  static ThemeData myCardsTheme = mainTheme.copyWith(
    primaryColor: Colors.amber,
    primaryTextTheme: TextTheme(
      title: TextStyle(color: Colors.black),
      body1: TextStyle(color: Colors.black),
    ),
    primaryIconTheme: IconThemeData(
      color: Colors.black
    )
  );
  
  static ThemeData feedbackTheme = mainTheme.copyWith(
    primaryColor: Colors.amber,
    primaryTextTheme: TextTheme(
      title: TextStyle(color: Colors.black),
      body1: TextStyle(color: Colors.black),
    ),
    primaryIconTheme: IconThemeData(
      color: Colors.black
    )
  );

  static ThemeData cardTheme = ThemeData(
    hintColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber)
      ),
    ),
    textTheme: TextTheme(
      body1: TextStyle(color: Colors.white),
      body2: TextStyle(color: Colors.white)
    )
  );
}

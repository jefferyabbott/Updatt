import 'package:flutter/material.dart';
import 'package:upddat/themes/dark_mode.dart';
import 'package:upddat/themes/light_mode.dart';

// manages switching the app between light and dark modes

class ThemeProvider with ChangeNotifier {
  // initially set to light mode
  ThemeData _themeData = lightMode;

  // get the current theme
  ThemeData get themeData => _themeData;

  // is it dark mode?
  bool get isDarkMode => _themeData == darkMode;

  // set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // toggle
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}

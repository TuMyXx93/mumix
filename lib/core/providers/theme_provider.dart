/// App-wide theme provider that persists the current light/dark selection.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeDarkKey = 'app_theme_dark';

  final SharedPreferences _prefs;
  bool _isDarkMode = false;

  /// Creates the provider and restores the saved theme mode.
  ThemeProvider(this._prefs) {
    _loadFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;

  void _loadFromPrefs() {
    _isDarkMode = _prefs.getBool(_themeDarkKey) ?? false;
  }

  /// Toggles the current theme mode and persists the new value.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_themeDarkKey, _isDarkMode);
    notifyListeners();
  }
}

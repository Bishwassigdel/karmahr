import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The three choices the user can pick from Settings.
// "system" means "just follow the phone's own Light/Dark setting" —
// the behavior the app had before this feature existed.
enum AppThemeMode { system, light, dark }

const _prefsKey = 'themeMode';

class ThemeState extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.system;
  AppThemeMode get mode => _mode;

  ThemeState() {
    _loadSavedMode();
  }

  // Restores whatever the user picked last time the app was open —
  // without this, the choice would reset to System every launch.
  Future<void> _loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    final match = AppThemeMode.values.where((m) => m.name == saved);
    if (match.isNotEmpty) {
      _mode = match.first;
      notifyListeners();
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    _mode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}

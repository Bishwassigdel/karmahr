import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english(Locale('en'), 'English'),
  nepali(Locale('ne'), 'नेपाली');

  const AppLanguage(this.locale, this.nativeName);
  final Locale locale;

  /// Each language is always shown in its own script, whatever the app's
  /// current language, so someone who can't read the current one can
  /// still find theirs.
  final String nativeName;
}

const _prefsKey = 'appLanguage';

/// The app's display language, picked in Settings and kept across
/// launches. Deliberately not per-user: it survives logout, like Theme.
class LocaleState extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;
  AppLanguage get language => _language;

  LocaleState() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      final match = AppLanguage.values.where((l) => l.name == saved);
      if (match.isNotEmpty && match.first != _language) {
        _language = match.first;
        notifyListeners();
      }
    } catch (_) {
      // No saved choice readable: stay on English.
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.name);
  }
}

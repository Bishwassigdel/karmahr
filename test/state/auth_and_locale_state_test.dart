import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/state/auth_state.dart';
import 'package:my_first_flutter_app/state/locale_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AuthState', () {
    test('starts signed out', () {
      final auth = AuthState();
      expect(auth.isSignedIn, isFalse);
      expect(auth.role, isNull);
    });

    test('signIn sets the role, signOut clears it', () {
      final auth = AuthState()..signIn(UserRole.manager);
      expect(auth.role, UserRole.manager);
      auth.signOut();
      expect(auth.isSignedIn, isFalse);
    });

    test('signOut when already signed out does not notify', () {
      final auth = AuthState();
      var notified = 0;
      auth.addListener(() => notified++);
      auth.signOut();
      expect(notified, 0);
    });
  });

  group('LocaleState', () {
    test('defaults to English', () {
      expect(LocaleState().language, AppLanguage.english);
    });

    test('restores the saved language', () async {
      SharedPreferences.setMockInitialValues({'appLanguage': 'nepali'});
      final state = LocaleState();
      for (var i = 0; i < 20 && state.language != AppLanguage.nepali; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      expect(state.language.locale, const Locale('ne'));
    });

    test('setLanguage persists the choice', () async {
      await LocaleState().setLanguage(AppLanguage.nepali);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('appLanguage'), 'nepali');
    });
  });
}

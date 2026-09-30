import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/screens/app_lock_gate.dart';
import 'package:my_first_flutter_app/state/app_lock_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the wrapped child once loaded (lock disabled by default)', (
    tester,
  ) async {
    final state = AppLockState();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppLockState>.value(
        value: state,
        child: const CupertinoApp(
          home: AppLockGate(child: Text('REAL APP CONTENT')),
        ),
      ),
    );

    // AppLockState._init() resolves via real platform-channel Futures
    // (SharedPreferences + local_auth), which testWidgets' fake-clock
    // pump() loop doesn't reliably drive to completion — runAsync()
    // runs this wait in a real async zone instead, which is the
    // documented way to let genuine platform-channel work finish inside
    // a widget test.
    await tester.runAsync(() async {
      for (var i = 0; i < 50 && !state.isLoaded; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    });
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(state.isLoaded, isTrue);
    // App Lock defaults to off, and there's no local_auth plugin
    // registered in tests (so deviceSupportsAuth resolves false) —
    // either way, the real content must show, not the lock screen.
    expect(find.text('REAL APP CONTENT'), findsOneWidget);
    expect(find.text('KarmaHR is Locked'), findsNothing);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/state/app_lock_state.dart';

void main() {
  // Plain `test()` (unlike `testWidgets()`) doesn't auto-initialize the
  // platform-channel bindings that shared_preferences and local_auth
  // both need, even just to fail gracefully — without this every
  // `await SharedPreferences.getInstance()` throws "Binding has not yet
  // been initialized" before AppLockState even gets a chance to run.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // A clean, in-memory SharedPreferences per test — otherwise a
    // value one test persists (setEnabled) could leak into the next.
    SharedPreferences.setMockInitialValues({});
  });

  // These run against whatever local_auth's platform channel returns in
  // the test environment (no real device — there's no plugin registered
  // at all, so every call resolves via MissingPluginException), so they
  // intentionally only assert on the parts of AppLockState that don't
  // depend on actually passing a biometric check: the persisted-
  // preference / session-only split, and that failures degrade to
  // false instead of throwing or hanging.

  // Waits for AppLockState's constructor-fired _init() to finish, without
  // hardcoding how many microtask turns that takes — it awaits two real
  // async calls (SharedPreferences.getInstance(), then local_auth's
  // isDeviceSupported()), so a fixed number of Duration.zero delays is
  // fragile. Polling isLoaded is the stable way to wait for "done."
  Future<void> waitUntilLoaded(AppLockState state) async {
    for (var i = 0; i < 50 && !state.isLoaded; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  }

  test('starts unloaded, then reaches isLoaded after init completes', () async {
    final state = AppLockState();
    expect(state.isLoaded, isFalse);

    await waitUntilLoaded(state);

    expect(state.isLoaded, isTrue);
    // No real local_auth plugin is registered in this test environment
    // (MissingPluginException on every call) — _init() must treat that
    // as "unsupported," not crash or hang, which is exactly what the
    // try/catch around isDeviceSupported() in _init() is for.
    expect(state.deviceSupportsAuth, isFalse);
  });

  test('isUnlockedThisSession starts false and is never auto-true', () async {
    final state = AppLockState();
    await waitUntilLoaded(state);

    expect(state.isUnlockedThisSession, isFalse);
  });

  test('lock() resets isUnlockedThisSession without touching enabled', () async {
    final state = AppLockState();
    await waitUntilLoaded(state);

    final enabledBefore = state.enabled;
    state.lock();

    expect(state.isUnlockedThisSession, isFalse);
    expect(state.enabled, enabledBefore); // lock() must not change this
  });

  test(
    'authenticate() never throws even without real biometric hardware',
    () async {
      final state = AppLockState();
      await waitUntilLoaded(state);

      // No real authenticator is registered in this test environment, so
      // this is expected to resolve to false rather than hang or throw —
      // that's the behavior every call site (Settings, AppLockScreen)
      // depends on.
      final result = await state.authenticate();
      expect(result, isFalse);
      expect(state.isUnlockedThisSession, isFalse);
    },
  );
}

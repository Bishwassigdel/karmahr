// Gates the app behind Face ID / Touch ID / device passcode.
//
// Two pieces of state, deliberately NOT the same thing:
//  - `enabled`: the user's persisted preference (survives restarts,
//    same SharedPreferences pattern as ThemeState).
//  - `isUnlockedThisSession`: whether they've already passed a check
//    since this app process started. This is NEVER persisted — a
//    fresh launch always re-locks when `enabled` is true. Without this
//    split, there'd be no way to tell "the user unlocked five minutes
//    ago" from "the user unlocked once, a year ago" — the second one
//    is not what an app lock is for.

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'appLockEnabled';

class AppLockState extends ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _enabled = false;
  bool get enabled => _enabled;

  bool _isUnlockedThisSession = false;
  bool get isUnlockedThisSession => _isUnlockedThisSession;

  // Null while still checking on startup, then set once known. Settings
  // uses this to grey out the toggle on a device/simulator with no
  // biometric or passcode capability at all, instead of offering a
  // switch that would only ever fail.
  bool? _deviceSupportsAuth;
  bool? get deviceSupportsAuth => _deviceSupportsAuth;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  AppLockState() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    // isDeviceSupported() covers BOTH biometrics and a plain device
    // passcode/PIN fallback — canCheckBiometrics alone would wrongly
    // say "unsupported" on a device with no fingerprint/Face ID
    // hardware enrolled but a perfectly good passcode set.
    //
    // Wrapped in try/catch deliberately: this constructor is never
    // awaited (AppLockState() { _init(); }), so an unhandled exception
    // here — the plugin not yet registered, an unusual device/emulator
    // state — would leave `_isLoaded` false forever, and AppLockGate
    // would be stuck on its loading spinner permanently. "Couldn't
    // determine support" must degrade to "treat as unsupported," never
    // to "never finish loading."
    bool supported;
    try {
      supported = await _auth.isDeviceSupported();
    } on Exception {
      supported = false;
    }

    _deviceSupportsAuth = supported;
    // If the device lost auth capability since this was turned on
    // (e.g. testing on a simulator), don't leave the user locked out
    // with no way to ever pass the check.
    _enabled = (prefs.getBool(_prefsKey) ?? false) && supported;
    _isLoaded = true;
    notifyListeners();
  }

  /// Prompts Face ID/Touch ID/device passcode. Returns true only on a
  /// genuine success — every failure path (user cancelled, nothing
  /// enrolled, lockout, iOS simulator's lack of support) returns false
  /// rather than throwing, so callers never need their own try/catch.
  Future<bool> authenticate({String reason = 'Unlock KarmaHR'}) async {
    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow device PIN/passcode fallback too
          stickyAuth: true, // survives a brief app backgrounding mid-prompt
        ),
      );
      if (success) {
        _isUnlockedThisSession = true;
        notifyListeners();
      }
      return success;
    } on Exception {
      // PlatformException covers "no hardware," "nothing enrolled," the
      // iOS simulator's otherOperatingSystem code, and lockouts — all of
      // these just mean "couldn't verify," which returning false already
      // communicates to the UI without every call site needing to know
      // local_auth's specific exception types.
      return false;
    }
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  /// Re-locks the app immediately. Called on logout, so the next person
  /// to open the app on this device — even without it ever having been
  /// fully closed — has to authenticate again before reaching anything.
  void lock() {
    _isUnlockedThisSession = false;
    notifyListeners();
  }
}

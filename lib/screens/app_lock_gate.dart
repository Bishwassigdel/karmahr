// Sits above WelcomeScreen and decides, on every rebuild, whether the
// real app is allowed to show at all. Three states:
//  1. AppLockState hasn't finished loading yet (checking SharedPreferences
//     + device biometric support) — show a blank loading screen instead
//     of a frame of real content, or this wouldn't be a lock at all.
//  2. App Lock is on and this session hasn't been unlocked — show
//     AppLockScreen and nothing else.
//  3. Otherwise — show the real app.
//
// Public (not just main.dart's home:) because logout needs it too:
// Navigator.pushAndRemoveUntil replaces the ENTIRE navigation stack
// with a fresh route — a bare WelcomeScreen there would bypass this
// gate completely, silently undoing AppLockState.lock(). Both the
// cold-start entry point and the post-logout entry point must build
// through the same gate, or "re-lock on logout" doesn't actually do
// anything a user could see.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'app_lock_screen.dart';
import '../state/app_lock_state.dart';

class AppLockGate extends StatelessWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final lockState = context.watch<AppLockState>();

    if (!lockState.isLoaded) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (lockState.enabled && !lockState.isUnlockedThisSession) {
      return const AppLockScreen();
    }

    return child;
  }
}

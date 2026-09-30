// Full-screen gate shown INSTEAD of the app's real content whenever
// App Lock is on and this session hasn't been unlocked yet. Triggers
// authentication automatically on first appearance — the "Unlock"
// button below is the fallback for "dismissed the system prompt, want
// to try again," not the primary way in. A failure or cancel just
// leaves this screen up; it never lets anything through except a
// genuine success from AppLockState.authenticate().

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/app_lock_state.dart';
import '../theme/app_colors.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _isAuthenticating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Post-frame so this runs after the lock screen itself has actually
    // painted — prompting from inside initState/build can fire before
    // there's anything on screen behind the system dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
  }

  Future<void> _tryUnlock() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    final success = await context.read<AppLockState>().authenticate();

    if (!mounted) return;
    setState(() {
      _isAuthenticating = false;
      _error = success ? null : "Couldn't verify — tap to try again.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background.resolveFrom(context),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.lock_shield_fill,
                  size: 64,
                  color: AppColors.karmaRed,
                ),
                const SizedBox(height: 20),
                const Text(
                  'KarmaHR is Locked',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock with Face ID, Touch ID, or your device passcode '
                  'to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: subtleTextColor),
                ),
                const SizedBox(height: 28),
                if (_isAuthenticating)
                  const CupertinoActivityIndicator(radius: 14)
                else
                  CupertinoButton.filled(
                    onPressed: _tryUnlock,
                    child: const Text('Unlock'),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: CupertinoColors.systemRed.resolveFrom(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

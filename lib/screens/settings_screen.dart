import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/app_lock_state.dart';
import '../state/notification_state.dart';
import '../state/push_notification_state.dart';
import '../state/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Human-readable label + description for each mode, so the row-building
  // code below doesn't repeat itself three times.
  String _title(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System Default';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  String _subtitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return "Match this iPhone's Light/Dark setting";
      case AppThemeMode.light:
        return 'Always use Light appearance';
      case AppThemeMode.dark:
        return 'Always use Dark appearance';
    }
  }

  IconData _icon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return CupertinoIcons.device_phone_portrait;
      case AppThemeMode.light:
        return CupertinoIcons.sun_max_fill;
      case AppThemeMode.dark:
        return CupertinoIcons.moon_fill;
    }
  }

  // Turning App Lock ON requires a successful authentication FIRST —
  // otherwise a user could flip the switch on a device that can't
  // actually verify them (no biometrics enrolled, etc.) and lock
  // themselves out on the next launch with no way back in. Turning it
  // OFF never needs a check: you're already past the gate to be here.
  Future<void> _onAppLockToggled(
    BuildContext context,
    bool wantsEnabled,
  ) async {
    final lockState = context.read<AppLockState>();

    if (wantsEnabled) {
      final verified = await lockState.authenticate(
        reason: 'Verify to enable App Lock',
      );
      if (!verified) {
        if (context.mounted) _showCouldNotVerify(context);
        return; // leave the switch off
      }
    }

    await lockState.setEnabled(wantsEnabled);
  }

  void _showCouldNotVerify(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Could Not Verify'),
        content: const Text(
          "App Lock wasn't enabled because we couldn't verify your "
          'identity. Make sure Face ID, Touch ID, or a device passcode '
          'is set up, then try again.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Asks the OS for permission when turning on; if denied, the switch
  // stays off and the user is told where to fix it (iOS/Android never
  // re-show the system prompt after a denial — only Settings can).
  Future<void> _onPushToggled(BuildContext context, bool wantsEnabled) async {
    final ok = await context.read<PushNotificationState>().setEnabled(
      wantsEnabled,
    );
    if (!ok && context.mounted) {
      _showSimpleDialog(
        context,
        title: 'Notifications Not Allowed',
        message:
            'KarmaHR needs permission to send notifications. Allow it in '
            "your phone's Settings app under KarmaHR → Notifications, "
            'then try again.',
      );
    }
  }

  void _sendTestNotification(BuildContext context) {
    notifyUser(
      context,
      kind: AppNotificationKind.system,
      title: 'Test notification',
      body: 'Push notifications are working. 🎉',
    );
  }

  void _showSimpleDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // context.watch rebuilds this screen's checkmarks whenever the
    // selected mode changes — same pattern used for AttendanceState.
    final themeState = context.watch<ThemeState>();
    final appLock = context.watch<AppLockState>();
    final push = context.watch<PushNotificationState>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('APPEARANCE'),
              footer: const Text(
                'Choose how KarmaHR looks. "System Default" switches '
                'automatically with your phone — pick Light or Dark to '
                'keep it fixed no matter what your phone is set to.',
              ),
              children: AppThemeMode.values.map((mode) {
                final isSelected = themeState.mode == mode;
                return CupertinoListTile(
                  leading: Icon(_icon(mode)),
                  title: Text(_title(mode)),
                  subtitle: Text(_subtitle(mode)),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          color: CupertinoColors.activeGreen,
                        )
                      : null,
                  onTap: () => context.read<ThemeState>().setMode(mode),
                );
              }).toList(),
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('SECURITY'),
              footer: Text(
                appLock.deviceSupportsAuth == false
                    ? "Face ID, Touch ID, and a device passcode aren't "
                          'available on this device — App Lock can\'t be '
                          'turned on here.'
                    : 'Require Face ID, Touch ID, or your device passcode '
                          'every time KarmaHR is opened.',
              ),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.lock_shield),
                  title: const Text('App Lock'),
                  trailing: appLock.deviceSupportsAuth == null
                      ? const CupertinoActivityIndicator()
                      : CupertinoSwitch(
                          value: appLock.enabled,
                          onChanged: appLock.deviceSupportsAuth == false
                              ? null
                              : (value) => _onAppLockToggled(context, value),
                        ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('NOTIFICATIONS'),
              footer: Text(
                push.isLoaded && !push.pluginReady
                    ? "Notifications aren't available on this device."
                    : 'Get reminders to check out, event reminders, and '
                          'updates on your requests — even when KarmaHR '
                          'is closed. Everything also appears in the '
                          'in-app inbox either way.',
              ),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.bell),
                  title: const Text('Push Notifications'),
                  trailing: !push.isLoaded
                      ? const CupertinoActivityIndicator()
                      : CupertinoSwitch(
                          value: push.enabled,
                          onChanged: push.pluginReady
                              ? (value) => _onPushToggled(context, value)
                              : null,
                        ),
                ),
                if (push.enabled)
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.paperplane),
                    title: const Text('Send Test Notification'),
                    onTap: () => _sendTestNotification(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

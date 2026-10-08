import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/app_lock_state.dart';
import '../state/locale_state.dart';
import '../state/notification_state.dart';
import '../state/push_notification_state.dart';
import '../state/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Human-readable label + description for each mode, so the row-building
  // code below doesn't repeat itself three times.
  String _title(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return l10n.themeSystem;
      case AppThemeMode.light:
        return l10n.themeLight;
      case AppThemeMode.dark:
        return l10n.themeDark;
    }
  }

  String _subtitle(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return l10n.themeSystemSubtitle;
      case AppThemeMode.light:
        return l10n.themeLightSubtitle;
      case AppThemeMode.dark:
        return l10n.themeDarkSubtitle;
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
        reason: context.l10n.appLockVerifyReason,
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
        title: Text(context.l10n.couldNotVerifyTitle),
        content: Text(context.l10n.couldNotVerifyBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.ok),
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
        title: context.l10n.notificationsNotAllowedTitle,
        message: context.l10n.notificationsNotAllowedBody,
      );
    }
  }

  void _sendTestNotification(BuildContext context) {
    notifyUser(
      context,
      kind: AppNotificationKind.system,
      title: context.l10n.testNotificationTitle,
      body: context.l10n.testNotificationBody,
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
            child: Text(context.l10n.ok),
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
    final language = context.watch<LocaleState>().language;
    final l10n = context.l10n;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.settingsTitle)),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: Text(l10n.languageHeader),
              footer: Text(l10n.languageFooter),
              children: AppLanguage.values.map((option) {
                return CupertinoListTile(
                  leading: const Icon(CupertinoIcons.globe),
                  title: Text(option.nativeName),
                  trailing: option == language
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          color: CupertinoColors.activeGreen,
                        )
                      : null,
                  onTap: () =>
                      context.read<LocaleState>().setLanguage(option),
                );
              }).toList(),
            ),
            CupertinoListSection.insetGrouped(
              header: Text(l10n.appearanceHeader),
              footer: Text(l10n.appearanceFooter),
              children: AppThemeMode.values.map((mode) {
                final isSelected = themeState.mode == mode;
                return CupertinoListTile(
                  leading: Icon(_icon(mode)),
                  title: Text(_title(l10n, mode)),
                  subtitle: Text(_subtitle(l10n, mode)),
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
              header: Text(l10n.securityHeader),
              footer: Text(
                appLock.deviceSupportsAuth == false
                    ? l10n.appLockUnavailableFooter
                    : l10n.appLockFooter,
              ),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.lock_shield),
                  title: Text(l10n.appLock),
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
              header: Text(l10n.notificationsHeader),
              footer: Text(
                push.isLoaded && !push.pluginReady
                    ? l10n.pushUnavailableFooter
                    : l10n.pushFooter,
              ),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.bell),
                  title: Text(l10n.pushNotifications),
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
                    title: Text(l10n.sendTestNotification),
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

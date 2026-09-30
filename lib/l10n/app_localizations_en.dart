// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get roleEmployee => 'Employee';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleHr => 'HR';

  @override
  String get loginTitle => 'Sign in to KarmaHR';

  @override
  String get loginSubtitle => 'Enter your staff credentials to continue';

  @override
  String get staffIdLabel => 'Staff ID';

  @override
  String get staffIdHint => 'e.g. MB-24071';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordUnavailable =>
      'Forgot password isn\'t available yet.';

  @override
  String get signIn => 'Sign In';

  @override
  String get ssoDivider => 'or continue with SSO';

  @override
  String get continueWithSso => 'Continue with SSO';

  @override
  String get ssoUnavailable => 'SSO sign-in isn\'t available yet.';

  @override
  String get demoRoleLabel => 'Sign in as (demo)';

  @override
  String get demoRoleNote =>
      'Demo only. Once login is connected, your role will come from the server.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTeam => 'Team';

  @override
  String get tabLeave => 'Leave';

  @override
  String get tabTime => 'Time';

  @override
  String get tabEvents => 'Events';

  @override
  String get tabApps => 'Apps';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutConfirm => 'Are you sure you want to log out?';

  @override
  String signedInAs(String role) {
    return 'Signed in as $role';
  }

  @override
  String get teamTitle => 'My Team';

  @override
  String get teamComingTitle => 'Manager tools are on the way';

  @override
  String get teamComingBody =>
      'Approving leave, expenses and overtime, team attendance, and team reports will appear here.';

  @override
  String get hrPortalTitle => 'HR Portal';

  @override
  String get hrComingTitle => 'The HR portal is on the way';

  @override
  String get hrComingBody =>
      'Employee records, payroll runs, leave and holiday policies, notices, and reports will live here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageHeader => 'LANGUAGE';

  @override
  String get languageFooter =>
      'Screens are being translated step by step. Anything not translated yet stays in English.';

  @override
  String get appearanceHeader => 'APPEARANCE';

  @override
  String get appearanceFooter =>
      'Choose how KarmaHR looks. \"System Default\" switches automatically with your phone. Pick Light or Dark to keep it fixed no matter what your phone is set to.';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeSystemSubtitle => 'Match this phone\'s Light/Dark setting';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightSubtitle => 'Always use Light appearance';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkSubtitle => 'Always use Dark appearance';

  @override
  String get securityHeader => 'SECURITY';

  @override
  String get appLock => 'App Lock';

  @override
  String get appLockFooter =>
      'Require Face ID, Touch ID, or your device passcode every time KarmaHR is opened.';

  @override
  String get appLockUnavailableFooter =>
      'Face ID, Touch ID, and a device passcode aren\'t available on this device, so App Lock can\'t be turned on here.';

  @override
  String get appLockVerifyReason => 'Verify to enable App Lock';

  @override
  String get couldNotVerifyTitle => 'Could Not Verify';

  @override
  String get couldNotVerifyBody =>
      'App Lock wasn\'t enabled because we couldn\'t verify your identity. Make sure Face ID, Touch ID, or a device passcode is set up, then try again.';

  @override
  String get notificationsHeader => 'NOTIFICATIONS';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushFooter =>
      'Get reminders to check out, event reminders, and updates on your requests, even when KarmaHR is closed. Everything also appears in the in-app inbox either way.';

  @override
  String get pushUnavailableFooter =>
      'Notifications aren\'t available on this device.';

  @override
  String get sendTestNotification => 'Send Test Notification';

  @override
  String get notificationsNotAllowedTitle => 'Notifications Not Allowed';

  @override
  String get notificationsNotAllowedBody =>
      'KarmaHR needs permission to send notifications. Allow it in your phone\'s Settings app under KarmaHR → Notifications, then try again.';

  @override
  String get testNotificationTitle => 'Test notification';

  @override
  String get testNotificationBody => 'Push notifications are working. 🎉';
}

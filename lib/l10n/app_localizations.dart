import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @roleEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get roleEmployee;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleHr.
  ///
  /// In en, this message translates to:
  /// **'HR'**
  String get roleHr;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to KarmaHR'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your staff credentials to continue'**
  String get loginSubtitle;

  /// No description provided for @staffIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Staff ID'**
  String get staffIdLabel;

  /// No description provided for @staffIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. MB-24071'**
  String get staffIdHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Forgot password isn\'t available yet.'**
  String get forgotPasswordUnavailable;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @ssoDivider.
  ///
  /// In en, this message translates to:
  /// **'or continue with SSO'**
  String get ssoDivider;

  /// No description provided for @continueWithSso.
  ///
  /// In en, this message translates to:
  /// **'Continue with SSO'**
  String get continueWithSso;

  /// No description provided for @ssoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'SSO sign-in isn\'t available yet.'**
  String get ssoUnavailable;

  /// No description provided for @demoRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign in as (demo)'**
  String get demoRoleLabel;

  /// No description provided for @demoRoleNote.
  ///
  /// In en, this message translates to:
  /// **'Demo only. Once login is connected, your role will come from the server.'**
  String get demoRoleNote;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get tabTeam;

  /// No description provided for @tabLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get tabLeave;

  /// No description provided for @tabTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get tabTime;

  /// No description provided for @tabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get tabEvents;

  /// No description provided for @tabApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get tabApps;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {role}'**
  String signedInAs(String role);

  /// No description provided for @teamTitle.
  ///
  /// In en, this message translates to:
  /// **'My Team'**
  String get teamTitle;

  /// No description provided for @teamComingTitle.
  ///
  /// In en, this message translates to:
  /// **'Manager tools are on the way'**
  String get teamComingTitle;

  /// No description provided for @teamComingBody.
  ///
  /// In en, this message translates to:
  /// **'Approving leave, expenses and overtime, team attendance, and team reports will appear here.'**
  String get teamComingBody;

  /// No description provided for @hrPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'HR Portal'**
  String get hrPortalTitle;

  /// No description provided for @hrComingTitle.
  ///
  /// In en, this message translates to:
  /// **'The HR portal is on the way'**
  String get hrComingTitle;

  /// No description provided for @hrComingBody.
  ///
  /// In en, this message translates to:
  /// **'Employee records, payroll runs, leave and holiday policies, notices, and reports will live here.'**
  String get hrComingBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageHeader.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageHeader;

  /// No description provided for @languageFooter.
  ///
  /// In en, this message translates to:
  /// **'Screens are being translated step by step. Anything not translated yet stays in English.'**
  String get languageFooter;

  /// No description provided for @appearanceHeader.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearanceHeader;

  /// No description provided for @appearanceFooter.
  ///
  /// In en, this message translates to:
  /// **'Choose how KarmaHR looks. \"System Default\" switches automatically with your phone. Pick Light or Dark to keep it fixed no matter what your phone is set to.'**
  String get appearanceFooter;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Match this phone\'s Light/Dark setting'**
  String get themeSystemSubtitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use Light appearance'**
  String get themeLightSubtitle;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use Dark appearance'**
  String get themeDarkSubtitle;

  /// No description provided for @securityHeader.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get securityHeader;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLockFooter.
  ///
  /// In en, this message translates to:
  /// **'Require Face ID, Touch ID, or your device passcode every time KarmaHR is opened.'**
  String get appLockFooter;

  /// No description provided for @appLockUnavailableFooter.
  ///
  /// In en, this message translates to:
  /// **'Face ID, Touch ID, and a device passcode aren\'t available on this device, so App Lock can\'t be turned on here.'**
  String get appLockUnavailableFooter;

  /// No description provided for @appLockVerifyReason.
  ///
  /// In en, this message translates to:
  /// **'Verify to enable App Lock'**
  String get appLockVerifyReason;

  /// No description provided for @couldNotVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Could Not Verify'**
  String get couldNotVerifyTitle;

  /// No description provided for @couldNotVerifyBody.
  ///
  /// In en, this message translates to:
  /// **'App Lock wasn\'t enabled because we couldn\'t verify your identity. Make sure Face ID, Touch ID, or a device passcode is set up, then try again.'**
  String get couldNotVerifyBody;

  /// No description provided for @notificationsHeader.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notificationsHeader;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushFooter.
  ///
  /// In en, this message translates to:
  /// **'Get reminders to check out, event reminders, and updates on your requests, even when KarmaHR is closed. Everything also appears in the in-app inbox either way.'**
  String get pushFooter;

  /// No description provided for @pushUnavailableFooter.
  ///
  /// In en, this message translates to:
  /// **'Notifications aren\'t available on this device.'**
  String get pushUnavailableFooter;

  /// No description provided for @sendTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get sendTestNotification;

  /// No description provided for @notificationsNotAllowedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications Not Allowed'**
  String get notificationsNotAllowedTitle;

  /// No description provided for @notificationsNotAllowedBody.
  ///
  /// In en, this message translates to:
  /// **'KarmaHR needs permission to send notifications. Allow it in your phone\'s Settings app under KarmaHR → Notifications, then try again.'**
  String get notificationsNotAllowedBody;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Test notification'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Push notifications are working. 🎉'**
  String get testNotificationBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

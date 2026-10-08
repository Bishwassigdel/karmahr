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

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @moreApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get moreApps;

  /// No description provided for @moreAppsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All your tools in one place'**
  String get moreAppsSubtitle;

  /// No description provided for @moreProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get moreProfile;

  /// No description provided for @myInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'My Info'**
  String get myInfoTitle;

  /// No description provided for @infoTabJob.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get infoTabJob;

  /// No description provided for @infoTabContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get infoTabContact;

  /// No description provided for @infoTabPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get infoTabPay;

  /// No description provided for @infoTabDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get infoTabDocs;

  /// No description provided for @infoTabEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get infoTabEmergency;

  /// No description provided for @staffIdValue.
  ///
  /// In en, this message translates to:
  /// **'Staff ID {id}'**
  String staffIdValue(String id);

  /// No description provided for @jobTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitleLabel;

  /// No description provided for @departmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get departmentLabel;

  /// No description provided for @managerLabel.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get managerLabel;

  /// No description provided for @joinedLabel.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joinedLabel;

  /// No description provided for @employmentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Employment type'**
  String get employmentTypeLabel;

  /// No description provided for @workLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Work location'**
  String get workLocationLabel;

  /// No description provided for @workEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Work email'**
  String get workEmailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @pendingHrApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending HR approval: {phone}'**
  String pendingHrApproval(String phone);

  /// No description provided for @basicSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Basic salary'**
  String get basicSalaryLabel;

  /// No description provided for @dearnessAllowanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Dearness allowance'**
  String get dearnessAllowanceLabel;

  /// No description provided for @transportAllowanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Transport allowance'**
  String get transportAllowanceLabel;

  /// No description provided for @grossMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Gross per month'**
  String get grossMonthlyLabel;

  /// No description provided for @payslipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payslips'**
  String get payslipsLabel;

  /// No description provided for @taxPlannerLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax planner'**
  String get taxPlannerLabel;

  /// No description provided for @salaryCertificateLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary certificate'**
  String get salaryCertificateLabel;

  /// No description provided for @manageDocuments.
  ///
  /// In en, this message translates to:
  /// **'Manage documents'**
  String get manageDocuments;

  /// No description provided for @noDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents yet.'**
  String get noDocuments;

  /// No description provided for @emergencyContactsLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get emergencyContactsLabel;

  /// No description provided for @healthInsuranceLabel.
  ///
  /// In en, this message translates to:
  /// **'Health insurance'**
  String get healthInsuranceLabel;

  /// No description provided for @manageEmergency.
  ///
  /// In en, this message translates to:
  /// **'Manage contacts & insurance'**
  String get manageEmergency;

  /// No description provided for @tabTimeOff.
  ///
  /// In en, this message translates to:
  /// **'Time Off'**
  String get tabTimeOff;

  /// No description provided for @requestTimeOff.
  ///
  /// In en, this message translates to:
  /// **'Request time off'**
  String get requestTimeOff;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(String days);

  /// No description provided for @planTrip.
  ///
  /// In en, this message translates to:
  /// **'Plan a trip'**
  String get planTrip;

  /// No description provided for @planTripSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find bridge days around holidays'**
  String get planTripSubtitle;

  /// No description provided for @holidayCalendarLabel.
  ///
  /// In en, this message translates to:
  /// **'Holiday calendar'**
  String get holidayCalendarLabel;

  /// No description provided for @allBalances.
  ///
  /// In en, this message translates to:
  /// **'All balances'**
  String get allBalances;

  /// No description provided for @myTimeOffRequests.
  ///
  /// In en, this message translates to:
  /// **'My time-off requests'**
  String get myTimeOffRequests;

  /// No description provided for @noTimeOffRequests.
  ///
  /// In en, this message translates to:
  /// **'No time off requested yet.'**
  String get noTimeOffRequests;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @tabRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get tabRequests;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get filterOpen;

  /// No description provided for @filterClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get filterClosed;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get newRequest;

  /// No description provided for @requestTypeLeave.
  ///
  /// In en, this message translates to:
  /// **'Time off'**
  String get requestTypeLeave;

  /// No description provided for @requestTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense claim'**
  String get requestTypeExpense;

  /// No description provided for @requestTypeOvertime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get requestTypeOvertime;

  /// No description provided for @requestTypeHr.
  ///
  /// In en, this message translates to:
  /// **'HR request'**
  String get requestTypeHr;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'Nothing here. You\'re all caught up.'**
  String get noRequests;

  /// No description provided for @whatsHappening.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening'**
  String get whatsHappening;

  /// No description provided for @feedOut.
  ///
  /// In en, this message translates to:
  /// **'{name} is out'**
  String feedOut(String name);

  /// No description provided for @feedBirthday.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s birthday'**
  String feedBirthday(String name);

  /// No description provided for @feedAnniversary.
  ///
  /// In en, this message translates to:
  /// **'{name}: {years} years at KarmaHR'**
  String feedAnniversary(String name, int years);

  /// No description provided for @feedToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get feedToday;

  /// No description provided for @feedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get feedTomorrow;

  /// No description provided for @feedNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing happening this week.'**
  String get feedNothing;

  /// No description provided for @a11ySearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get a11ySearch;

  /// No description provided for @a11yAddDocument.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get a11yAddDocument;

  /// No description provided for @a11yNewExpenseClaim.
  ///
  /// In en, this message translates to:
  /// **'New expense claim'**
  String get a11yNewExpenseClaim;

  /// No description provided for @a11yAddGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get a11yAddGoal;

  /// No description provided for @a11yGiveKudos.
  ///
  /// In en, this message translates to:
  /// **'Give kudos'**
  String get a11yGiveKudos;

  /// No description provided for @a11yPostComment.
  ///
  /// In en, this message translates to:
  /// **'Post comment'**
  String get a11yPostComment;

  /// No description provided for @a11yRemoveContact.
  ///
  /// In en, this message translates to:
  /// **'Remove contact'**
  String get a11yRemoveContact;

  /// No description provided for @a11yPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get a11yPreviousMonth;

  /// No description provided for @a11yNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get a11yNextMonth;

  /// No description provided for @a11yShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get a11yShowPassword;

  /// No description provided for @a11yHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get a11yHidePassword;

  /// No description provided for @a11yShareSlip.
  ///
  /// In en, this message translates to:
  /// **'Share payslip'**
  String get a11yShareSlip;

  /// No description provided for @a11yFewerHours.
  ///
  /// In en, this message translates to:
  /// **'Fewer hours'**
  String get a11yFewerHours;

  /// No description provided for @a11yMoreHours.
  ///
  /// In en, this message translates to:
  /// **'More hours'**
  String get a11yMoreHours;

  /// No description provided for @a11yNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get a11yNotifications;

  /// No description provided for @a11yNotificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'Notifications, {count} unread'**
  String a11yNotificationsUnread(int count);

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

  /// No description provided for @hrTabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get hrTabMore;

  /// No description provided for @hrPeopleEvents.
  ///
  /// In en, this message translates to:
  /// **'Birthdays & work anniversaries'**
  String get hrPeopleEvents;

  /// No description provided for @hrNoPeopleEvents.
  ///
  /// In en, this message translates to:
  /// **'No birthdays or anniversaries in the next 30 days.'**
  String get hrNoPeopleEvents;

  /// No description provided for @hrBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get hrBirthday;

  /// No description provided for @hrAnniversary.
  ///
  /// In en, this message translates to:
  /// **'{years}-year work anniversary'**
  String hrAnniversary(int years);

  /// No description provided for @hrSectionOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get hrSectionOverview;

  /// No description provided for @hrSectionEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get hrSectionEmployees;

  /// No description provided for @hrSectionLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave & Holidays'**
  String get hrSectionLeave;

  /// No description provided for @hrSectionPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get hrSectionPayroll;

  /// No description provided for @hrSectionNotices.
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get hrSectionNotices;

  /// No description provided for @hrSectionReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get hrSectionReports;

  /// No description provided for @hrStatEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get hrStatEmployees;

  /// No description provided for @hrStatDepartments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get hrStatDepartments;

  /// No description provided for @hrStatOutToday.
  ///
  /// In en, this message translates to:
  /// **'Out today'**
  String get hrStatOutToday;

  /// No description provided for @hrByDepartment.
  ///
  /// In en, this message translates to:
  /// **'Employees by department'**
  String get hrByDepartment;

  /// No description provided for @hrNobodyOut.
  ///
  /// In en, this message translates to:
  /// **'Nobody is on leave today.'**
  String get hrNobodyOut;

  /// No description provided for @hrDemoDataNote.
  ///
  /// In en, this message translates to:
  /// **'Demo data. Real numbers arrive when the backend is connected.'**
  String get hrDemoDataNote;

  /// No description provided for @hrSearchEmployees.
  ///
  /// In en, this message translates to:
  /// **'Search by name, role or department'**
  String get hrSearchEmployees;

  /// No description provided for @hrAddEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get hrAddEmployee;

  /// No description provided for @hrFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get hrFilterActive;

  /// No description provided for @hrFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get hrFilterInactive;

  /// No description provided for @hrNoEmployeesFound.
  ///
  /// In en, this message translates to:
  /// **'No employees match.'**
  String get hrNoEmployeesFound;

  /// No description provided for @hrEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get hrEmployeeTitle;

  /// No description provided for @hrNoManager.
  ///
  /// In en, this message translates to:
  /// **'No manager'**
  String get hrNoManager;

  /// No description provided for @hrFilingStatus.
  ///
  /// In en, this message translates to:
  /// **'Tax filing'**
  String get hrFilingStatus;

  /// No description provided for @hrFilingSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get hrFilingSingle;

  /// No description provided for @hrFilingMarried.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get hrFilingMarried;

  /// No description provided for @hrDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate employee'**
  String get hrDeactivate;

  /// No description provided for @hrReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate employee'**
  String get hrReactivate;

  /// No description provided for @hrDeactivateAction.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get hrDeactivateAction;

  /// No description provided for @hrReactivateAction.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get hrReactivateAction;

  /// No description provided for @hrDeactivateMessage.
  ///
  /// In en, this message translates to:
  /// **'They will no longer appear in the directory or in payroll. Their records are kept.'**
  String get hrDeactivateMessage;

  /// No description provided for @hrReactivateMessage.
  ///
  /// In en, this message translates to:
  /// **'They will appear in the directory and in payroll again.'**
  String get hrReactivateMessage;

  /// No description provided for @hrNewEmployee.
  ///
  /// In en, this message translates to:
  /// **'New employee'**
  String get hrNewEmployee;

  /// No description provided for @hrEditEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit employee'**
  String get hrEditEmployee;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @hrFieldName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get hrFieldName;

  /// No description provided for @hrCheckDetails.
  ///
  /// In en, this message translates to:
  /// **'Check the details'**
  String get hrCheckDetails;

  /// No description provided for @hrErrName.
  ///
  /// In en, this message translates to:
  /// **'Enter the employee\'s full name.'**
  String get hrErrName;

  /// No description provided for @hrErrJob.
  ///
  /// In en, this message translates to:
  /// **'Enter a job title and a department.'**
  String get hrErrJob;

  /// No description provided for @hrErrEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get hrErrEmail;

  /// No description provided for @hrErrPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit mobile number starting with 96, 97 or 98 (optionally with +977).'**
  String get hrErrPhone;

  /// No description provided for @hrErrSalary.
  ///
  /// In en, this message translates to:
  /// **'Enter a basic salary above zero.'**
  String get hrErrSalary;

  /// No description provided for @hrApprovalsTab.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get hrApprovalsTab;

  /// No description provided for @hrPolicyTab.
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get hrPolicyTab;

  /// No description provided for @hrHolidaysTab.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get hrHolidaysTab;

  /// No description provided for @hrApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get hrApprove;

  /// No description provided for @hrReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get hrReject;

  /// No description provided for @hrRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this request?'**
  String get hrRejectTitle;

  /// No description provided for @hrDecided.
  ///
  /// In en, this message translates to:
  /// **'Decided'**
  String get hrDecided;

  /// No description provided for @hrPolicyNoCarry.
  ///
  /// In en, this message translates to:
  /// **'Does not carry forward'**
  String get hrPolicyNoCarry;

  /// No description provided for @hrPolicyCarryAll.
  ///
  /// In en, this message translates to:
  /// **'Carries forward without limit'**
  String get hrPolicyCarryAll;

  /// No description provided for @hrPolicyPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get hrPolicyPaid;

  /// No description provided for @hrPolicyUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get hrPolicyUnpaid;

  /// No description provided for @hrPolicyNote.
  ///
  /// In en, this message translates to:
  /// **'These figures are placeholders until HR and legal sign them off. Editing policy arrives with the backend.'**
  String get hrPolicyNote;

  /// No description provided for @hrCompanyHolidays.
  ///
  /// In en, this message translates to:
  /// **'Company holidays'**
  String get hrCompanyHolidays;

  /// No description provided for @hrPublicHolidays.
  ///
  /// In en, this message translates to:
  /// **'Upcoming public holidays'**
  String get hrPublicHolidays;

  /// No description provided for @hrAddHoliday.
  ///
  /// In en, this message translates to:
  /// **'Add company holiday'**
  String get hrAddHoliday;

  /// No description provided for @hrHolidayName.
  ///
  /// In en, this message translates to:
  /// **'Holiday name'**
  String get hrHolidayName;

  /// No description provided for @hrHolidayDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get hrHolidayDate;

  /// No description provided for @hrNoCompanyHolidays.
  ///
  /// In en, this message translates to:
  /// **'No company holidays yet.'**
  String get hrNoCompanyHolidays;

  /// No description provided for @hrNoPublicHolidays.
  ///
  /// In en, this message translates to:
  /// **'No upcoming public holidays in the calendar.'**
  String get hrNoPublicHolidays;

  /// No description provided for @hrHolidayNeedsName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the holiday.'**
  String get hrHolidayNeedsName;

  /// No description provided for @hrRemoveHoliday.
  ///
  /// In en, this message translates to:
  /// **'Remove holiday'**
  String get hrRemoveHoliday;

  /// No description provided for @hrRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get hrRemoveAction;

  /// No description provided for @hrHolidayNote.
  ///
  /// In en, this message translates to:
  /// **'Public holidays come from the government calendar. Company holidays you add here are HR\'s record; the employee calendar picks them up once the backend is connected.'**
  String get hrHolidayNote;

  /// No description provided for @hrNeedsAction.
  ///
  /// In en, this message translates to:
  /// **'Needs your action'**
  String get hrNeedsAction;

  /// No description provided for @hrPayPeriod.
  ///
  /// In en, this message translates to:
  /// **'Pay period'**
  String get hrPayPeriod;

  /// No description provided for @hrRunPayroll.
  ///
  /// In en, this message translates to:
  /// **'Run payroll'**
  String get hrRunPayroll;

  /// No description provided for @hrRecalculate.
  ///
  /// In en, this message translates to:
  /// **'Recalculate'**
  String get hrRecalculate;

  /// No description provided for @hrApprovePayroll.
  ///
  /// In en, this message translates to:
  /// **'Approve payroll'**
  String get hrApprovePayroll;

  /// No description provided for @hrApprovePayrollMessage.
  ///
  /// In en, this message translates to:
  /// **'Once approved, the figures are frozen: later changes to employee records won\'t alter this payroll.'**
  String get hrApprovePayrollMessage;

  /// No description provided for @hrMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get hrMarkPaid;

  /// No description provided for @hrMarkPaidMessage.
  ///
  /// In en, this message translates to:
  /// **'Do this after the bank transfer is done.'**
  String get hrMarkPaidMessage;

  /// No description provided for @hrPayrollDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get hrPayrollDraft;

  /// No description provided for @hrPayGross.
  ///
  /// In en, this message translates to:
  /// **'Gross'**
  String get hrPayGross;

  /// No description provided for @hrPayDeductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get hrPayDeductions;

  /// No description provided for @hrPayNet.
  ///
  /// In en, this message translates to:
  /// **'Net pay'**
  String get hrPayNet;

  /// No description provided for @hrExportRegister.
  ///
  /// In en, this message translates to:
  /// **'Payroll register (CSV)'**
  String get hrExportRegister;

  /// No description provided for @hrExportBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer file (CSV)'**
  String get hrExportBank;

  /// No description provided for @hrExportTds.
  ///
  /// In en, this message translates to:
  /// **'TDS report (CSV)'**
  String get hrExportTds;

  /// No description provided for @hrExportSsf.
  ///
  /// In en, this message translates to:
  /// **'SSF contribution report (CSV)'**
  String get hrExportSsf;

  /// No description provided for @hrSharePayslip.
  ///
  /// In en, this message translates to:
  /// **'Share payslip (PDF)'**
  String get hrSharePayslip;

  /// No description provided for @hrBankNeedsApproval.
  ///
  /// In en, this message translates to:
  /// **'Approve the payroll first to export the bank file.'**
  String get hrBankNeedsApproval;

  /// No description provided for @hrBankName.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get hrBankName;

  /// No description provided for @hrAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get hrAccountNumber;

  /// No description provided for @hrErrAccount.
  ///
  /// In en, this message translates to:
  /// **'Account numbers contain digits only.'**
  String get hrErrAccount;

  /// No description provided for @hrBankMissing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 employee has no bank account on file and is left out of the bank file: {names}} other{{count} employees have no bank account on file and are left out of the bank file: {names}}}'**
  String hrBankMissing(int count, String names);

  /// No description provided for @hrLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get hrLetters;

  /// No description provided for @hrLettersFooter.
  ///
  /// In en, this message translates to:
  /// **'Made as PDFs for you to sign and share.'**
  String get hrLettersFooter;

  /// No description provided for @hrLetterAppointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment letter'**
  String get hrLetterAppointment;

  /// No description provided for @hrLetterExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience letter'**
  String get hrLetterExperience;

  /// No description provided for @hrAddDocument.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get hrAddDocument;

  /// No description provided for @hrDocName.
  ///
  /// In en, this message translates to:
  /// **'Document name'**
  String get hrDocName;

  /// No description provided for @hrDocType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get hrDocType;

  /// No description provided for @hrDocExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get hrDocExpires;

  /// No description provided for @hrDocNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get hrDocNoExpiry;

  /// No description provided for @hrDocExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get hrDocExpired;

  /// No description provided for @hrNoDocs.
  ///
  /// In en, this message translates to:
  /// **'No documents on file.'**
  String get hrNoDocs;

  /// No description provided for @hrDocNeedsName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the document.'**
  String get hrDocNeedsName;

  /// No description provided for @hrRemoveDoc.
  ///
  /// In en, this message translates to:
  /// **'Remove document'**
  String get hrRemoveDoc;

  /// No description provided for @hrReportsDocs.
  ///
  /// In en, this message translates to:
  /// **'Documents expiring soon'**
  String get hrReportsDocs;

  /// No description provided for @hrNoExpiringDocs.
  ///
  /// In en, this message translates to:
  /// **'No documents expire in the next 30 days.'**
  String get hrNoExpiringDocs;

  /// No description provided for @hrDocContract.
  ///
  /// In en, this message translates to:
  /// **'Employment contract'**
  String get hrDocContract;

  /// No description provided for @hrDocCitizenship.
  ///
  /// In en, this message translates to:
  /// **'Citizenship certificate'**
  String get hrDocCitizenship;

  /// No description provided for @hrDocPan.
  ///
  /// In en, this message translates to:
  /// **'PAN card'**
  String get hrDocPan;

  /// No description provided for @hrDocPermit.
  ///
  /// In en, this message translates to:
  /// **'Work permit'**
  String get hrDocPermit;

  /// No description provided for @hrDocCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get hrDocCertificate;

  /// No description provided for @hrDocOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get hrDocOther;

  /// No description provided for @hrAuditDocumentAdded.
  ///
  /// In en, this message translates to:
  /// **'Document added'**
  String get hrAuditDocumentAdded;

  /// No description provided for @hrAuditDocumentRemoved.
  ///
  /// In en, this message translates to:
  /// **'Document removed'**
  String get hrAuditDocumentRemoved;

  /// No description provided for @hrSectionAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get hrSectionAttendance;

  /// No description provided for @hrSectionReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get hrSectionReviews;

  /// No description provided for @hrSectionHiring.
  ///
  /// In en, this message translates to:
  /// **'Hiring'**
  String get hrSectionHiring;

  /// No description provided for @hrAttPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get hrAttPresent;

  /// No description provided for @hrAttLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get hrAttLate;

  /// No description provided for @hrAttAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get hrAttAbsent;

  /// No description provided for @hrAttOnLeave.
  ///
  /// In en, this message translates to:
  /// **'On leave'**
  String get hrAttOnLeave;

  /// No description provided for @hrAttWeeklyOff.
  ///
  /// In en, this message translates to:
  /// **'Weekly holiday. Nobody is expected at work.'**
  String get hrAttWeeklyOff;

  /// No description provided for @hrAttNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No records for this day.'**
  String get hrAttNoRecords;

  /// No description provided for @hrReviewStart.
  ///
  /// In en, this message translates to:
  /// **'Start review cycle'**
  String get hrReviewStart;

  /// No description provided for @hrReviewName.
  ///
  /// In en, this message translates to:
  /// **'Cycle name'**
  String get hrReviewName;

  /// No description provided for @hrReviewNeedsName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the review cycle.'**
  String get hrReviewNeedsName;

  /// No description provided for @hrReviewNoCycles.
  ///
  /// In en, this message translates to:
  /// **'No review cycles yet.'**
  String get hrReviewNoCycles;

  /// No description provided for @hrReviewAdvance.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get hrReviewAdvance;

  /// No description provided for @hrStageNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get hrStageNotStarted;

  /// No description provided for @hrStageSelf.
  ///
  /// In en, this message translates to:
  /// **'Self review done'**
  String get hrStageSelf;

  /// No description provided for @hrStageManager.
  ///
  /// In en, this message translates to:
  /// **'Manager review done'**
  String get hrStageManager;

  /// No description provided for @hrStageCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get hrStageCompleted;

  /// No description provided for @hrAuditReviewStarted.
  ///
  /// In en, this message translates to:
  /// **'Review cycle started'**
  String get hrAuditReviewStarted;

  /// No description provided for @hrJobNew.
  ///
  /// In en, this message translates to:
  /// **'New job'**
  String get hrJobNew;

  /// No description provided for @hrJobOpenings.
  ///
  /// In en, this message translates to:
  /// **'Openings'**
  String get hrJobOpenings;

  /// No description provided for @hrJobOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get hrJobOpen;

  /// No description provided for @hrJobClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get hrJobClosed;

  /// No description provided for @hrJobClose.
  ///
  /// In en, this message translates to:
  /// **'Close job'**
  String get hrJobClose;

  /// No description provided for @hrJobReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen job'**
  String get hrJobReopen;

  /// No description provided for @hrNoJobs.
  ///
  /// In en, this message translates to:
  /// **'No jobs yet.'**
  String get hrNoJobs;

  /// No description provided for @hrJobNeedsDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter a job title, a department and at least one opening.'**
  String get hrJobNeedsDetails;

  /// No description provided for @hrApplicants.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get hrApplicants;

  /// No description provided for @hrAddApplicant.
  ///
  /// In en, this message translates to:
  /// **'Add applicant'**
  String get hrAddApplicant;

  /// No description provided for @hrApplicantName.
  ///
  /// In en, this message translates to:
  /// **'Applicant name'**
  String get hrApplicantName;

  /// No description provided for @hrApplicantEmail.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get hrApplicantEmail;

  /// No description provided for @hrApplicantNeedsName.
  ///
  /// In en, this message translates to:
  /// **'Enter the applicant\'s name.'**
  String get hrApplicantNeedsName;

  /// No description provided for @hrNoApplicants.
  ///
  /// In en, this message translates to:
  /// **'No applicants yet.'**
  String get hrNoApplicants;

  /// No description provided for @hrApplicantAdvance.
  ///
  /// In en, this message translates to:
  /// **'Next stage'**
  String get hrApplicantAdvance;

  /// No description provided for @hrAddAsEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add as employee'**
  String get hrAddAsEmployee;

  /// No description provided for @hrAppApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get hrAppApplied;

  /// No description provided for @hrAppScreening.
  ///
  /// In en, this message translates to:
  /// **'Screening'**
  String get hrAppScreening;

  /// No description provided for @hrAppInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get hrAppInterview;

  /// No description provided for @hrAppOffer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get hrAppOffer;

  /// No description provided for @hrAppHired.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get hrAppHired;

  /// No description provided for @hrAuditJobPosted.
  ///
  /// In en, this message translates to:
  /// **'Job posted'**
  String get hrAuditJobPosted;

  /// No description provided for @hrAuditApplicantHired.
  ///
  /// In en, this message translates to:
  /// **'Applicant hired'**
  String get hrAuditApplicantHired;

  /// No description provided for @hrShowOrgChart.
  ///
  /// In en, this message translates to:
  /// **'Show org chart'**
  String get hrShowOrgChart;

  /// No description provided for @hrShowList.
  ///
  /// In en, this message translates to:
  /// **'Show list'**
  String get hrShowList;

  /// No description provided for @hrTabTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get hrTabTasks;

  /// No description provided for @hrOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get hrOnboarding;

  /// No description provided for @hrOffboarding.
  ///
  /// In en, this message translates to:
  /// **'Offboarding'**
  String get hrOffboarding;

  /// No description provided for @hrTaskCollectDocs.
  ///
  /// In en, this message translates to:
  /// **'Collect documents'**
  String get hrTaskCollectDocs;

  /// No description provided for @hrTaskCreateAccounts.
  ///
  /// In en, this message translates to:
  /// **'Create accounts and email'**
  String get hrTaskCreateAccounts;

  /// No description provided for @hrTaskIssueEquipment.
  ///
  /// In en, this message translates to:
  /// **'Issue laptop and equipment'**
  String get hrTaskIssueEquipment;

  /// No description provided for @hrTaskInduction.
  ///
  /// In en, this message translates to:
  /// **'Hold induction session'**
  String get hrTaskInduction;

  /// No description provided for @hrTaskIntroduceTeam.
  ///
  /// In en, this message translates to:
  /// **'Introduce the team'**
  String get hrTaskIntroduceTeam;

  /// No description provided for @hrTaskExitInterview.
  ///
  /// In en, this message translates to:
  /// **'Exit interview'**
  String get hrTaskExitInterview;

  /// No description provided for @hrTaskReturnAssets.
  ///
  /// In en, this message translates to:
  /// **'Collect laptop and ID card'**
  String get hrTaskReturnAssets;

  /// No description provided for @hrTaskFinalSettlement.
  ///
  /// In en, this message translates to:
  /// **'Final salary settlement'**
  String get hrTaskFinalSettlement;

  /// No description provided for @hrTaskDisableAccounts.
  ///
  /// In en, this message translates to:
  /// **'Disable accounts'**
  String get hrTaskDisableAccounts;

  /// No description provided for @hrTaskExperienceLetter.
  ///
  /// In en, this message translates to:
  /// **'Issue experience letter'**
  String get hrTaskExperienceLetter;

  /// No description provided for @hrImportEmployees.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV'**
  String get hrImportEmployees;

  /// No description provided for @hrImportHint.
  ///
  /// In en, this message translates to:
  /// **'One person per line: Name, Job title, Department, Email, Phone, Basic salary, Dearness allowance, Transport allowance'**
  String get hrImportHint;

  /// No description provided for @hrImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get hrImportAction;

  /// No description provided for @hrImportNothing.
  ///
  /// In en, this message translates to:
  /// **'There is nothing to import.'**
  String get hrImportNothing;

  /// No description provided for @hrImportBadColumns.
  ///
  /// In en, this message translates to:
  /// **'needs 8 columns'**
  String get hrImportBadColumns;

  /// No description provided for @hrImportResult.
  ///
  /// In en, this message translates to:
  /// **'Import finished'**
  String get hrImportResult;

  /// No description provided for @hrAuditEmployeesImported.
  ///
  /// In en, this message translates to:
  /// **'Employees imported'**
  String get hrAuditEmployeesImported;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'CEO'**
  String get roleOwner;

  /// No description provided for @ownerSecOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get ownerSecOverview;

  /// No description provided for @ownerSecDepartments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get ownerSecDepartments;

  /// No description provided for @ownerSecPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get ownerSecPeople;

  /// No description provided for @ownerSecMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get ownerSecMoney;

  /// No description provided for @ownerSecActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get ownerSecActivity;

  /// No description provided for @ownerKpiHeadcount.
  ///
  /// In en, this message translates to:
  /// **'Headcount'**
  String get ownerKpiHeadcount;

  /// No description provided for @ownerKpiProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress score'**
  String get ownerKpiProgress;

  /// No description provided for @ownerKpiAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get ownerKpiAttendance;

  /// No description provided for @ownerKpiPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll this month'**
  String get ownerKpiPayroll;

  /// No description provided for @ownerKpiAttrition.
  ///
  /// In en, this message translates to:
  /// **'Left in the last year'**
  String get ownerKpiAttrition;

  /// No description provided for @ownerNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get ownerNeedsAttention;

  /// No description provided for @ownerAllGood.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs attention right now.'**
  String get ownerAllGood;

  /// No description provided for @ownerDeptProgress.
  ///
  /// In en, this message translates to:
  /// **'Department progress'**
  String get ownerDeptProgress;

  /// No description provided for @ownerSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get ownerSeeAll;

  /// No description provided for @ownerLowestFirst.
  ///
  /// In en, this message translates to:
  /// **'Lowest score first'**
  String get ownerLowestFirst;

  /// No description provided for @ownerStatusOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get ownerStatusOnTrack;

  /// No description provided for @ownerStatusWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get ownerStatusWatch;

  /// No description provided for @ownerStatusBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get ownerStatusBehind;

  /// No description provided for @ownerHowCalculated.
  ///
  /// In en, this message translates to:
  /// **'How is progress calculated?'**
  String get ownerHowCalculated;

  /// No description provided for @ownerMetricGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals on track'**
  String get ownerMetricGoals;

  /// No description provided for @ownerMetricReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews completed'**
  String get ownerMetricReviews;

  /// No description provided for @ownerMetricTraining.
  ///
  /// In en, this message translates to:
  /// **'Training completed'**
  String get ownerMetricTraining;

  /// No description provided for @ownerTrend12.
  ///
  /// In en, this message translates to:
  /// **'Headcount, last 12 months'**
  String get ownerTrend12;

  /// No description provided for @ownerByBranch.
  ///
  /// In en, this message translates to:
  /// **'By branch'**
  String get ownerByBranch;

  /// No description provided for @ownerViewPeople.
  ///
  /// In en, this message translates to:
  /// **'See the people'**
  String get ownerViewPeople;

  /// No description provided for @ownerSearchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search by name or role'**
  String get ownerSearchPeople;

  /// No description provided for @ownerAllDepartments.
  ///
  /// In en, this message translates to:
  /// **'All departments'**
  String get ownerAllDepartments;

  /// No description provided for @ownerAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get ownerAllBranches;

  /// No description provided for @ownerDepartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get ownerDepartmentLabel;

  /// No description provided for @ownerBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get ownerBranchLabel;

  /// No description provided for @ownerAttendance30.
  ///
  /// In en, this message translates to:
  /// **'Attendance, last 30 days'**
  String get ownerAttendance30;

  /// No description provided for @ownerGoalsThisQuarter.
  ///
  /// In en, this message translates to:
  /// **'Goals this quarter'**
  String get ownerGoalsThisQuarter;

  /// No description provided for @ownerReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Performance review'**
  String get ownerReviewLabel;

  /// No description provided for @ownerReviewDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get ownerReviewDone;

  /// No description provided for @ownerReviewPending.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get ownerReviewPending;

  /// No description provided for @ownerTrainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get ownerTrainingLabel;

  /// No description provided for @ownerLeaveBalance.
  ///
  /// In en, this message translates to:
  /// **'Leave balance'**
  String get ownerLeaveBalance;

  /// No description provided for @ownerPay.
  ///
  /// In en, this message translates to:
  /// **'Monthly pay'**
  String get ownerPay;

  /// No description provided for @ownerShowPay.
  ///
  /// In en, this message translates to:
  /// **'Show pay'**
  String get ownerShowPay;

  /// No description provided for @ownerHidePay.
  ///
  /// In en, this message translates to:
  /// **'Hide pay'**
  String get ownerHidePay;

  /// No description provided for @ownerPayHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get ownerPayHidden;

  /// No description provided for @ownerShowPayMessage.
  ///
  /// In en, this message translates to:
  /// **'Viewing someone\'s pay is recorded in the audit log.'**
  String get ownerShowPayMessage;

  /// No description provided for @hrAuditPayViewed.
  ///
  /// In en, this message translates to:
  /// **'Pay viewed'**
  String get hrAuditPayViewed;

  /// No description provided for @ownerPayrollTrend.
  ///
  /// In en, this message translates to:
  /// **'Payroll, last 12 months'**
  String get ownerPayrollTrend;

  /// No description provided for @ownerPerEmployee.
  ///
  /// In en, this message translates to:
  /// **'Average per employee'**
  String get ownerPerEmployee;

  /// No description provided for @ownerByDepartment.
  ///
  /// In en, this message translates to:
  /// **'By department'**
  String get ownerByDepartment;

  /// No description provided for @ownerLakh.
  ///
  /// In en, this message translates to:
  /// **'lakh'**
  String get ownerLakh;

  /// No description provided for @ownerCrore.
  ///
  /// In en, this message translates to:
  /// **'crore'**
  String get ownerCrore;

  /// No description provided for @ownerWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a decision'**
  String get ownerWaiting;

  /// No description provided for @ownerNoWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting for a decision.'**
  String get ownerNoWaiting;

  /// No description provided for @ownerNoPeople.
  ///
  /// In en, this message translates to:
  /// **'No one matches.'**
  String get ownerNoPeople;

  /// No description provided for @ownerDemoBanner.
  ///
  /// In en, this message translates to:
  /// **'Demo company of {count} people, so the charts have something to show. Real numbers arrive with the backend.'**
  String ownerDemoBanner(int count);

  /// No description provided for @ownerPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan {plan}'**
  String ownerPlan(int plan);

  /// No description provided for @ownerJoinedLeft.
  ///
  /// In en, this message translates to:
  /// **'Joined {joined} · Left {left} in 30 days'**
  String ownerJoinedLeft(int joined, int left);

  /// No description provided for @ownerAttBehind.
  ///
  /// In en, this message translates to:
  /// **'{name} is behind on progress (score {score})'**
  String ownerAttBehind(String name, int score);

  /// No description provided for @ownerAttAttrition.
  ///
  /// In en, this message translates to:
  /// **'{name}: {percent}% of people left in the last year'**
  String ownerAttAttrition(String name, int percent);

  /// No description provided for @ownerAttShort.
  ///
  /// In en, this message translates to:
  /// **'{name} is {count} people short of its plan'**
  String ownerAttShort(String name, int count);

  /// No description provided for @ownerAttAttendance.
  ///
  /// In en, this message translates to:
  /// **'{name} attendance is {percent}%'**
  String ownerAttAttendance(String name, int percent);

  /// No description provided for @ownerAttRequests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 request has waited over 3 days} other{{count} requests have waited over 3 days}}'**
  String ownerAttRequests(int count);

  /// No description provided for @ownerHeadcountOfPlan.
  ///
  /// In en, this message translates to:
  /// **'{count} of {plan} planned'**
  String ownerHeadcountOfPlan(int count, int plan);

  /// No description provided for @ownerFewPeople.
  ///
  /// In en, this message translates to:
  /// **'Fewer than {min} people'**
  String ownerFewPeople(int min);

  /// No description provided for @ownerFormulaBody.
  ///
  /// In en, this message translates to:
  /// **'Each department scores 0 to 100: {goals}% goals on track + {reviews}% reviews completed + {training}% training completed + {attendance}% attendance.\n\n75 and above is on track, 60 to 74 needs watching, below 60 is behind.\n\nGroups of fewer than {min} people are not shown, so nobody can be identified.'**
  String ownerFormulaBody(
    int goals,
    int reviews,
    int training,
    int attendance,
    int min,
  );

  /// No description provided for @ownerAttritionValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of the team'**
  String ownerAttritionValue(int percent);

  /// No description provided for @ownerJoinedLast90.
  ///
  /// In en, this message translates to:
  /// **'Joined in the last 90 days: {count}'**
  String ownerJoinedLast90(int count);

  /// No description provided for @ownerTenure.
  ///
  /// In en, this message translates to:
  /// **'{years}y {months}m'**
  String ownerTenure(int years, int months);

  /// No description provided for @ownerDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String ownerDays(String days);

  /// No description provided for @ownerShowPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Show {name}\'s pay?'**
  String ownerShowPayTitle(String name);

  /// No description provided for @ownerVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{change} vs last month'**
  String ownerVsLastMonth(String change);

  /// No description provided for @ownerWaitingDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{under a day} =1{1 day} other{{count} days}}'**
  String ownerWaitingDays(int count);

  /// No description provided for @hrAuditGroupPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get hrAuditGroupPeople;

  /// No description provided for @hrAuditGroupCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get hrAuditGroupCompany;

  /// No description provided for @hrExportAudit.
  ///
  /// In en, this message translates to:
  /// **'Copy audit log as CSV'**
  String get hrExportAudit;

  /// No description provided for @hrReviewDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Q{quarter} {year} review'**
  String hrReviewDefaultName(int quarter, String year);

  /// No description provided for @hrReviewProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} completed'**
  String hrReviewProgress(int done, int total);

  /// No description provided for @hrReviewStartHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Starts a review for the 1 active employee.} other{Starts a review for all {count} active employees.}}'**
  String hrReviewStartHint(int count);

  /// No description provided for @hrJobSummary.
  ///
  /// In en, this message translates to:
  /// **'{active, plural, =1{1 applicant} other{{active} applicants}} · {openings, plural, =1{1 opening} other{{openings} openings}}'**
  String hrJobSummary(int active, int openings);

  /// No description provided for @hrDirectReports.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 direct report} other{{count} direct reports}}'**
  String hrDirectReports(int count);

  /// No description provided for @hrTasksDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String hrTasksDone(int done, int total);

  /// No description provided for @hrImportAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No employees added.} =1{Added 1 employee.} other{Added {count} employees.}}'**
  String hrImportAdded(int count);

  /// No description provided for @hrImportSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row was skipped:} other{{count} rows were skipped:}}'**
  String hrImportSkipped(int count);

  /// No description provided for @hrImportLine.
  ///
  /// In en, this message translates to:
  /// **'Line {line}: {reason}'**
  String hrImportLine(int line, String reason);

  /// No description provided for @a11yPreviousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get a11yPreviousDay;

  /// No description provided for @a11yNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get a11yNextDay;

  /// No description provided for @hrAttCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'In {time}'**
  String hrAttCheckedIn(String time);

  /// No description provided for @hrAttRate.
  ///
  /// In en, this message translates to:
  /// **'{percent}% came to work'**
  String hrAttRate(int percent);

  /// No description provided for @hrDocExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String hrDocExpiresIn(int days);

  /// No description provided for @hrRemoveDocTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\"?'**
  String hrRemoveDocTitle(String title);

  /// No description provided for @hrActionDocs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 document expiring soon} other{{count} documents expiring soon}}'**
  String hrActionDocs(int count);

  /// No description provided for @hrCsvCopiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get hrCsvCopiedTitle;

  /// No description provided for @hrCsvCopied.
  ///
  /// In en, this message translates to:
  /// **'Paste it into a spreadsheet.'**
  String get hrCsvCopied;

  /// No description provided for @hrPaySsf.
  ///
  /// In en, this message translates to:
  /// **'Social security (SSF)'**
  String get hrPaySsf;

  /// No description provided for @hrPayCit.
  ///
  /// In en, this message translates to:
  /// **'CIT contribution'**
  String get hrPayCit;

  /// No description provided for @hrPayInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance premium'**
  String get hrPayInsurance;

  /// No description provided for @hrPayTax.
  ///
  /// In en, this message translates to:
  /// **'Income tax (TDS)'**
  String get hrPayTax;

  /// No description provided for @hrPayPlaceholderNote.
  ///
  /// In en, this message translates to:
  /// **'Tax and SSF figures use placeholder rules. Have finance verify them before running real payroll.'**
  String get hrPayPlaceholderNote;

  /// No description provided for @hrNoActiveStaff.
  ///
  /// In en, this message translates to:
  /// **'There are no active employees to pay for this month.'**
  String get hrNoActiveStaff;

  /// No description provided for @hrPayNotRun.
  ///
  /// In en, this message translates to:
  /// **'Payroll for {month} hasn\'t been run yet.'**
  String hrPayNotRun(String month);

  /// No description provided for @hrApprovePayrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve payroll for {month}?'**
  String hrApprovePayrollTitle(String month);

  /// No description provided for @hrMarkPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark {month} payroll as paid?'**
  String hrMarkPaidTitle(String month);

  /// No description provided for @hrPayLineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gross {gross} · Tax {tax}'**
  String hrPayLineSubtitle(String gross, String tax);

  /// No description provided for @hrActionPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll for {month} isn\'t approved yet'**
  String hrActionPayroll(String month);

  /// No description provided for @hrNewNotice.
  ///
  /// In en, this message translates to:
  /// **'New notice'**
  String get hrNewNotice;

  /// No description provided for @hrNoticeTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get hrNoticeTitleField;

  /// No description provided for @hrNoticeCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get hrNoticeCategory;

  /// No description provided for @hrNoticeBodyField.
  ///
  /// In en, this message translates to:
  /// **'Write the notice here'**
  String get hrNoticeBodyField;

  /// No description provided for @hrPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get hrPublish;

  /// No description provided for @hrNoNotices.
  ///
  /// In en, this message translates to:
  /// **'No notices yet.'**
  String get hrNoNotices;

  /// No description provided for @hrNoticeNeedsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for the notice.'**
  String get hrNoticeNeedsTitle;

  /// No description provided for @hrNoticeNeedsBody.
  ///
  /// In en, this message translates to:
  /// **'Write the text of the notice.'**
  String get hrNoticeNeedsBody;

  /// No description provided for @hrDeleteNotice.
  ///
  /// In en, this message translates to:
  /// **'Delete notice'**
  String get hrDeleteNotice;

  /// No description provided for @hrDeleteNoticeMessage.
  ///
  /// In en, this message translates to:
  /// **'Employees will no longer see it.'**
  String get hrDeleteNoticeMessage;

  /// No description provided for @hrDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get hrDeleteAction;

  /// No description provided for @hrNoticesFooter.
  ///
  /// In en, this message translates to:
  /// **'Published notices appear in every employee\'s Notices.'**
  String get hrNoticesFooter;

  /// No description provided for @hrCatGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get hrCatGeneral;

  /// No description provided for @hrCatUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get hrCatUrgent;

  /// No description provided for @hrCatPolicy.
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get hrCatPolicy;

  /// No description provided for @hrCatHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get hrCatHoliday;

  /// No description provided for @hrDeleteNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String hrDeleteNoticeTitle(String title);

  /// No description provided for @hrReportsHeadcount.
  ///
  /// In en, this message translates to:
  /// **'Headcount'**
  String get hrReportsHeadcount;

  /// No description provided for @hrReportsByDepartment.
  ///
  /// In en, this message translates to:
  /// **'By department'**
  String get hrReportsByDepartment;

  /// No description provided for @hrReportsByType.
  ///
  /// In en, this message translates to:
  /// **'By employment type'**
  String get hrReportsByType;

  /// No description provided for @hrReportsRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get hrReportsRequests;

  /// No description provided for @hrReportsPayroll.
  ///
  /// In en, this message translates to:
  /// **'Latest payroll'**
  String get hrReportsPayroll;

  /// No description provided for @hrReportsNoPayroll.
  ///
  /// In en, this message translates to:
  /// **'No payroll has been run yet.'**
  String get hrReportsNoPayroll;

  /// No description provided for @hrReportsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get hrReportsExport;

  /// No description provided for @hrExportEmployees.
  ///
  /// In en, this message translates to:
  /// **'Copy employee list as CSV'**
  String get hrExportEmployees;

  /// No description provided for @hrReportsActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get hrReportsActivity;

  /// No description provided for @hrNoActivity.
  ///
  /// In en, this message translates to:
  /// **'Nothing has happened yet.'**
  String get hrNoActivity;

  /// No description provided for @hrAuditEmployeeAdded.
  ///
  /// In en, this message translates to:
  /// **'Employee added'**
  String get hrAuditEmployeeAdded;

  /// No description provided for @hrAuditEmployeeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Employee updated'**
  String get hrAuditEmployeeUpdated;

  /// No description provided for @hrAuditEmployeeDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Employee deactivated'**
  String get hrAuditEmployeeDeactivated;

  /// No description provided for @hrAuditEmployeeReactivated.
  ///
  /// In en, this message translates to:
  /// **'Employee reactivated'**
  String get hrAuditEmployeeReactivated;

  /// No description provided for @hrAuditRequestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved'**
  String get hrAuditRequestApproved;

  /// No description provided for @hrAuditRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get hrAuditRequestRejected;

  /// No description provided for @hrAuditPayrollRun.
  ///
  /// In en, this message translates to:
  /// **'Payroll calculated'**
  String get hrAuditPayrollRun;

  /// No description provided for @hrAuditPayrollApproved.
  ///
  /// In en, this message translates to:
  /// **'Payroll approved'**
  String get hrAuditPayrollApproved;

  /// No description provided for @hrAuditPayrollPaid.
  ///
  /// In en, this message translates to:
  /// **'Payroll marked as paid'**
  String get hrAuditPayrollPaid;

  /// No description provided for @hrAuditNoticePublished.
  ///
  /// In en, this message translates to:
  /// **'Notice published'**
  String get hrAuditNoticePublished;

  /// No description provided for @hrAuditNoticeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notice deleted'**
  String get hrAuditNoticeDeleted;

  /// No description provided for @hrAuditHolidayAdded.
  ///
  /// In en, this message translates to:
  /// **'Company holiday added'**
  String get hrAuditHolidayAdded;

  /// No description provided for @hrAuditHolidayRemoved.
  ///
  /// In en, this message translates to:
  /// **'Company holiday removed'**
  String get hrAuditHolidayRemoved;

  /// No description provided for @hrAuditLine.
  ///
  /// In en, this message translates to:
  /// **'{actor}: {detail}'**
  String hrAuditLine(String actor, String detail);

  /// No description provided for @hrAllClear.
  ///
  /// In en, this message translates to:
  /// **'Nothing needs your action.'**
  String get hrAllClear;

  /// No description provided for @hrWaitingForYou.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing is waiting for you} =1{1 request is waiting for you} other{{count} requests are waiting for you}}'**
  String hrWaitingForYou(int count);

  /// No description provided for @hrActionApprovals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 request to review} other{{count} requests to review}}'**
  String hrActionApprovals(int count);

  /// No description provided for @hrRejectMessage.
  ///
  /// In en, this message translates to:
  /// **'The request from {name} will be marked as rejected. This can\'t be changed afterwards.'**
  String hrRejectMessage(String name);

  /// No description provided for @hrPolicyDaysPerYear.
  ///
  /// In en, this message translates to:
  /// **'{days} days a year'**
  String hrPolicyDaysPerYear(String days);

  /// No description provided for @hrPolicyAccrual.
  ///
  /// In en, this message translates to:
  /// **'1 day for every {days} days worked'**
  String hrPolicyAccrual(String days);

  /// No description provided for @hrPolicyCarryUpTo.
  ///
  /// In en, this message translates to:
  /// **'Carries forward up to {days} days'**
  String hrPolicyCarryUpTo(String days);

  /// No description provided for @hrPolicyDocument.
  ///
  /// In en, this message translates to:
  /// **'Document needed after {days} days'**
  String hrPolicyDocument(String days);

  /// No description provided for @hrRemoveHolidayTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String hrRemoveHolidayTitle(String name);

  /// No description provided for @hrEmployeeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 employee} other{{count} employees}}'**
  String hrEmployeeCount(int count);

  /// No description provided for @hrDeactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {name}?'**
  String hrDeactivateTitle(String name);

  /// No description provided for @hrReactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivate {name}?'**
  String hrReactivateTitle(String name);

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

  /// No description provided for @hrNewJoiners.
  ///
  /// In en, this message translates to:
  /// **'New joiners (last 30 days)'**
  String get hrNewJoiners;

  /// No description provided for @hrNoNewJoiners.
  ///
  /// In en, this message translates to:
  /// **'Nobody has joined in the last 30 days.'**
  String get hrNoNewJoiners;
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

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
  String get tabMore => 'More';

  @override
  String get moreApps => 'Apps';

  @override
  String get moreAppsSubtitle => 'All your tools in one place';

  @override
  String get moreProfile => 'Profile';

  @override
  String get myInfoTitle => 'My Info';

  @override
  String get infoTabJob => 'Job';

  @override
  String get infoTabContact => 'Contact';

  @override
  String get infoTabPay => 'Pay';

  @override
  String get infoTabDocs => 'Docs';

  @override
  String get infoTabEmergency => 'Emergency';

  @override
  String staffIdValue(String id) {
    return 'Staff ID $id';
  }

  @override
  String get jobTitleLabel => 'Job title';

  @override
  String get departmentLabel => 'Department';

  @override
  String get managerLabel => 'Manager';

  @override
  String get joinedLabel => 'Joined';

  @override
  String get employmentTypeLabel => 'Employment type';

  @override
  String get workLocationLabel => 'Work location';

  @override
  String get workEmailLabel => 'Work email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get editAction => 'Edit';

  @override
  String pendingHrApproval(String phone) {
    return 'Pending HR approval: $phone';
  }

  @override
  String get basicSalaryLabel => 'Basic salary';

  @override
  String get dearnessAllowanceLabel => 'Dearness allowance';

  @override
  String get transportAllowanceLabel => 'Transport allowance';

  @override
  String get grossMonthlyLabel => 'Gross per month';

  @override
  String get payslipsLabel => 'Payslips';

  @override
  String get taxPlannerLabel => 'Tax planner';

  @override
  String get salaryCertificateLabel => 'Salary certificate';

  @override
  String get manageDocuments => 'Manage documents';

  @override
  String get noDocuments => 'No documents yet.';

  @override
  String get emergencyContactsLabel => 'Emergency contacts';

  @override
  String get healthInsuranceLabel => 'Health insurance';

  @override
  String get manageEmergency => 'Manage contacts & insurance';

  @override
  String get tabTimeOff => 'Time Off';

  @override
  String get requestTimeOff => 'Request time off';

  @override
  String daysLeft(String days) {
    return '$days days left';
  }

  @override
  String get planTrip => 'Plan a trip';

  @override
  String get planTripSubtitle => 'Find bridge days around holidays';

  @override
  String get holidayCalendarLabel => 'Holiday calendar';

  @override
  String get allBalances => 'All balances';

  @override
  String get myTimeOffRequests => 'My time-off requests';

  @override
  String get noTimeOffRequests => 'No time off requested yet.';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusPaid => 'Paid';

  @override
  String get tabRequests => 'Requests';

  @override
  String get filterAll => 'All';

  @override
  String get filterOpen => 'Open';

  @override
  String get filterClosed => 'Closed';

  @override
  String get newRequest => 'New request';

  @override
  String get requestTypeLeave => 'Time off';

  @override
  String get requestTypeExpense => 'Expense claim';

  @override
  String get requestTypeOvertime => 'Overtime';

  @override
  String get requestTypeHr => 'HR request';

  @override
  String get noRequests => 'Nothing here. You\'re all caught up.';

  @override
  String get whatsHappening => 'What\'s happening';

  @override
  String feedOut(String name) {
    return '$name is out';
  }

  @override
  String feedBirthday(String name) {
    return '$name\'s birthday';
  }

  @override
  String feedAnniversary(String name, int years) {
    return '$name: $years years at KarmaHR';
  }

  @override
  String get feedToday => 'Today';

  @override
  String get feedTomorrow => 'Tomorrow';

  @override
  String get feedNothing => 'Nothing happening this week.';

  @override
  String get a11ySearch => 'Search';

  @override
  String get a11yAddDocument => 'Add document';

  @override
  String get a11yNewExpenseClaim => 'New expense claim';

  @override
  String get a11yAddGoal => 'Add goal';

  @override
  String get a11yGiveKudos => 'Give kudos';

  @override
  String get a11yPostComment => 'Post comment';

  @override
  String get a11yRemoveContact => 'Remove contact';

  @override
  String get a11yPreviousMonth => 'Previous month';

  @override
  String get a11yNextMonth => 'Next month';

  @override
  String get a11yShowPassword => 'Show password';

  @override
  String get a11yHidePassword => 'Hide password';

  @override
  String get a11yShareSlip => 'Share payslip';

  @override
  String get a11yFewerHours => 'Fewer hours';

  @override
  String get a11yMoreHours => 'More hours';

  @override
  String get a11yNotifications => 'Notifications';

  @override
  String a11yNotificationsUnread(int count) {
    return 'Notifications, $count unread';
  }

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
  String get hrTabMore => 'More';

  @override
  String get hrPeopleEvents => 'Birthdays & work anniversaries';

  @override
  String get hrNoPeopleEvents =>
      'No birthdays or anniversaries in the next 30 days.';

  @override
  String get hrBirthday => 'Birthday';

  @override
  String hrAnniversary(int years) {
    return '$years-year work anniversary';
  }

  @override
  String get hrSectionOverview => 'Overview';

  @override
  String get hrSectionEmployees => 'Employees';

  @override
  String get hrSectionLeave => 'Leave & Holidays';

  @override
  String get hrSectionPayroll => 'Payroll';

  @override
  String get hrSectionNotices => 'Notices';

  @override
  String get hrSectionReports => 'Reports';

  @override
  String get hrStatEmployees => 'Employees';

  @override
  String get hrStatDepartments => 'Departments';

  @override
  String get hrStatOutToday => 'Out today';

  @override
  String get hrByDepartment => 'Employees by department';

  @override
  String get hrNobodyOut => 'Nobody is on leave today.';

  @override
  String get hrDemoDataNote =>
      'Demo data. Real numbers arrive when the backend is connected.';

  @override
  String get hrSearchEmployees => 'Search by name, role or department';

  @override
  String get hrAddEmployee => 'Add employee';

  @override
  String get hrFilterActive => 'Active';

  @override
  String get hrFilterInactive => 'Inactive';

  @override
  String get hrNoEmployeesFound => 'No employees match.';

  @override
  String get hrEmployeeTitle => 'Employee';

  @override
  String get hrNoManager => 'No manager';

  @override
  String get hrFilingStatus => 'Tax filing';

  @override
  String get hrFilingSingle => 'Single';

  @override
  String get hrFilingMarried => 'Married';

  @override
  String get hrDeactivate => 'Deactivate employee';

  @override
  String get hrReactivate => 'Reactivate employee';

  @override
  String get hrDeactivateAction => 'Deactivate';

  @override
  String get hrReactivateAction => 'Reactivate';

  @override
  String get hrDeactivateMessage =>
      'They will no longer appear in the directory or in payroll. Their records are kept.';

  @override
  String get hrReactivateMessage =>
      'They will appear in the directory and in payroll again.';

  @override
  String get hrNewEmployee => 'New employee';

  @override
  String get hrEditEmployee => 'Edit employee';

  @override
  String get save => 'Save';

  @override
  String get hrFieldName => 'Full name';

  @override
  String get hrCheckDetails => 'Check the details';

  @override
  String get hrErrName => 'Enter the employee\'s full name.';

  @override
  String get hrErrJob => 'Enter a job title and a department.';

  @override
  String get hrErrEmail => 'Enter a valid email address.';

  @override
  String get hrErrPhone =>
      'Enter a 10-digit mobile number starting with 96, 97 or 98 (optionally with +977).';

  @override
  String get hrErrSalary => 'Enter a basic salary above zero.';

  @override
  String get hrApprovalsTab => 'Approvals';

  @override
  String get hrPolicyTab => 'Policy';

  @override
  String get hrHolidaysTab => 'Holidays';

  @override
  String get hrApprove => 'Approve';

  @override
  String get hrReject => 'Reject';

  @override
  String get hrRejectTitle => 'Reject this request?';

  @override
  String get hrDecided => 'Decided';

  @override
  String get hrPolicyNoCarry => 'Does not carry forward';

  @override
  String get hrPolicyCarryAll => 'Carries forward without limit';

  @override
  String get hrPolicyPaid => 'Paid';

  @override
  String get hrPolicyUnpaid => 'Unpaid';

  @override
  String get hrPolicyNote =>
      'These figures are placeholders until HR and legal sign them off. Editing policy arrives with the backend.';

  @override
  String get hrCompanyHolidays => 'Company holidays';

  @override
  String get hrPublicHolidays => 'Upcoming public holidays';

  @override
  String get hrAddHoliday => 'Add company holiday';

  @override
  String get hrHolidayName => 'Holiday name';

  @override
  String get hrHolidayDate => 'Date';

  @override
  String get hrNoCompanyHolidays => 'No company holidays yet.';

  @override
  String get hrNoPublicHolidays =>
      'No upcoming public holidays in the calendar.';

  @override
  String get hrHolidayNeedsName => 'Enter a name for the holiday.';

  @override
  String get hrRemoveHoliday => 'Remove holiday';

  @override
  String get hrRemoveAction => 'Remove';

  @override
  String get hrHolidayNote =>
      'Public holidays come from the government calendar. Company holidays you add here are HR\'s record; the employee calendar picks them up once the backend is connected.';

  @override
  String get hrNeedsAction => 'Needs your action';

  @override
  String get hrPayPeriod => 'Pay period';

  @override
  String get hrRunPayroll => 'Run payroll';

  @override
  String get hrRecalculate => 'Recalculate';

  @override
  String get hrApprovePayroll => 'Approve payroll';

  @override
  String get hrApprovePayrollMessage =>
      'Once approved, the figures are frozen: later changes to employee records won\'t alter this payroll.';

  @override
  String get hrMarkPaid => 'Mark as paid';

  @override
  String get hrMarkPaidMessage => 'Do this after the bank transfer is done.';

  @override
  String get hrPayrollDraft => 'Draft';

  @override
  String get hrPayGross => 'Gross';

  @override
  String get hrPayDeductions => 'Deductions';

  @override
  String get hrPayNet => 'Net pay';

  @override
  String get hrExportRegister => 'Payroll register (CSV)';

  @override
  String get hrExportBank => 'Bank transfer file (CSV)';

  @override
  String get hrExportTds => 'TDS report (CSV)';

  @override
  String get hrExportSsf => 'SSF contribution report (CSV)';

  @override
  String get hrSharePayslip => 'Share payslip (PDF)';

  @override
  String get hrBankNeedsApproval =>
      'Approve the payroll first to export the bank file.';

  @override
  String get hrBankName => 'Bank';

  @override
  String get hrAccountNumber => 'Account number';

  @override
  String get hrErrAccount => 'Account numbers contain digits only.';

  @override
  String hrBankMissing(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count employees have no bank account on file and are left out of the bank file: $names',
      one:
          '1 employee has no bank account on file and is left out of the bank file: $names',
    );
    return '$_temp0';
  }

  @override
  String get hrLetters => 'Letters';

  @override
  String get hrLettersFooter => 'Made as PDFs for you to sign and share.';

  @override
  String get hrLetterAppointment => 'Appointment letter';

  @override
  String get hrLetterExperience => 'Experience letter';

  @override
  String get hrAddDocument => 'Add document';

  @override
  String get hrDocName => 'Document name';

  @override
  String get hrDocType => 'Type';

  @override
  String get hrDocExpires => 'Expires';

  @override
  String get hrDocNoExpiry => 'No expiry';

  @override
  String get hrDocExpired => 'Expired';

  @override
  String get hrNoDocs => 'No documents on file.';

  @override
  String get hrDocNeedsName => 'Enter a name for the document.';

  @override
  String get hrRemoveDoc => 'Remove document';

  @override
  String get hrReportsDocs => 'Documents expiring soon';

  @override
  String get hrNoExpiringDocs => 'No documents expire in the next 30 days.';

  @override
  String get hrDocContract => 'Employment contract';

  @override
  String get hrDocCitizenship => 'Citizenship certificate';

  @override
  String get hrDocPan => 'PAN card';

  @override
  String get hrDocPermit => 'Work permit';

  @override
  String get hrDocCertificate => 'Certificate';

  @override
  String get hrDocOther => 'Other';

  @override
  String get hrAuditDocumentAdded => 'Document added';

  @override
  String get hrAuditDocumentRemoved => 'Document removed';

  @override
  String get hrSectionAttendance => 'Attendance';

  @override
  String get hrSectionReviews => 'Reviews';

  @override
  String get hrSectionHiring => 'Hiring';

  @override
  String get hrAttPresent => 'Present';

  @override
  String get hrAttLate => 'Late';

  @override
  String get hrAttAbsent => 'Absent';

  @override
  String get hrAttOnLeave => 'On leave';

  @override
  String get hrAttWeeklyOff => 'Weekly holiday. Nobody is expected at work.';

  @override
  String get hrAttNoRecords => 'No records for this day.';

  @override
  String get hrReviewStart => 'Start review cycle';

  @override
  String get hrReviewName => 'Cycle name';

  @override
  String get hrReviewNeedsName => 'Enter a name for the review cycle.';

  @override
  String get hrReviewNoCycles => 'No review cycles yet.';

  @override
  String get hrReviewAdvance => 'Next step';

  @override
  String get hrStageNotStarted => 'Not started';

  @override
  String get hrStageSelf => 'Self review done';

  @override
  String get hrStageManager => 'Manager review done';

  @override
  String get hrStageCompleted => 'Completed';

  @override
  String get hrAuditReviewStarted => 'Review cycle started';

  @override
  String get hrJobNew => 'New job';

  @override
  String get hrJobOpenings => 'Openings';

  @override
  String get hrJobOpen => 'Open';

  @override
  String get hrJobClosed => 'Closed';

  @override
  String get hrJobClose => 'Close job';

  @override
  String get hrJobReopen => 'Reopen job';

  @override
  String get hrNoJobs => 'No jobs yet.';

  @override
  String get hrJobNeedsDetails =>
      'Enter a job title, a department and at least one opening.';

  @override
  String get hrApplicants => 'Applicants';

  @override
  String get hrAddApplicant => 'Add applicant';

  @override
  String get hrApplicantName => 'Applicant name';

  @override
  String get hrApplicantEmail => 'Email (optional)';

  @override
  String get hrApplicantNeedsName => 'Enter the applicant\'s name.';

  @override
  String get hrNoApplicants => 'No applicants yet.';

  @override
  String get hrApplicantAdvance => 'Next stage';

  @override
  String get hrAddAsEmployee => 'Add as employee';

  @override
  String get hrAppApplied => 'Applied';

  @override
  String get hrAppScreening => 'Screening';

  @override
  String get hrAppInterview => 'Interview';

  @override
  String get hrAppOffer => 'Offer';

  @override
  String get hrAppHired => 'Hired';

  @override
  String get hrAuditJobPosted => 'Job posted';

  @override
  String get hrAuditApplicantHired => 'Applicant hired';

  @override
  String get hrShowOrgChart => 'Show org chart';

  @override
  String get hrShowList => 'Show list';

  @override
  String get hrTabTasks => 'Tasks';

  @override
  String get hrOnboarding => 'Onboarding';

  @override
  String get hrOffboarding => 'Offboarding';

  @override
  String get hrTaskCollectDocs => 'Collect documents';

  @override
  String get hrTaskCreateAccounts => 'Create accounts and email';

  @override
  String get hrTaskIssueEquipment => 'Issue laptop and equipment';

  @override
  String get hrTaskInduction => 'Hold induction session';

  @override
  String get hrTaskIntroduceTeam => 'Introduce the team';

  @override
  String get hrTaskExitInterview => 'Exit interview';

  @override
  String get hrTaskReturnAssets => 'Collect laptop and ID card';

  @override
  String get hrTaskFinalSettlement => 'Final salary settlement';

  @override
  String get hrTaskDisableAccounts => 'Disable accounts';

  @override
  String get hrTaskExperienceLetter => 'Issue experience letter';

  @override
  String get hrImportEmployees => 'Import from CSV';

  @override
  String get hrImportHint =>
      'One person per line: Name, Job title, Department, Email, Phone, Basic salary, Dearness allowance, Transport allowance';

  @override
  String get hrImportAction => 'Import';

  @override
  String get hrImportNothing => 'There is nothing to import.';

  @override
  String get hrImportBadColumns => 'needs 8 columns';

  @override
  String get hrImportResult => 'Import finished';

  @override
  String get hrAuditEmployeesImported => 'Employees imported';

  @override
  String get roleOwner => 'CEO';

  @override
  String get ownerSecOverview => 'Overview';

  @override
  String get ownerSecDepartments => 'Departments';

  @override
  String get ownerSecPeople => 'People';

  @override
  String get ownerSecMoney => 'Money';

  @override
  String get ownerSecActivity => 'Activity';

  @override
  String get ownerKpiHeadcount => 'Headcount';

  @override
  String get ownerKpiProgress => 'Progress score';

  @override
  String get ownerKpiAttendance => 'Attendance';

  @override
  String get ownerKpiPayroll => 'Payroll this month';

  @override
  String get ownerKpiAttrition => 'Left in the last year';

  @override
  String get ownerNeedsAttention => 'Needs attention';

  @override
  String get ownerAllGood => 'Nothing needs attention right now.';

  @override
  String get ownerDeptProgress => 'Department progress';

  @override
  String get ownerSeeAll => 'See all';

  @override
  String get ownerLowestFirst => 'Lowest score first';

  @override
  String get ownerStatusOnTrack => 'On track';

  @override
  String get ownerStatusWatch => 'Watch';

  @override
  String get ownerStatusBehind => 'Behind';

  @override
  String get ownerHowCalculated => 'How is progress calculated?';

  @override
  String get ownerMetricGoals => 'Goals on track';

  @override
  String get ownerMetricReviews => 'Reviews completed';

  @override
  String get ownerMetricTraining => 'Training completed';

  @override
  String get ownerTrend12 => 'Headcount, last 12 months';

  @override
  String get ownerByBranch => 'By branch';

  @override
  String get ownerViewPeople => 'See the people';

  @override
  String get ownerSearchPeople => 'Search by name or role';

  @override
  String get ownerAllDepartments => 'All departments';

  @override
  String get ownerAllBranches => 'All branches';

  @override
  String get ownerDepartmentLabel => 'Department';

  @override
  String get ownerBranchLabel => 'Branch';

  @override
  String get ownerAttendance30 => 'Attendance, last 30 days';

  @override
  String get ownerGoalsThisQuarter => 'Goals this quarter';

  @override
  String get ownerReviewLabel => 'Performance review';

  @override
  String get ownerReviewDone => 'Done';

  @override
  String get ownerReviewPending => 'Not done';

  @override
  String get ownerTrainingLabel => 'Training';

  @override
  String get ownerLeaveBalance => 'Leave balance';

  @override
  String get ownerPay => 'Monthly pay';

  @override
  String get ownerShowPay => 'Show pay';

  @override
  String get ownerHidePay => 'Hide pay';

  @override
  String get ownerPayHidden => 'Hidden';

  @override
  String get ownerShowPayMessage =>
      'Viewing someone\'s pay is recorded in the audit log.';

  @override
  String get hrAuditPayViewed => 'Pay viewed';

  @override
  String get ownerPayrollTrend => 'Payroll, last 12 months';

  @override
  String get ownerPerEmployee => 'Average per employee';

  @override
  String get ownerByDepartment => 'By department';

  @override
  String get ownerLakh => 'lakh';

  @override
  String get ownerCrore => 'crore';

  @override
  String get ownerWaiting => 'Waiting for a decision';

  @override
  String get ownerNoWaiting => 'Nothing is waiting for a decision.';

  @override
  String get ownerNoPeople => 'No one matches.';

  @override
  String ownerDemoBanner(int count) {
    return 'Demo company of $count people, so the charts have something to show. Real numbers arrive with the backend.';
  }

  @override
  String ownerPlan(int plan) {
    return 'Plan $plan';
  }

  @override
  String ownerJoinedLeft(int joined, int left) {
    return 'Joined $joined · Left $left in 30 days';
  }

  @override
  String ownerAttBehind(String name, int score) {
    return '$name is behind on progress (score $score)';
  }

  @override
  String ownerAttAttrition(String name, int percent) {
    return '$name: $percent% of people left in the last year';
  }

  @override
  String ownerAttShort(String name, int count) {
    return '$name is $count people short of its plan';
  }

  @override
  String ownerAttAttendance(String name, int percent) {
    return '$name attendance is $percent%';
  }

  @override
  String ownerAttRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests have waited over 3 days',
      one: '1 request has waited over 3 days',
    );
    return '$_temp0';
  }

  @override
  String ownerHeadcountOfPlan(int count, int plan) {
    return '$count of $plan planned';
  }

  @override
  String ownerFewPeople(int min) {
    return 'Fewer than $min people';
  }

  @override
  String ownerFormulaBody(
    int goals,
    int reviews,
    int training,
    int attendance,
    int min,
  ) {
    return 'Each department scores 0 to 100: $goals% goals on track + $reviews% reviews completed + $training% training completed + $attendance% attendance.\n\n75 and above is on track, 60 to 74 needs watching, below 60 is behind.\n\nGroups of fewer than $min people are not shown, so nobody can be identified.';
  }

  @override
  String ownerAttritionValue(int percent) {
    return '$percent% of the team';
  }

  @override
  String ownerJoinedLast90(int count) {
    return 'Joined in the last 90 days: $count';
  }

  @override
  String ownerTenure(int years, int months) {
    return '${years}y ${months}m';
  }

  @override
  String ownerDays(String days) {
    return '$days days';
  }

  @override
  String ownerShowPayTitle(String name) {
    return 'Show $name\'s pay?';
  }

  @override
  String ownerVsLastMonth(String change) {
    return '$change vs last month';
  }

  @override
  String ownerWaitingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'under a day',
    );
    return '$_temp0';
  }

  @override
  String get hrAuditGroupPeople => 'People';

  @override
  String get hrAuditGroupCompany => 'Company';

  @override
  String get hrExportAudit => 'Copy audit log as CSV';

  @override
  String hrReviewDefaultName(int quarter, String year) {
    return 'Q$quarter $year review';
  }

  @override
  String hrReviewProgress(int done, int total) {
    return '$done of $total completed';
  }

  @override
  String hrReviewStartHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Starts a review for all $count active employees.',
      one: 'Starts a review for the 1 active employee.',
    );
    return '$_temp0';
  }

  @override
  String hrJobSummary(int active, int openings) {
    String _temp0 = intl.Intl.pluralLogic(
      active,
      locale: localeName,
      other: '$active applicants',
      one: '1 applicant',
    );
    String _temp1 = intl.Intl.pluralLogic(
      openings,
      locale: localeName,
      other: '$openings openings',
      one: '1 opening',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String hrDirectReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count direct reports',
      one: '1 direct report',
    );
    return '$_temp0';
  }

  @override
  String hrTasksDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String hrImportAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count employees.',
      one: 'Added 1 employee.',
      zero: 'No employees added.',
    );
    return '$_temp0';
  }

  @override
  String hrImportSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows were skipped:',
      one: '1 row was skipped:',
    );
    return '$_temp0';
  }

  @override
  String hrImportLine(int line, String reason) {
    return 'Line $line: $reason';
  }

  @override
  String get a11yPreviousDay => 'Previous day';

  @override
  String get a11yNextDay => 'Next day';

  @override
  String hrAttCheckedIn(String time) {
    return 'In $time';
  }

  @override
  String hrAttRate(int percent) {
    return '$percent% came to work';
  }

  @override
  String hrDocExpiresIn(int days) {
    return 'Expires in $days days';
  }

  @override
  String hrRemoveDocTitle(String title) {
    return 'Remove \"$title\"?';
  }

  @override
  String hrActionDocs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents expiring soon',
      one: '1 document expiring soon',
    );
    return '$_temp0';
  }

  @override
  String get hrCsvCopiedTitle => 'Copied';

  @override
  String get hrCsvCopied => 'Paste it into a spreadsheet.';

  @override
  String get hrPaySsf => 'Social security (SSF)';

  @override
  String get hrPayCit => 'CIT contribution';

  @override
  String get hrPayInsurance => 'Insurance premium';

  @override
  String get hrPayTax => 'Income tax (TDS)';

  @override
  String get hrPayPlaceholderNote =>
      'Tax and SSF figures use placeholder rules. Have finance verify them before running real payroll.';

  @override
  String get hrNoActiveStaff =>
      'There are no active employees to pay for this month.';

  @override
  String hrPayNotRun(String month) {
    return 'Payroll for $month hasn\'t been run yet.';
  }

  @override
  String hrApprovePayrollTitle(String month) {
    return 'Approve payroll for $month?';
  }

  @override
  String hrMarkPaidTitle(String month) {
    return 'Mark $month payroll as paid?';
  }

  @override
  String hrPayLineSubtitle(String gross, String tax) {
    return 'Gross $gross · Tax $tax';
  }

  @override
  String hrActionPayroll(String month) {
    return 'Payroll for $month isn\'t approved yet';
  }

  @override
  String get hrNewNotice => 'New notice';

  @override
  String get hrNoticeTitleField => 'Title';

  @override
  String get hrNoticeCategory => 'Category';

  @override
  String get hrNoticeBodyField => 'Write the notice here';

  @override
  String get hrPublish => 'Publish';

  @override
  String get hrNoNotices => 'No notices yet.';

  @override
  String get hrNoticeNeedsTitle => 'Enter a title for the notice.';

  @override
  String get hrNoticeNeedsBody => 'Write the text of the notice.';

  @override
  String get hrDeleteNotice => 'Delete notice';

  @override
  String get hrDeleteNoticeMessage => 'Employees will no longer see it.';

  @override
  String get hrDeleteAction => 'Delete';

  @override
  String get hrNoticesFooter =>
      'Published notices appear in every employee\'s Notices.';

  @override
  String get hrCatGeneral => 'General';

  @override
  String get hrCatUrgent => 'Urgent';

  @override
  String get hrCatPolicy => 'Policy';

  @override
  String get hrCatHoliday => 'Holiday';

  @override
  String hrDeleteNoticeTitle(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get hrReportsHeadcount => 'Headcount';

  @override
  String get hrReportsByDepartment => 'By department';

  @override
  String get hrReportsByType => 'By employment type';

  @override
  String get hrReportsRequests => 'Requests';

  @override
  String get hrReportsPayroll => 'Latest payroll';

  @override
  String get hrReportsNoPayroll => 'No payroll has been run yet.';

  @override
  String get hrReportsExport => 'Export';

  @override
  String get hrExportEmployees => 'Copy employee list as CSV';

  @override
  String get hrReportsActivity => 'Recent activity';

  @override
  String get hrNoActivity => 'Nothing has happened yet.';

  @override
  String get hrAuditEmployeeAdded => 'Employee added';

  @override
  String get hrAuditEmployeeUpdated => 'Employee updated';

  @override
  String get hrAuditEmployeeDeactivated => 'Employee deactivated';

  @override
  String get hrAuditEmployeeReactivated => 'Employee reactivated';

  @override
  String get hrAuditRequestApproved => 'Request approved';

  @override
  String get hrAuditRequestRejected => 'Request rejected';

  @override
  String get hrAuditPayrollRun => 'Payroll calculated';

  @override
  String get hrAuditPayrollApproved => 'Payroll approved';

  @override
  String get hrAuditPayrollPaid => 'Payroll marked as paid';

  @override
  String get hrAuditNoticePublished => 'Notice published';

  @override
  String get hrAuditNoticeDeleted => 'Notice deleted';

  @override
  String get hrAuditHolidayAdded => 'Company holiday added';

  @override
  String get hrAuditHolidayRemoved => 'Company holiday removed';

  @override
  String hrAuditLine(String actor, String detail) {
    return '$actor: $detail';
  }

  @override
  String get hrAllClear => 'Nothing needs your action.';

  @override
  String hrWaitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests are waiting for you',
      one: '1 request is waiting for you',
      zero: 'Nothing is waiting for you',
    );
    return '$_temp0';
  }

  @override
  String hrActionApprovals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests to review',
      one: '1 request to review',
    );
    return '$_temp0';
  }

  @override
  String hrRejectMessage(String name) {
    return 'The request from $name will be marked as rejected. This can\'t be changed afterwards.';
  }

  @override
  String hrPolicyDaysPerYear(String days) {
    return '$days days a year';
  }

  @override
  String hrPolicyAccrual(String days) {
    return '1 day for every $days days worked';
  }

  @override
  String hrPolicyCarryUpTo(String days) {
    return 'Carries forward up to $days days';
  }

  @override
  String hrPolicyDocument(String days) {
    return 'Document needed after $days days';
  }

  @override
  String hrRemoveHolidayTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String hrEmployeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count employees',
      one: '1 employee',
    );
    return '$_temp0';
  }

  @override
  String hrDeactivateTitle(String name) {
    return 'Deactivate $name?';
  }

  @override
  String hrReactivateTitle(String name) {
    return 'Reactivate $name?';
  }

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

  @override
  String get hrNewJoiners => 'New joiners (last 30 days)';

  @override
  String get hrNoNewJoiners => 'Nobody has joined in the last 30 days.';
}

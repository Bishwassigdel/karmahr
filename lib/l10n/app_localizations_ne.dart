// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get ok => 'ठीक छ';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get roleEmployee => 'कर्मचारी';

  @override
  String get roleManager => 'प्रबन्धक';

  @override
  String get roleHr => 'एचआर';

  @override
  String get loginTitle => 'KarmaHR मा साइन इन गर्नुहोस्';

  @override
  String get loginSubtitle => 'जारी राख्न आफ्नो कर्मचारी विवरण हाल्नुहोस्';

  @override
  String get staffIdLabel => 'कर्मचारी आईडी';

  @override
  String get staffIdHint => 'जस्तै MB-24071';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get passwordHint => 'आफ्नो पासवर्ड हाल्नुहोस्';

  @override
  String get forgotPassword => 'पासवर्ड बिर्सनुभयो?';

  @override
  String get forgotPasswordUnavailable =>
      'पासवर्ड रिसेट सुविधा अहिले उपलब्ध छैन।';

  @override
  String get signIn => 'साइन इन';

  @override
  String get ssoDivider => 'वा SSO मार्फत जारी राख्नुहोस्';

  @override
  String get continueWithSso => 'SSO मार्फत जारी राख्नुहोस्';

  @override
  String get ssoUnavailable => 'SSO साइन इन अहिले उपलब्ध छैन।';

  @override
  String get demoRoleLabel => 'यस रूपमा साइन इन (डेमो)';

  @override
  String get demoRoleNote =>
      'डेमो मात्र। लगइन जोडिएपछि तपाईंको भूमिका सर्भरबाट आउनेछ।';

  @override
  String get tabHome => 'गृह';

  @override
  String get tabTeam => 'टोली';

  @override
  String get tabLeave => 'बिदा';

  @override
  String get tabTime => 'समय';

  @override
  String get tabEvents => 'कार्यक्रम';

  @override
  String get tabMore => 'थप';

  @override
  String get moreApps => 'एप्स';

  @override
  String get moreAppsSubtitle => 'तपाईंका सबै सुविधा एकै ठाउँमा';

  @override
  String get moreProfile => 'प्रोफाइल';

  @override
  String get myInfoTitle => 'मेरो विवरण';

  @override
  String get infoTabJob => 'काम';

  @override
  String get infoTabContact => 'सम्पर्क';

  @override
  String get infoTabPay => 'तलब';

  @override
  String get infoTabDocs => 'कागजात';

  @override
  String get infoTabEmergency => 'आपतकालीन';

  @override
  String staffIdValue(String id) {
    return 'कर्मचारी आईडी $id';
  }

  @override
  String get jobTitleLabel => 'पद';

  @override
  String get departmentLabel => 'विभाग';

  @override
  String get managerLabel => 'प्रबन्धक';

  @override
  String get joinedLabel => 'नियुक्ति मिति';

  @override
  String get employmentTypeLabel => 'रोजगारीको प्रकार';

  @override
  String get workLocationLabel => 'कार्यस्थल';

  @override
  String get workEmailLabel => 'कार्यालय इमेल';

  @override
  String get phoneLabel => 'फोन';

  @override
  String get editAction => 'सम्पादन';

  @override
  String pendingHrApproval(String phone) {
    return 'एचआर स्वीकृति बाँकी: $phone';
  }

  @override
  String get basicSalaryLabel => 'आधारभूत तलब';

  @override
  String get dearnessAllowanceLabel => 'महँगी भत्ता';

  @override
  String get transportAllowanceLabel => 'यातायात भत्ता';

  @override
  String get grossMonthlyLabel => 'मासिक कुल तलब';

  @override
  String get payslipsLabel => 'तलबपर्चीहरू';

  @override
  String get taxPlannerLabel => 'कर योजनाकार';

  @override
  String get salaryCertificateLabel => 'तलब प्रमाणपत्र';

  @override
  String get manageDocuments => 'कागजात व्यवस्थापन';

  @override
  String get noDocuments => 'अहिलेसम्म कुनै कागजात छैन।';

  @override
  String get emergencyContactsLabel => 'आपतकालीन सम्पर्क';

  @override
  String get healthInsuranceLabel => 'स्वास्थ्य बीमा';

  @override
  String get manageEmergency => 'सम्पर्क र बीमा व्यवस्थापन';

  @override
  String get tabTimeOff => 'बिदा';

  @override
  String get requestTimeOff => 'बिदाको अनुरोध';

  @override
  String daysLeft(String days) {
    return '$days दिन बाँकी';
  }

  @override
  String get planTrip => 'यात्राको योजना';

  @override
  String get planTripSubtitle => 'सार्वजनिक बिदा नजिकका पुल दिनहरू खोज्नुहोस्';

  @override
  String get holidayCalendarLabel => 'बिदा पात्रो';

  @override
  String get allBalances => 'सबै बिदा बाँकी';

  @override
  String get myTimeOffRequests => 'मेरा बिदा अनुरोधहरू';

  @override
  String get noTimeOffRequests => 'अहिलेसम्म बिदा माग गरिएको छैन।';

  @override
  String get statusPending => 'बाँकी';

  @override
  String get statusApproved => 'स्वीकृत';

  @override
  String get statusRejected => 'अस्वीकृत';

  @override
  String get statusPaid => 'भुक्तानी भयो';

  @override
  String get tabRequests => 'अनुरोध';

  @override
  String get filterAll => 'सबै';

  @override
  String get filterOpen => 'खुला';

  @override
  String get filterClosed => 'बन्द';

  @override
  String get newRequest => 'नयाँ अनुरोध';

  @override
  String get requestTypeLeave => 'बिदा';

  @override
  String get requestTypeExpense => 'खर्च दाबी';

  @override
  String get requestTypeOvertime => 'ओभरटाइम';

  @override
  String get requestTypeHr => 'एचआर अनुरोध';

  @override
  String get noRequests => 'यहाँ केही छैन। सबै काम सकियो।';

  @override
  String get whatsHappening => 'के भइरहेको छ';

  @override
  String feedOut(String name) {
    return '$name बिदामा';
  }

  @override
  String feedBirthday(String name) {
    return '$name को जन्मदिन';
  }

  @override
  String feedAnniversary(String name, int years) {
    return '$name: KarmaHR मा $years वर्ष';
  }

  @override
  String get feedToday => 'आज';

  @override
  String get feedTomorrow => 'भोलि';

  @override
  String get feedNothing => 'यो हप्ता केही छैन।';

  @override
  String get a11ySearch => 'खोज्नुहोस्';

  @override
  String get a11yAddDocument => 'कागजात थप्नुहोस्';

  @override
  String get a11yNewExpenseClaim => 'नयाँ खर्च दाबी';

  @override
  String get a11yAddGoal => 'लक्ष्य थप्नुहोस्';

  @override
  String get a11yGiveKudos => 'प्रशंसा दिनुहोस्';

  @override
  String get a11yPostComment => 'टिप्पणी पठाउनुहोस्';

  @override
  String get a11yRemoveContact => 'सम्पर्क हटाउनुहोस्';

  @override
  String get a11yPreviousMonth => 'अघिल्लो महिना';

  @override
  String get a11yNextMonth => 'अर्को महिना';

  @override
  String get a11yShowPassword => 'पासवर्ड देखाउनुहोस्';

  @override
  String get a11yHidePassword => 'पासवर्ड लुकाउनुहोस्';

  @override
  String get a11yShareSlip => 'तलबपर्ची सेयर गर्नुहोस्';

  @override
  String get a11yFewerHours => 'कम घण्टा';

  @override
  String get a11yMoreHours => 'बढी घण्टा';

  @override
  String get a11yNotifications => 'सूचनाहरू';

  @override
  String a11yNotificationsUnread(int count) {
    return 'सूचनाहरू, $count नपढिएका';
  }

  @override
  String get logOut => 'लग आउट';

  @override
  String get logOutConfirm => 'के तपाईं लग आउट गर्न निश्चित हुनुहुन्छ?';

  @override
  String signedInAs(String role) {
    return '$role को रूपमा साइन इन';
  }

  @override
  String get teamTitle => 'मेरो टोली';

  @override
  String get teamComingTitle => 'प्रबन्धकका सुविधाहरू आउँदैछन्';

  @override
  String get teamComingBody =>
      'बिदा, खर्च र ओभरटाइमको स्वीकृति, टोलीको हाजिरी र टोली रिपोर्टहरू यहाँ देखिनेछन्।';

  @override
  String get hrTabMore => 'थप';

  @override
  String get hrPeopleEvents => 'जन्मदिन र कार्य वार्षिकोत्सव';

  @override
  String get hrNoPeopleEvents =>
      'आगामी ३० दिनमा कुनै जन्मदिन वा वार्षिकोत्सव छैन।';

  @override
  String get hrBirthday => 'जन्मदिन';

  @override
  String hrAnniversary(int years) {
    return '$years वर्षको कार्य वार्षिकोत्सव';
  }

  @override
  String get hrSectionOverview => 'सारांश';

  @override
  String get hrSectionEmployees => 'कर्मचारीहरू';

  @override
  String get hrSectionLeave => 'बिदा र सार्वजनिक बिदा';

  @override
  String get hrSectionPayroll => 'तलब';

  @override
  String get hrSectionNotices => 'सूचनाहरू';

  @override
  String get hrSectionReports => 'रिपोर्टहरू';

  @override
  String get hrStatEmployees => 'कर्मचारी';

  @override
  String get hrStatDepartments => 'विभागहरू';

  @override
  String get hrStatOutToday => 'आज बिदामा';

  @override
  String get hrByDepartment => 'विभाग अनुसार कर्मचारी';

  @override
  String get hrNobodyOut => 'आज कोही पनि बिदामा छैन।';

  @override
  String get hrDemoDataNote =>
      'डेमो डाटा। ब्याकएन्ड जोडिएपछि वास्तविक संख्या देखिनेछ।';

  @override
  String get hrSearchEmployees => 'नाम, पद वा विभाग खोज्नुहोस्';

  @override
  String get hrAddEmployee => 'कर्मचारी थप्नुहोस्';

  @override
  String get hrFilterActive => 'सक्रिय';

  @override
  String get hrFilterInactive => 'निष्क्रिय';

  @override
  String get hrNoEmployeesFound => 'मिल्ने कर्मचारी भेटिएन।';

  @override
  String get hrEmployeeTitle => 'कर्मचारी';

  @override
  String get hrNoManager => 'प्रबन्धक छैन';

  @override
  String get hrFilingStatus => 'कर बुझाउने अवस्था';

  @override
  String get hrFilingSingle => 'एकल';

  @override
  String get hrFilingMarried => 'विवाहित';

  @override
  String get hrDeactivate => 'कर्मचारी निष्क्रिय गर्नुहोस्';

  @override
  String get hrReactivate => 'कर्मचारी पुनः सक्रिय गर्नुहोस्';

  @override
  String get hrDeactivateAction => 'निष्क्रिय गर्नुहोस्';

  @override
  String get hrReactivateAction => 'पुनः सक्रिय गर्नुहोस्';

  @override
  String get hrDeactivateMessage =>
      'उनी डाइरेक्टरी र तलब सूचीमा देखिनेछैनन्। उनको अभिलेख सुरक्षित रहनेछ।';

  @override
  String get hrReactivateMessage =>
      'उनी फेरि डाइरेक्टरी र तलब सूचीमा देखिनेछन्।';

  @override
  String get hrNewEmployee => 'नयाँ कर्मचारी';

  @override
  String get hrEditEmployee => 'कर्मचारी सम्पादन';

  @override
  String get save => 'सुरक्षित गर्नुहोस्';

  @override
  String get hrFieldName => 'पूरा नाम';

  @override
  String get hrCheckDetails => 'विवरण जाँच्नुहोस्';

  @override
  String get hrErrName => 'कर्मचारीको पूरा नाम लेख्नुहोस्।';

  @override
  String get hrErrJob => 'पद र विभाग लेख्नुहोस्।';

  @override
  String get hrErrEmail => 'मान्य इमेल ठेगाना लेख्नुहोस्।';

  @override
  String get hrErrPhone =>
      '९६, ९७ वा ९८ बाट सुरु हुने १० अङ्कको मोबाइल नम्बर लेख्नुहोस् (+977 सहित पनि हुन सक्छ)।';

  @override
  String get hrErrSalary => 'शून्यभन्दा बढी आधारभूत तलब लेख्नुहोस्।';

  @override
  String get hrApprovalsTab => 'स्वीकृति';

  @override
  String get hrPolicyTab => 'नीति';

  @override
  String get hrHolidaysTab => 'बिदाहरू';

  @override
  String get hrApprove => 'स्वीकृत गर्नुहोस्';

  @override
  String get hrReject => 'अस्वीकृत गर्नुहोस्';

  @override
  String get hrRejectTitle => 'यो अनुरोध अस्वीकार गर्ने?';

  @override
  String get hrDecided => 'निर्णय भइसकेका';

  @override
  String get hrPolicyNoCarry => 'अर्को वर्षमा सर्दैन';

  @override
  String get hrPolicyCarryAll => 'सीमा बिना अर्को वर्षमा सर्छ';

  @override
  String get hrPolicyPaid => 'तलबसहित';

  @override
  String get hrPolicyUnpaid => 'तलब बिना';

  @override
  String get hrPolicyNote =>
      'यी तथ्याङ्क एचआर र कानुनी समीक्षा नभएसम्म नमूना मात्र हुन्। नीति सम्पादन ब्याकएन्डसँगै आउनेछ।';

  @override
  String get hrCompanyHolidays => 'कम्पनीका बिदाहरू';

  @override
  String get hrPublicHolidays => 'आगामी सार्वजनिक बिदाहरू';

  @override
  String get hrAddHoliday => 'कम्पनी बिदा थप्नुहोस्';

  @override
  String get hrHolidayName => 'बिदाको नाम';

  @override
  String get hrHolidayDate => 'मिति';

  @override
  String get hrNoCompanyHolidays => 'अहिलेसम्म कम्पनी बिदा छैन।';

  @override
  String get hrNoPublicHolidays => 'पात्रोमा आगामी सार्वजनिक बिदा छैन।';

  @override
  String get hrHolidayNeedsName => 'बिदाको नाम लेख्नुहोस्।';

  @override
  String get hrRemoveHoliday => 'बिदा हटाउनुहोस्';

  @override
  String get hrRemoveAction => 'हटाउनुहोस्';

  @override
  String get hrHolidayNote =>
      'सार्वजनिक बिदा सरकारी पात्रोबाट आउँछन्। यहाँ थपिएका कम्पनी बिदा एचआरको अभिलेख हुन्; ब्याकएन्ड जोडिएपछि कर्मचारीको पात्रोमा देखिनेछन्।';

  @override
  String get hrNeedsAction => 'तपाईंले गर्नुपर्ने काम';

  @override
  String get hrPayPeriod => 'तलब अवधि';

  @override
  String get hrRunPayroll => 'तलब चलाउनुहोस्';

  @override
  String get hrRecalculate => 'फेरि गणना गर्नुहोस्';

  @override
  String get hrApprovePayroll => 'तलब स्वीकृत गर्नुहोस्';

  @override
  String get hrApprovePayrollMessage =>
      'स्वीकृत भएपछि अङ्कहरू स्थिर हुन्छन्: पछि कर्मचारीको विवरण फेरिए पनि यो तलब फेरिँदैन।';

  @override
  String get hrMarkPaid => 'भुक्तानी भयो भनेर चिन्ह लगाउनुहोस्';

  @override
  String get hrMarkPaidMessage => 'बैंक ट्रान्सफर सकिएपछि मात्र यो गर्नुहोस्।';

  @override
  String get hrPayrollDraft => 'मस्यौदा';

  @override
  String get hrPayGross => 'कुल तलब';

  @override
  String get hrPayDeductions => 'कटौती';

  @override
  String get hrPayNet => 'खुद तलब';

  @override
  String get hrExportRegister => 'तलब विवरण (CSV)';

  @override
  String get hrExportBank => 'बैंक ट्रान्सफर फाइल (CSV)';

  @override
  String get hrExportTds => 'TDS प्रतिवेदन (CSV)';

  @override
  String get hrExportSsf => 'SSF योगदान प्रतिवेदन (CSV)';

  @override
  String get hrSharePayslip => 'तलबपर्ची सेयर गर्नुहोस् (PDF)';

  @override
  String get hrBankNeedsApproval =>
      'बैंक फाइल निर्यात गर्न पहिले तलब स्वीकृत गर्नुहोस्।';

  @override
  String get hrBankName => 'बैंक';

  @override
  String get hrAccountNumber => 'खाता नम्बर';

  @override
  String get hrErrAccount => 'खाता नम्बरमा अङ्क मात्र हुनुपर्छ।';

  @override
  String hrBankMissing(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count कर्मचारीको बैंक खाता विवरण छैन र बैंक फाइलबाट छुटेका छन्: $names',
    );
    return '$_temp0';
  }

  @override
  String get hrLetters => 'पत्रहरू';

  @override
  String get hrLettersFooter => 'हस्ताक्षर गरी बाँड्न PDF बनाइन्छ।';

  @override
  String get hrLetterAppointment => 'नियुक्ति पत्र';

  @override
  String get hrLetterExperience => 'अनुभव पत्र';

  @override
  String get hrAddDocument => 'कागजात थप्नुहोस्';

  @override
  String get hrDocName => 'कागजातको नाम';

  @override
  String get hrDocType => 'प्रकार';

  @override
  String get hrDocExpires => 'म्याद सकिने मिति';

  @override
  String get hrDocNoExpiry => 'म्याद छैन';

  @override
  String get hrDocExpired => 'म्याद सकियो';

  @override
  String get hrNoDocs => 'कुनै कागजात राखिएको छैन।';

  @override
  String get hrDocNeedsName => 'कागजातको नाम लेख्नुहोस्।';

  @override
  String get hrRemoveDoc => 'कागजात हटाउनुहोस्';

  @override
  String get hrReportsDocs => 'चाँडै म्याद सकिने कागजातहरू';

  @override
  String get hrNoExpiringDocs => 'आगामी ३० दिनमा कुनै कागजातको म्याद सकिँदैन।';

  @override
  String get hrDocContract => 'रोजगारी सम्झौता';

  @override
  String get hrDocCitizenship => 'नागरिकता प्रमाणपत्र';

  @override
  String get hrDocPan => 'प्यान कार्ड';

  @override
  String get hrDocPermit => 'कार्य अनुमति';

  @override
  String get hrDocCertificate => 'प्रमाणपत्र';

  @override
  String get hrDocOther => 'अन्य';

  @override
  String get hrAuditDocumentAdded => 'कागजात थपियो';

  @override
  String get hrAuditDocumentRemoved => 'कागजात हटाइयो';

  @override
  String get hrSectionAttendance => 'हाजिरी';

  @override
  String get hrSectionReviews => 'मूल्याङ्कन';

  @override
  String get hrSectionHiring => 'भर्ना';

  @override
  String get hrAttPresent => 'उपस्थित';

  @override
  String get hrAttLate => 'ढिला';

  @override
  String get hrAttAbsent => 'अनुपस्थित';

  @override
  String get hrAttOnLeave => 'बिदामा';

  @override
  String get hrAttWeeklyOff => 'साप्ताहिक बिदा। कामका लागि कोही आउनुपर्दैन।';

  @override
  String get hrAttNoRecords => 'यस दिनको रेकर्ड छैन।';

  @override
  String get hrReviewStart => 'मूल्याङ्कन चक्र सुरु गर्नुहोस्';

  @override
  String get hrReviewName => 'चक्रको नाम';

  @override
  String get hrReviewNeedsName => 'मूल्याङ्कन चक्रको नाम लेख्नुहोस्।';

  @override
  String get hrReviewNoCycles => 'अहिलेसम्म कुनै मूल्याङ्कन चक्र छैन।';

  @override
  String get hrReviewAdvance => 'अर्को चरण';

  @override
  String get hrStageNotStarted => 'सुरु भएको छैन';

  @override
  String get hrStageSelf => 'आफ्नो मूल्याङ्कन सकियो';

  @override
  String get hrStageManager => 'प्रबन्धकको मूल्याङ्कन सकियो';

  @override
  String get hrStageCompleted => 'पूरा भयो';

  @override
  String get hrAuditReviewStarted => 'मूल्याङ्कन चक्र सुरु भयो';

  @override
  String get hrJobNew => 'नयाँ जागिर';

  @override
  String get hrJobOpenings => 'रिक्त पद';

  @override
  String get hrJobOpen => 'खुला';

  @override
  String get hrJobClosed => 'बन्द';

  @override
  String get hrJobClose => 'जागिर बन्द गर्नुहोस्';

  @override
  String get hrJobReopen => 'जागिर फेरि खोल्नुहोस्';

  @override
  String get hrNoJobs => 'अहिलेसम्म कुनै जागिर छैन।';

  @override
  String get hrJobNeedsDetails =>
      'जागिरको पद, विभाग र कम्तीमा एउटा रिक्त पद लेख्नुहोस्।';

  @override
  String get hrApplicants => 'आवेदकहरू';

  @override
  String get hrAddApplicant => 'आवेदक थप्नुहोस्';

  @override
  String get hrApplicantName => 'आवेदकको नाम';

  @override
  String get hrApplicantEmail => 'इमेल (ऐच्छिक)';

  @override
  String get hrApplicantNeedsName => 'आवेदकको नाम लेख्नुहोस्।';

  @override
  String get hrNoApplicants => 'अहिलेसम्म कुनै आवेदक छैन।';

  @override
  String get hrApplicantAdvance => 'अर्को चरण';

  @override
  String get hrAddAsEmployee => 'कर्मचारीको रूपमा थप्नुहोस्';

  @override
  String get hrAppApplied => 'आवेदन दिएको';

  @override
  String get hrAppScreening => 'छनोट';

  @override
  String get hrAppInterview => 'अन्तर्वार्ता';

  @override
  String get hrAppOffer => 'प्रस्ताव';

  @override
  String get hrAppHired => 'नियुक्त';

  @override
  String get hrAuditJobPosted => 'जागिर प्रकाशित भयो';

  @override
  String get hrAuditApplicantHired => 'आवेदक नियुक्त भयो';

  @override
  String get hrShowOrgChart => 'संगठन चार्ट देखाउनुहोस्';

  @override
  String get hrShowList => 'सूची देखाउनुहोस्';

  @override
  String get hrTabTasks => 'कार्यहरू';

  @override
  String get hrOnboarding => 'नयाँ कर्मचारी स्वागत';

  @override
  String get hrOffboarding => 'बिदाइ प्रक्रिया';

  @override
  String get hrTaskCollectDocs => 'कागजात सङ्कलन';

  @override
  String get hrTaskCreateAccounts => 'खाता र इमेल बनाउने';

  @override
  String get hrTaskIssueEquipment => 'ल्यापटप र उपकरण दिने';

  @override
  String get hrTaskInduction => 'परिचय कार्यक्रम गर्ने';

  @override
  String get hrTaskIntroduceTeam => 'टोलीसँग परिचय गराउने';

  @override
  String get hrTaskExitInterview => 'बिदाइ अन्तर्वार्ता';

  @override
  String get hrTaskReturnAssets => 'ल्यापटप र परिचयपत्र फिर्ता लिने';

  @override
  String get hrTaskFinalSettlement => 'अन्तिम तलब भुक्तानी';

  @override
  String get hrTaskDisableAccounts => 'खाता बन्द गर्ने';

  @override
  String get hrTaskExperienceLetter => 'अनुभव पत्र दिने';

  @override
  String get hrImportEmployees => 'CSV बाट आयात';

  @override
  String get hrImportHint =>
      'एक लाइनमा एक जना: नाम, पद, विभाग, इमेल, फोन, आधारभूत तलब, महँगी भत्ता, यातायात भत्ता';

  @override
  String get hrImportAction => 'आयात गर्नुहोस्';

  @override
  String get hrImportNothing => 'आयात गर्ने केही छैन।';

  @override
  String get hrImportBadColumns => '८ वटा स्तम्भ चाहिन्छ';

  @override
  String get hrImportResult => 'आयात सकियो';

  @override
  String get hrAuditEmployeesImported => 'कर्मचारी आयात गरियो';

  @override
  String get roleOwner => 'कार्यकारी';

  @override
  String get ownerSecOverview => 'सारांश';

  @override
  String get ownerSecDepartments => 'विभागहरू';

  @override
  String get ownerSecPeople => 'कर्मचारी';

  @override
  String get ownerSecMoney => 'खर्च';

  @override
  String get ownerSecActivity => 'गतिविधि';

  @override
  String get ownerKpiHeadcount => 'कर्मचारी संख्या';

  @override
  String get ownerKpiProgress => 'प्रगति अङ्क';

  @override
  String get ownerKpiAttendance => 'उपस्थिति';

  @override
  String get ownerKpiPayroll => 'यो महिनाको तलब';

  @override
  String get ownerKpiAttrition => 'वर्षभरि छाडेका';

  @override
  String get ownerNeedsAttention => 'ध्यान दिनुपर्ने';

  @override
  String get ownerAllGood => 'अहिले ध्यान दिनुपर्ने केही छैन।';

  @override
  String get ownerDeptProgress => 'विभागको प्रगति';

  @override
  String get ownerSeeAll => 'सबै हेर्नुहोस्';

  @override
  String get ownerLowestFirst => 'कम अङ्क भएका पहिले';

  @override
  String get ownerStatusOnTrack => 'ठीक ट्र्याकमा';

  @override
  String get ownerStatusWatch => 'नजर राख्नुहोस्';

  @override
  String get ownerStatusBehind => 'पछाडि';

  @override
  String get ownerHowCalculated => 'प्रगति कसरी गणना गरिन्छ?';

  @override
  String get ownerMetricGoals => 'लक्ष्य प्रगति';

  @override
  String get ownerMetricReviews => 'मूल्याङ्कन पूरा';

  @override
  String get ownerMetricTraining => 'तालिम पूरा';

  @override
  String get ownerTrend12 => '१२ महिनाको कर्मचारी संख्या';

  @override
  String get ownerByBranch => 'शाखा अनुसार';

  @override
  String get ownerViewPeople => 'कर्मचारीहरू हेर्नुहोस्';

  @override
  String get ownerSearchPeople => 'नाम वा पद खोज्नुहोस्';

  @override
  String get ownerAllDepartments => 'सबै विभाग';

  @override
  String get ownerAllBranches => 'सबै शाखा';

  @override
  String get ownerDepartmentLabel => 'विभाग';

  @override
  String get ownerBranchLabel => 'शाखा';

  @override
  String get ownerAttendance30 => 'उपस्थिति, पछिल्ला ३० दिन';

  @override
  String get ownerGoalsThisQuarter => 'यस त्रैमासिकका लक्ष्य';

  @override
  String get ownerReviewLabel => 'कार्य मूल्याङ्कन';

  @override
  String get ownerReviewDone => 'सकियो';

  @override
  String get ownerReviewPending => 'बाँकी';

  @override
  String get ownerTrainingLabel => 'तालिम';

  @override
  String get ownerLeaveBalance => 'बिदा बाँकी';

  @override
  String get ownerPay => 'मासिक तलब';

  @override
  String get ownerShowPay => 'तलब देखाउनुहोस्';

  @override
  String get ownerHidePay => 'तलब लुकाउनुहोस्';

  @override
  String get ownerPayHidden => 'लुकाइएको';

  @override
  String get ownerShowPayMessage =>
      'कसैको तलब हेर्नु गतिविधि अभिलेखमा दर्ता हुन्छ।';

  @override
  String get hrAuditPayViewed => 'तलब हेरियो';

  @override
  String get ownerPayrollTrend => '१२ महिनाको तलब';

  @override
  String get ownerPerEmployee => 'प्रति कर्मचारी औसत';

  @override
  String get ownerByDepartment => 'विभाग अनुसार';

  @override
  String get ownerLakh => 'लाख';

  @override
  String get ownerCrore => 'करोड';

  @override
  String get ownerWaiting => 'निर्णयको प्रतीक्षामा';

  @override
  String get ownerNoWaiting => 'निर्णयको प्रतीक्षामा केही छैन।';

  @override
  String get ownerNoPeople => 'कोही मिलेन।';

  @override
  String ownerDemoBanner(int count) {
    return '$count जनाको नमूना कम्पनी, ताकि चार्टमा देखाउन केही होस्। वास्तविक संख्या ब्याकएन्डसँगै आउनेछ।';
  }

  @override
  String ownerPlan(int plan) {
    return 'योजना $plan';
  }

  @override
  String ownerJoinedLeft(int joined, int left) {
    return '३० दिनमा $joined थपिए · $left छाडे';
  }

  @override
  String ownerAttBehind(String name, int score) {
    return '$name प्रगतिमा पछाडि छ (अङ्क $score)';
  }

  @override
  String ownerAttAttrition(String name, int percent) {
    return '$name: वर्षभरि $percent% मानिसले छाडे';
  }

  @override
  String ownerAttShort(String name, int count) {
    return '$name आफ्नो योजनाभन्दा $count जना कम छ';
  }

  @override
  String ownerAttAttendance(String name, int percent) {
    return '$name को उपस्थिति $percent% छ';
  }

  @override
  String ownerAttRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अनुरोध ३ दिनभन्दा बढी पर्खिरहेका छन्',
    );
    return '$_temp0';
  }

  @override
  String ownerHeadcountOfPlan(int count, int plan) {
    return 'योजनाका $plan मध्ये $count';
  }

  @override
  String ownerFewPeople(int min) {
    return '$min जनाभन्दा कम';
  }

  @override
  String ownerFormulaBody(
    int goals,
    int reviews,
    int training,
    int attendance,
    int min,
  ) {
    return 'हरेक विभागले ० देखि १०० अङ्क पाउँछ: $goals% लक्ष्य प्रगति + $reviews% मूल्याङ्कन पूरा + $training% तालिम पूरा + $attendance% उपस्थिति।\n\n७५ वा बढी ठीक ट्र्याकमा, ६० देखि ७४ नजर राख्नुपर्ने, ६० भन्दा कम पछाडि।\n\n$min जनाभन्दा कमको समूह देखाइँदैन, ताकि कसैको पहिचान नहोस्।';
  }

  @override
  String ownerAttritionValue(int percent) {
    return 'टोलीको $percent%';
  }

  @override
  String ownerJoinedLast90(int count) {
    return 'पछिल्ला ९० दिनमा थपिएका: $count';
  }

  @override
  String ownerTenure(int years, int months) {
    return '$years वर्ष $months महिना';
  }

  @override
  String ownerDays(String days) {
    return '$days दिन';
  }

  @override
  String ownerShowPayTitle(String name) {
    return '$name को तलब देखाउने?';
  }

  @override
  String ownerVsLastMonth(String change) {
    return 'गत महिनाको तुलनामा $change';
  }

  @override
  String ownerWaitingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      zero: 'एक दिनभन्दा कम',
    );
    return '$_temp0';
  }

  @override
  String get hrAuditGroupPeople => 'कर्मचारी';

  @override
  String get hrAuditGroupCompany => 'कम्पनी';

  @override
  String get hrExportAudit => 'गतिविधि अभिलेख CSV मा प्रतिलिपि';

  @override
  String hrReviewDefaultName(int quarter, String year) {
    return '$year को Q$quarter मूल्याङ्कन';
  }

  @override
  String hrReviewProgress(int done, int total) {
    return '$total मध्ये $done पूरा';
  }

  @override
  String hrReviewStartHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सबै $count सक्रिय कर्मचारीको लागि मूल्याङ्कन सुरु हुन्छ।',
    );
    return '$_temp0';
  }

  @override
  String hrJobSummary(int active, int openings) {
    String _temp0 = intl.Intl.pluralLogic(
      active,
      locale: localeName,
      other: '$active आवेदक',
    );
    String _temp1 = intl.Intl.pluralLogic(
      openings,
      locale: localeName,
      other: '$openings रिक्त पद',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String hrDirectReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रत्यक्ष सहकर्मी',
    );
    return '$_temp0';
  }

  @override
  String hrTasksDone(int done, int total) {
    return '$total मध्ये $done सकियो';
  }

  @override
  String hrImportAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कर्मचारी थपिए।',
      zero: 'कुनै कर्मचारी थपिएन।',
    );
    return '$_temp0';
  }

  @override
  String hrImportSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लाइन छोडियो:',
    );
    return '$_temp0';
  }

  @override
  String hrImportLine(int line, String reason) {
    return 'लाइन $line: $reason';
  }

  @override
  String get a11yPreviousDay => 'अघिल्लो दिन';

  @override
  String get a11yNextDay => 'अर्को दिन';

  @override
  String hrAttCheckedIn(String time) {
    return '$time मा आएको';
  }

  @override
  String hrAttRate(int percent) {
    return '$percent% कार्यालय आए';
  }

  @override
  String hrDocExpiresIn(int days) {
    return '$days दिनमा म्याद सकिन्छ';
  }

  @override
  String hrRemoveDocTitle(String title) {
    return '\"$title\" हटाउने?';
  }

  @override
  String hrActionDocs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कागजातको म्याद चाँडै सकिँदैछ',
    );
    return '$_temp0';
  }

  @override
  String get hrCsvCopiedTitle => 'प्रतिलिपि भयो';

  @override
  String get hrCsvCopied => 'स्प्रेडसिटमा पेस्ट गर्नुहोस्।';

  @override
  String get hrPaySsf => 'सामाजिक सुरक्षा कोष (SSF)';

  @override
  String get hrPayCit => 'CIT योगदान';

  @override
  String get hrPayInsurance => 'बीमा प्रिमियम';

  @override
  String get hrPayTax => 'आयकर (TDS)';

  @override
  String get hrPayPlaceholderNote =>
      'कर र SSF का अङ्क नमूना नियमअनुसार हुन्। वास्तविक तलब चलाउनुअघि वित्त टोलीले जाँच्नुपर्छ।';

  @override
  String get hrNoActiveStaff =>
      'यो महिनाको लागि तलब दिनुपर्ने सक्रिय कर्मचारी छैनन्।';

  @override
  String hrPayNotRun(String month) {
    return '$month को तलब अझै चलाइएको छैन।';
  }

  @override
  String hrApprovePayrollTitle(String month) {
    return '$month को तलब स्वीकृत गर्ने?';
  }

  @override
  String hrMarkPaidTitle(String month) {
    return '$month को तलब भुक्तानी भयो भनी चिन्ह लगाउने?';
  }

  @override
  String hrPayLineSubtitle(String gross, String tax) {
    return 'कुल $gross · कर $tax';
  }

  @override
  String hrActionPayroll(String month) {
    return '$month को तलब अझै स्वीकृत भएको छैन';
  }

  @override
  String get hrNewNotice => 'नयाँ सूचना';

  @override
  String get hrNoticeTitleField => 'शीर्षक';

  @override
  String get hrNoticeCategory => 'वर्ग';

  @override
  String get hrNoticeBodyField => 'सूचना यहाँ लेख्नुहोस्';

  @override
  String get hrPublish => 'प्रकाशित गर्नुहोस्';

  @override
  String get hrNoNotices => 'अहिलेसम्म कुनै सूचना छैन।';

  @override
  String get hrNoticeNeedsTitle => 'सूचनाको शीर्षक लेख्नुहोस्।';

  @override
  String get hrNoticeNeedsBody => 'सूचनाको पाठ लेख्नुहोस्।';

  @override
  String get hrDeleteNotice => 'सूचना मेटाउनुहोस्';

  @override
  String get hrDeleteNoticeMessage => 'कर्मचारीहरूले यसलाई देख्नेछैनन्।';

  @override
  String get hrDeleteAction => 'मेटाउनुहोस्';

  @override
  String get hrNoticesFooter =>
      'प्रकाशित सूचना हरेक कर्मचारीको सूचनामा देखिन्छ।';

  @override
  String get hrCatGeneral => 'सामान्य';

  @override
  String get hrCatUrgent => 'जरुरी';

  @override
  String get hrCatPolicy => 'नीति';

  @override
  String get hrCatHoliday => 'बिदा';

  @override
  String hrDeleteNoticeTitle(String title) {
    return '\"$title\" मेटाउने?';
  }

  @override
  String get hrReportsHeadcount => 'कर्मचारी संख्या';

  @override
  String get hrReportsByDepartment => 'विभाग अनुसार';

  @override
  String get hrReportsByType => 'रोजगारीको प्रकार अनुसार';

  @override
  String get hrReportsRequests => 'अनुरोध';

  @override
  String get hrReportsPayroll => 'पछिल्लो तलब';

  @override
  String get hrReportsNoPayroll => 'अहिलेसम्म कुनै तलब चलाइएको छैन।';

  @override
  String get hrReportsExport => 'निर्यात';

  @override
  String get hrExportEmployees =>
      'कर्मचारी सूची CSV को रूपमा प्रतिलिपि गर्नुहोस्';

  @override
  String get hrReportsActivity => 'हालका गतिविधि';

  @override
  String get hrNoActivity => 'अहिलेसम्म केही भएको छैन।';

  @override
  String get hrAuditEmployeeAdded => 'कर्मचारी थपियो';

  @override
  String get hrAuditEmployeeUpdated => 'कर्मचारीको विवरण बदलियो';

  @override
  String get hrAuditEmployeeDeactivated => 'कर्मचारी निष्क्रिय गरियो';

  @override
  String get hrAuditEmployeeReactivated => 'कर्मचारी पुनः सक्रिय गरियो';

  @override
  String get hrAuditRequestApproved => 'अनुरोध स्वीकृत भयो';

  @override
  String get hrAuditRequestRejected => 'अनुरोध अस्वीकृत भयो';

  @override
  String get hrAuditPayrollRun => 'तलब गणना गरियो';

  @override
  String get hrAuditPayrollApproved => 'तलब स्वीकृत भयो';

  @override
  String get hrAuditPayrollPaid => 'तलब भुक्तानी भयो भनी चिन्ह लगाइयो';

  @override
  String get hrAuditNoticePublished => 'सूचना प्रकाशित भयो';

  @override
  String get hrAuditNoticeDeleted => 'सूचना मेटाइयो';

  @override
  String get hrAuditHolidayAdded => 'कम्पनी बिदा थपियो';

  @override
  String get hrAuditHolidayRemoved => 'कम्पनी बिदा हटाइयो';

  @override
  String hrAuditLine(String actor, String detail) {
    return '$actor: $detail';
  }

  @override
  String get hrAllClear => 'तपाईंले गर्नुपर्ने कुनै काम छैन।';

  @override
  String hrWaitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अनुरोध तपाईंको प्रतीक्षामा छन्',
      zero: 'तपाईंको लागि केही बाँकी छैन',
    );
    return '$_temp0';
  }

  @override
  String hrActionApprovals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अनुरोध हेर्न बाँकी',
    );
    return '$_temp0';
  }

  @override
  String hrRejectMessage(String name) {
    return '$name को अनुरोध अस्वीकृत भनेर चिन्ह लगाइनेछ। यो पछि बदल्न मिल्दैन।';
  }

  @override
  String hrPolicyDaysPerYear(String days) {
    return 'वर्षमा $days दिन';
  }

  @override
  String hrPolicyAccrual(String days) {
    return 'हरेक $days दिन काम गरेबापत १ दिन';
  }

  @override
  String hrPolicyCarryUpTo(String days) {
    return 'अर्को वर्षमा $days दिनसम्म सर्छ';
  }

  @override
  String hrPolicyDocument(String days) {
    return '$days दिनपछि कागजात चाहिन्छ';
  }

  @override
  String hrRemoveHolidayTitle(String name) {
    return '$name हटाउने?';
  }

  @override
  String hrEmployeeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कर्मचारी',
    );
    return '$_temp0';
  }

  @override
  String hrDeactivateTitle(String name) {
    return '$name लाई निष्क्रिय गर्ने?';
  }

  @override
  String hrReactivateTitle(String name) {
    return '$name लाई पुनः सक्रिय गर्ने?';
  }

  @override
  String get settingsTitle => 'सेटिङ';

  @override
  String get languageHeader => 'भाषा';

  @override
  String get languageFooter =>
      'स्क्रिनहरू क्रमशः अनुवाद हुँदैछन्। अनुवाद नभएका पाठ अंग्रेजीमै देखिनेछन्।';

  @override
  String get appearanceHeader => 'रूप';

  @override
  String get appearanceFooter =>
      'KarmaHR कस्तो देखिन्छ छान्नुहोस्। \"प्रणाली अनुसार\" ले तपाईंको फोनसँगै आफैं बदलिन्छ। फोनको सेटिङ जेसुकै भए पनि स्थिर राख्न उज्यालो वा अँध्यारो छान्नुहोस्।';

  @override
  String get themeSystem => 'प्रणाली अनुसार';

  @override
  String get themeSystemSubtitle => 'यो फोनको उज्यालो/अँध्यारो सेटिङ अनुसार';

  @override
  String get themeLight => 'उज्यालो';

  @override
  String get themeLightSubtitle => 'सधैं उज्यालो रूप प्रयोग गर्नुहोस्';

  @override
  String get themeDark => 'अँध्यारो';

  @override
  String get themeDarkSubtitle => 'सधैं अँध्यारो रूप प्रयोग गर्नुहोस्';

  @override
  String get securityHeader => 'सुरक्षा';

  @override
  String get appLock => 'एप लक';

  @override
  String get appLockFooter =>
      'KarmaHR खोल्दा हरेक पटक Face ID, Touch ID वा फोनको पासकोड आवश्यक पर्नेछ।';

  @override
  String get appLockUnavailableFooter =>
      'यो फोनमा Face ID, Touch ID वा पासकोड उपलब्ध छैन, त्यसैले यहाँ एप लक सक्रिय गर्न सकिँदैन।';

  @override
  String get appLockVerifyReason => 'एप लक सक्रिय गर्न पुष्टि गर्नुहोस्';

  @override
  String get couldNotVerifyTitle => 'पुष्टि हुन सकेन';

  @override
  String get couldNotVerifyBody =>
      'तपाईंको पहिचान पुष्टि हुन नसकेकाले एप लक सक्रिय भएन। Face ID, Touch ID वा फोनको पासकोड सेट भएको छ कि छैन जाँच्नुहोस् र फेरि प्रयास गर्नुहोस्।';

  @override
  String get notificationsHeader => 'सूचनाहरू';

  @override
  String get pushNotifications => 'पुस सूचना';

  @override
  String get pushFooter =>
      'KarmaHR बन्द हुँदा पनि चेक आउट, कार्यक्रम र तपाईंका अनुरोधहरूबारे रिमाइन्डर पाउनुहोस्। सबै कुरा एपभित्रको इनबक्समा पनि देखिन्छ।';

  @override
  String get pushUnavailableFooter => 'यो फोनमा सूचना सुविधा उपलब्ध छैन।';

  @override
  String get sendTestNotification => 'परीक्षण सूचना पठाउनुहोस्';

  @override
  String get notificationsNotAllowedTitle => 'सूचनाको अनुमति छैन';

  @override
  String get notificationsNotAllowedBody =>
      'सूचना पठाउन KarmaHR लाई अनुमति चाहिन्छ। फोनको Settings एपमा KarmaHR → Notifications मा गई अनुमति दिनुहोस् र फेरि प्रयास गर्नुहोस्।';

  @override
  String get testNotificationTitle => 'परीक्षण सूचना';

  @override
  String get testNotificationBody => 'पुस सूचना काम गरिरहेको छ। 🎉';

  @override
  String get hrNewJoiners => 'नयाँ सहभागी (पछिल्लो ३० दिन)';

  @override
  String get hrNoNewJoiners => 'पछिल्लो ३० दिनमा कोही सामेल भएका छैनन्।';

  @override
  String get hrSectionTeams => 'टोलीहरू';

  @override
  String get hrNewTeam => 'नयाँ टोली';

  @override
  String get hrTeamName => 'टोलीको नाम';

  @override
  String get hrTeamNameProblem => 'अरू टोलीले नलिएको टोलीको नाम लेख्नुहोस्।';

  @override
  String get hrTeamsEmpty =>
      'अहिलेसम्म कुनै टोली छैन। एउटा बनाउनुहोस्, मान्छे थप्नुहोस् र को प्रमुख हुने छान्नुहोस्।';

  @override
  String hrTeamMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get hrNoHead => 'प्रमुख छैन';

  @override
  String get hrTeamHead => 'टोली प्रमुख';

  @override
  String get hrRenameTeam => 'नाम बदल्नुहोस्';

  @override
  String get hrAddMember => 'सदस्य थप्नुहोस्';

  @override
  String get hrNoOneToAdd => 'सबै यो टोलीमा पहिले नै छन्।';

  @override
  String get hrMakeHead => 'टोली प्रमुख बनाउनुहोस्';

  @override
  String get hrRemoveHead => 'प्रमुखबाट हटाउनुहोस्';

  @override
  String get hrRemoveFromTeam => 'टोलीबाट हटाउनुहोस्';

  @override
  String hrHeadElsewhere(String name, String team) {
    return '$name पहिले नै $team को प्रमुख हुनुहुन्छ। एक व्यक्ति एउटै टोलीको प्रमुख हुन सक्छ।';
  }

  @override
  String get hrDeleteTeam => 'टोली मेट्नुहोस्';

  @override
  String hrDeleteTeamTitle(String name) {
    return '$name मेट्ने?';
  }

  @override
  String get hrDeleteTeamBody =>
      'टोली हटाइन्छ। यसमा भएका मान्छेलाई असर पर्दैन।';

  @override
  String get hrTeamHint =>
      'प्रमुख बनाउन वा हटाउन व्यक्तिमा थिच्नुहोस्। प्रमुखले अन्य सदस्यलाई काम दिन सक्छन्।';

  @override
  String get hrTeamNeedsHead =>
      'यो टोलीको प्रमुख छैन, त्यसैले कसैले यसका सदस्यलाई काम दिन सक्दैन।';

  @override
  String get hrAuditTeamCreated => 'टोली बनाइयो';

  @override
  String get hrAuditTeamUpdated => 'टोली परिवर्तन भयो';

  @override
  String get hrAuditTeamDeleted => 'टोली मेटाइयो';
}

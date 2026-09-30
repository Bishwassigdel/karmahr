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
  String get tabApps => 'एप्स';

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
  String get hrPortalTitle => 'एचआर पोर्टल';

  @override
  String get hrComingTitle => 'एचआर पोर्टल आउँदैछ';

  @override
  String get hrComingBody =>
      'कर्मचारी अभिलेख, तलब प्रक्रिया, बिदा तथा सार्वजनिक बिदाका नीति, सूचना र रिपोर्टहरू यहाँ हुनेछन्।';

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
}

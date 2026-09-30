// Earthquake / emergency "I'm safe" check-in.
//
// In a real system HR raises the alert from their own console and it
// reaches every phone via push. There's no HR side or push server yet,
// so the alert can be started here as a clearly-labelled DRILL — which is
// also a genuinely useful thing to practise: the first time someone uses
// a safety check-in shouldn't be during a real earthquake.

import 'package:flutter/foundation.dart';

enum SafetyResponse { none, safe, needHelp }

class SafetyAlert {
  final String title;
  final String message;
  final DateTime issuedAt;
  final bool isDrill;

  const SafetyAlert({
    required this.title,
    required this.message,
    required this.issuedAt,
    required this.isDrill,
  });
}

class SafetyState extends ChangeNotifier {
  SafetyAlert? _alert;
  SafetyResponse _response = SafetyResponse.none;
  String? _helpNote;

  // Demo team tally for the alert's lifetime (excluding this user).
  static const _teamSize = 42;
  int _othersSafe = 0;
  int _othersNeedHelp = 0;

  SafetyAlert? get alert => _alert;
  bool get isActive => _alert != null;
  SafetyResponse get response => _response;
  String? get helpNote => _helpNote;
  bool get awaitingMyResponse => isActive && _response == SafetyResponse.none;

  int get safeCount => _othersSafe + (_response == SafetyResponse.safe ? 1 : 0);
  int get needHelpCount =>
      _othersNeedHelp + (_response == SafetyResponse.needHelp ? 1 : 0);
  int get noResponseCount => _teamSize + 1 - safeCount - needHelpCount;

  void startDrill() {
    _alert = SafetyAlert(
      title: 'Earthquake Drill',
      message:
          'This is a DRILL. Drop, cover, and hold on. When it is safe, '
          'mark yourself below so HR knows you are okay.',
      issuedAt: DateTime.now(),
      isDrill: true,
    );
    _response = SafetyResponse.none;
    _helpNote = null;
    // As if some coworkers already responded.
    _othersSafe = 27;
    _othersNeedHelp = 1;
    notifyListeners();
  }

  void respond(SafetyResponse response, {String? note}) {
    if (!isActive) return;
    _response = response;
    _helpNote = response == SafetyResponse.needHelp ? note?.trim() : null;
    notifyListeners();
  }

  void endAlert() {
    _alert = null;
    _response = SafetyResponse.none;
    _helpNote = null;
    notifyListeners();
  }

  void reset() => endAlert();
}

// Weekly mood check-in + quick polls. Both are ANONYMOUS by design: only
// aggregate counts are stored — never "who answered what" — the same
// promise the Anonymous Feedback screen makes.

import 'package:flutter/foundation.dart';

const moodOptions = [
  ('😞', 'Rough'),
  ('😕', 'Meh'),
  ('😐', 'Okay'),
  ('🙂', 'Good'),
  ('😄', 'Great'),
];

class Poll {
  final String id;
  final String question;
  final List<String> options;
  final List<int> votes;

  /// Only used to stop voting twice and to highlight "your" answer on
  /// THIS device — it's never sent anywhere alongside the vote.
  int? myChoice;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.votes,
  });

  int get totalVotes => votes.fold(0, (a, b) => a + b);
}

class SurveyState extends ChangeNotifier {
  // Demo baseline of this week's team responses, per mood option.
  List<int> _moodCounts = _seedMoodCounts();
  int? _myMood;
  final List<Poll> _polls = _seedPolls();

  static List<int> _seedMoodCounts() => [1, 3, 9, 14, 6];

  static List<Poll> _seedPolls() => [
    Poll(
      id: 'dashain-lunch-menu',
      question: 'Dashain lunch: what should we have?',
      options: ['Khasi ko masu & sel roti', 'Newari khaja set', 'Veg thali'],
      votes: [21, 14, 9],
    ),
    Poll(
      id: 'wfh-friday',
      question: 'Would you like Friday afternoons as work-from-home?',
      options: ['Yes', 'No', "Don't mind"],
      votes: [38, 6, 11],
    ),
  ];

  List<int> get moodCounts => List.unmodifiable(_moodCounts);
  int? get myMood => _myMood;
  bool get hasCheckedInThisWeek => _myMood != null;
  int get moodResponses => _moodCounts.fold(0, (a, b) => a + b);

  List<Poll> get polls => List.unmodifiable(_polls);

  /// Team average on a 1–5 scale.
  double get averageMood {
    final total = moodResponses;
    if (total == 0) return 0;
    var sum = 0;
    for (var i = 0; i < _moodCounts.length; i++) {
      sum += (i + 1) * _moodCounts[i];
    }
    return sum / total;
  }

  void checkIn(int moodIndex) {
    if (_myMood != null) return; // one response per week
    _myMood = moodIndex;
    _moodCounts = [..._moodCounts]..[moodIndex] += 1;
    notifyListeners();
  }

  void vote(Poll poll, int optionIndex) {
    if (poll.myChoice != null) return; // one vote per poll
    poll.myChoice = optionIndex;
    poll.votes[optionIndex] += 1;
    notifyListeners();
  }

  void reset() {
    _moodCounts = _seedMoodCounts();
    _myMood = null;
    _polls
      ..clear()
      ..addAll(_seedPolls());
    notifyListeners();
  }
}

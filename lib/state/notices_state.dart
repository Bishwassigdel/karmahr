// Company notices. HR publishes them; every employee's Notices screen and
// global search read the same list. COMPANY data: logout does not reset it.

import 'package:flutter/foundation.dart';

import '../data/calendar_data.dart' show adMonths;
import '../data/notices_data.dart';

/// The categories a notice can have (the same strings Notice stores).
const noticeCategories = ['General', 'Urgent', 'Policy', 'Holiday'];

class NoticesState extends ChangeNotifier {
  final List<Notice> _notices = [...demoNotices];

  /// Newest first.
  List<Notice> get notices => List.unmodifiable(_notices);

  /// Publishes a notice dated [now] (today by default) at the top.
  /// A notice needs a title and a body; without either nothing happens and
  /// this returns false.
  bool publish({
    required String title,
    required String category,
    required String body,
    DateTime? now,
  }) {
    final t = title.trim();
    final b = body.trim();
    if (t.isEmpty || b.isEmpty) return false;
    final day = now ?? DateTime.now();
    _notices.insert(
      0,
      Notice(
        title: t,
        date:
            '${adMonths[day.month - 1].substring(0, 3)} ${day.day}, ${day.year}',
        category: category,
        body: b,
      ),
    );
    notifyListeners();
    return true;
  }

  void remove(Notice notice) {
    if (_notices.remove(notice)) notifyListeners();
  }
}

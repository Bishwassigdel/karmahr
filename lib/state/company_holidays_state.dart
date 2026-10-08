// Holidays the company adds on top of the government calendar (a founding
// day, an annual picnic). COMPANY data: logout does not reset it.

import 'package:flutter/foundation.dart';

class CompanyHoliday {
  final String id;
  final String title;

  /// A calendar day (no time of day).
  final DateTime date;

  const CompanyHoliday({
    required this.id,
    required this.title,
    required this.date,
  });
}

class CompanyHolidaysState extends ChangeNotifier {
  final List<CompanyHoliday> _holidays = _seed();
  var _nextId = 100;

  static List<CompanyHoliday> _seed() {
    final today = DateTime.now();
    DateTime inDays(int d) => DateTime(today.year, today.month, today.day + d);
    return [
      CompanyHoliday(
        id: 'h1',
        title: 'Company Foundation Day',
        date: inDays(21),
      ),
      CompanyHoliday(id: 'h2', title: 'Annual Picnic', date: inDays(48)),
    ];
  }

  /// Soonest first.
  List<CompanyHoliday> get holidays =>
      _holidays.toList()..sort((a, b) => a.date.compareTo(b.date));

  void add(String title, DateTime date) {
    final name = title.trim();
    if (name.isEmpty) return;
    _holidays.add(
      CompanyHoliday(
        id: 'h${_nextId++}',
        title: name,
        date: DateTime(date.year, date.month, date.day),
      ),
    );
    notifyListeners();
  }

  void remove(String id) {
    final before = _holidays.length;
    _holidays.removeWhere((h) => h.id == id);
    if (_holidays.length != before) notifyListeners();
  }
}

// Quarterly goals, on the Nepali fiscal calendar (Q1 = Shrawan–Ashwin).

import 'package:flutter/foundation.dart';
import 'package:nepali_utils/nepali_utils.dart';

import '../domain/nepal/fiscal_year.dart';

/// e.g. "Q1 · FY 2083/84" for today.
String currentQuarterLabel([NepaliDateTime? on]) {
  final date = on ?? NepaliDateTime.now();
  final fy = NepaliFiscalYear.of(date);
  return 'Q${NepaliFiscalYear.quarterOf(date)} · FY ${fy.label}';
}

class Goal {
  final String id;
  final String title;
  final String keyResult;
  final String quarter;
  double progress; // 0.0 – 1.0

  Goal({
    required this.id,
    required this.title,
    required this.keyResult,
    required this.quarter,
    this.progress = 0,
  });
}

class GoalsState extends ChangeNotifier {
  final List<Goal> _goals = _seed();
  int _nextId = 100;

  static List<Goal> _seed() {
    final q = currentQuarterLabel();
    return [
      Goal(
        id: 'g1',
        title: 'Cut leave-request turnaround time',
        keyResult: 'Median approval under 24 hours',
        quarter: q,
        progress: 0.6,
      ),
      Goal(
        id: 'g2',
        title: 'Digitize personnel files',
        keyResult: '120 of 200 files scanned and indexed',
        quarter: q,
        progress: 0.35,
      ),
      Goal(
        id: 'g3',
        title: 'Complete HR analytics course',
        keyResult: 'Certificate earned by quarter end',
        quarter: q,
        progress: 0.8,
      ),
    ];
  }

  List<Goal> get goals => List.unmodifiable(_goals);

  double get averageProgress => _goals.isEmpty
      ? 0
      : _goals.fold(0.0, (sum, g) => sum + g.progress) / _goals.length;

  void add({required String title, required String keyResult}) {
    _goals.add(
      Goal(
        id: 'g${_nextId++}',
        title: title.trim(),
        keyResult: keyResult.trim(),
        quarter: currentQuarterLabel(),
      ),
    );
    notifyListeners();
  }

  void setProgress(Goal goal, double progress) {
    goal.progress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  void remove(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  void reset() {
    _goals
      ..clear()
      ..addAll(_seed());
    _nextId = 100;
    notifyListeners();
  }
}

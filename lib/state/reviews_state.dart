// Performance review cycles. HR starts a cycle (say "Q2 2083/84 review") for
// every active employee and tracks each person through the same four steps.
// COMPANY data: logout does not reset it.
//
// The reviews themselves (the ratings and comments) are written by the
// employee and their manager; this only tracks who is at which step.

import 'package:flutter/foundation.dart';

enum ReviewStage { notStarted, selfDone, managerDone, completed }

class ReviewCycle {
  final String id;
  final String name;
  final DateTime createdAt;

  /// Each employee's step, by employee ID.
  final Map<String, ReviewStage> stages;

  const ReviewCycle({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.stages,
  });

  int get total => stages.length;
  int get completed =>
      stages.values.where((s) => s == ReviewStage.completed).length;

  /// 0 to 1.
  double get progress => total == 0 ? 0 : completed / total;
}

class ReviewsState extends ChangeNotifier {
  final List<ReviewCycle> _cycles = _seed();
  var _nextId = 100;

  static List<ReviewCycle> _seed() {
    final now = DateTime.now();
    return [
      ReviewCycle(
        id: 'c2',
        name: 'Q1 2083/84 review',
        createdAt: now.subtract(const Duration(days: 20)),
        stages: const {
          'MB-21003': ReviewStage.completed,
          'MB-22015': ReviewStage.completed,
          'MB-24071': ReviewStage.managerDone,
          'MB-23044': ReviewStage.selfDone,
          'MB-22021': ReviewStage.completed,
          'MB-23088': ReviewStage.selfDone,
          'MB-24012': ReviewStage.notStarted,
          'MB-23102': ReviewStage.managerDone,
        },
      ),
      ReviewCycle(
        id: 'c1',
        name: 'Q4 2082/83 review',
        createdAt: now.subtract(const Duration(days: 110)),
        stages: const {
          'MB-21003': ReviewStage.completed,
          'MB-22015': ReviewStage.completed,
          'MB-23044': ReviewStage.completed,
          'MB-22021': ReviewStage.completed,
        },
      ),
    ];
  }

  /// Newest first.
  List<ReviewCycle> get cycles =>
      _cycles.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  ReviewCycle? byId(String id) {
    for (final c in _cycles) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Starts a cycle with everyone at the first step. Needs a name and at
  /// least one person; otherwise nothing happens and this returns null.
  ReviewCycle? start(
    String name,
    Iterable<String> employeeIds, {
    DateTime? now,
  }) {
    final n = name.trim();
    final ids = employeeIds.toList();
    if (n.isEmpty || ids.isEmpty) return null;
    final cycle = ReviewCycle(
      id: 'c${_nextId++}',
      name: n,
      createdAt: now ?? DateTime.now(),
      stages: {for (final id in ids) id: ReviewStage.notStarted},
    );
    _cycles.add(cycle);
    notifyListeners();
    return cycle;
  }

  /// Moves one person to the next step. A completed review stays completed.
  void advance(String cycleId, String employeeId) {
    final i = _cycles.indexWhere((c) => c.id == cycleId);
    if (i < 0) return;
    final cycle = _cycles[i];
    final stage = cycle.stages[employeeId];
    if (stage == null || stage == ReviewStage.completed) return;

    final next = ReviewStage.values[stage.index + 1];
    _cycles[i] = ReviewCycle(
      id: cycle.id,
      name: cycle.name,
      createdAt: cycle.createdAt,
      stages: {...cycle.stages, employeeId: next},
    );
    notifyListeners();
  }
}

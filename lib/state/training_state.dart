// Assigned training and certifications. Overdue mandatory courses are
// also announced once per session in the notification inbox (see
// startup reminders in main_nav_screen.dart).

import 'package:flutter/foundation.dart';

enum TrainingStatus { notStarted, inProgress, completed }

String trainingStatusLabel(TrainingStatus s) => switch (s) {
  TrainingStatus.notStarted => 'Not started',
  TrainingStatus.inProgress => 'In progress',
  TrainingStatus.completed => 'Completed',
};

class TrainingCourse {
  final String id;
  final String title;
  final String provider;
  final int durationMinutes;
  final DateTime dueDate;
  final bool mandatory;

  /// Badge earned on completion, shown in the badge shelf.
  final String badge;
  TrainingStatus status;
  DateTime? completedOn;

  TrainingCourse({
    required this.id,
    required this.title,
    required this.provider,
    required this.durationMinutes,
    required this.dueDate,
    required this.badge,
    this.mandatory = false,
    this.status = TrainingStatus.notStarted,
    this.completedOn,
  });

  bool isOverdue(DateTime now) =>
      status != TrainingStatus.completed && dueDate.isBefore(now);
}

class TrainingState extends ChangeNotifier {
  final List<TrainingCourse> _courses = _seed();
  bool _overdueAnnounced = false;

  static List<TrainingCourse> _seed() {
    final now = DateTime.now();
    DateTime inDays(int d) => DateTime(now.year, now.month, now.day + d);
    return [
      TrainingCourse(
        id: 'it-security',
        title: 'IT Security Awareness 2026',
        provider: 'KarmaHR IT',
        durationMinutes: 30,
        dueDate: inDays(-2),
        badge: '🛡️',
        mandatory: true,
        status: TrainingStatus.inProgress,
      ),
      TrainingCourse(
        id: 'posh',
        title: 'Workplace Respect & Anti-Harassment',
        provider: 'Human Resources',
        durationMinutes: 45,
        dueDate: inDays(21),
        badge: '🤝',
        mandatory: true,
      ),
      TrainingCourse(
        id: 'labour-act',
        title: 'Labour Act 2074: What Employees Should Know',
        provider: 'Human Resources',
        durationMinutes: 40,
        dueDate: inDays(45),
        badge: '⚖️',
      ),
      TrainingCourse(
        id: 'first-aid',
        title: 'First Aid & Earthquake Preparedness',
        provider: 'Nepal Red Cross (demo)',
        durationMinutes: 90,
        dueDate: inDays(-40),
        badge: '⛑️',
        status: TrainingStatus.completed,
        completedOn: inDays(-45),
      ),
    ];
  }

  List<TrainingCourse> get courses => List.unmodifiable(_courses);

  List<TrainingCourse> overdue(DateTime now) =>
      _courses.where((c) => c.isOverdue(now)).toList();

  List<TrainingCourse> get completed =>
      _courses.where((c) => c.status == TrainingStatus.completed).toList();

  void start(TrainingCourse course) {
    if (course.status != TrainingStatus.notStarted) return;
    course.status = TrainingStatus.inProgress;
    notifyListeners();
  }

  void complete(TrainingCourse course) {
    if (course.status == TrainingStatus.completed) return;
    course.status = TrainingStatus.completed;
    course.completedOn = DateTime.now();
    notifyListeners();
  }

  /// Returns the overdue courses the FIRST time it's called in a session,
  /// then an empty list — so the startup reminder fires once per login,
  /// not on every rebuild or tab switch.
  List<TrainingCourse> takeOverdueToAnnounce(DateTime now) {
    if (_overdueAnnounced) return const [];
    _overdueAnnounced = true;
    return overdue(now);
  }

  void reset() {
    _courses
      ..clear()
      ..addAll(_seed());
    _overdueAnnounced = false;
    notifyListeners();
  }
}

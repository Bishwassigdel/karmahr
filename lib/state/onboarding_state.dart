// New-joiner onboarding checklist. Grouped by who/what it involves so a
// new employee can see "documents" vs "people" vs "systems" at a glance.

import 'package:flutter/foundation.dart';

enum OnboardingGroup { documents, systems, people, policies }

String onboardingGroupLabel(OnboardingGroup g) => switch (g) {
  OnboardingGroup.documents => 'DOCUMENTS',
  OnboardingGroup.systems => 'SYSTEMS & IT',
  OnboardingGroup.people => 'PEOPLE',
  OnboardingGroup.policies => 'POLICIES',
};

class OnboardingTask {
  final String id;
  final OnboardingGroup group;
  final String title;
  final String detail;
  bool done;

  OnboardingTask({
    required this.id,
    required this.group,
    required this.title,
    required this.detail,
    this.done = false,
  });
}

class OnboardingState extends ChangeNotifier {
  final List<OnboardingTask> _tasks = _seed();

  static List<OnboardingTask> _seed() => [
    OnboardingTask(
      id: 'docs-pan',
      group: OnboardingGroup.documents,
      title: 'Submit PAN & citizenship copies',
      detail: 'Needed by payroll for TDS and your personnel file.',
      done: true,
    ),
    OnboardingTask(
      id: 'docs-bank',
      group: OnboardingGroup.documents,
      title: 'Share bank account details',
      detail: 'Salary is credited here from your first payroll.',
      done: true,
    ),
    OnboardingTask(
      id: 'docs-ssf',
      group: OnboardingGroup.documents,
      title: 'Register for SSF / Provident Fund',
      detail: 'HR will enrol you — bring your citizenship certificate.',
    ),
    OnboardingTask(
      id: 'it-email',
      group: OnboardingGroup.systems,
      title: 'Set up work email & 2-step login',
      detail: 'Check your personal email for the IT welcome message.',
      done: true,
    ),
    OnboardingTask(
      id: 'it-security',
      group: OnboardingGroup.systems,
      title: 'Complete IT security training',
      detail: 'Assigned in Training — about 30 minutes.',
    ),
    OnboardingTask(
      id: 'people-manager',
      group: OnboardingGroup.people,
      title: 'First 1:1 with your manager',
      detail: 'Agree your first-quarter goals together.',
    ),
    OnboardingTask(
      id: 'people-buddy',
      group: OnboardingGroup.people,
      title: 'Meet your onboarding buddy',
      detail: 'Your go-to person for everyday questions.',
    ),
    OnboardingTask(
      id: 'policy-conduct',
      group: OnboardingGroup.policies,
      title: 'Read & sign the Code of Conduct',
      detail: 'Includes the anti-harassment and leave policies.',
    ),
  ];

  List<OnboardingTask> get tasks => List.unmodifiable(_tasks);

  int get doneCount => _tasks.where((t) => t.done).length;
  double get progress => _tasks.isEmpty ? 1 : doneCount / _tasks.length;
  bool get isComplete => doneCount == _tasks.length;

  void toggle(OnboardingTask task) {
    task.done = !task.done;
    notifyListeners();
  }

  void reset() {
    _tasks
      ..clear()
      ..addAll(_seed());
    notifyListeners();
  }
}

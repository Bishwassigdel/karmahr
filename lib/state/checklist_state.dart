// HR's to-do lists for people joining and leaving: tick each step as it is
// done. COMPANY data: logout does not reset it.

import 'package:flutter/foundation.dart';

enum ChecklistItem {
  // Joining
  collectDocuments,
  createAccounts,
  issueEquipment,
  inductionSession,
  introduceTeam,
  // Leaving
  exitInterview,
  returnAssets,
  finalSettlement,
  disableAccounts,
  issueExperienceLetter,
}

const onboardingItems = [
  ChecklistItem.collectDocuments,
  ChecklistItem.createAccounts,
  ChecklistItem.issueEquipment,
  ChecklistItem.inductionSession,
  ChecklistItem.introduceTeam,
];

const offboardingItems = [
  ChecklistItem.exitInterview,
  ChecklistItem.returnAssets,
  ChecklistItem.finalSettlement,
  ChecklistItem.disableAccounts,
  ChecklistItem.issueExperienceLetter,
];

class ChecklistState extends ChangeNotifier {
  // Which steps are done, by employee ID.
  final Map<String, Set<ChecklistItem>> _done = {
    // A recent joiner, partway through.
    'MB-24012': {ChecklistItem.collectDocuments, ChecklistItem.createAccounts},
    // The former employee, partway through leaving.
    'MB-22030': {ChecklistItem.exitInterview, ChecklistItem.returnAssets},
  };

  bool isDone(String employeeId, ChecklistItem item) =>
      _done[employeeId]?.contains(item) ?? false;

  /// Ticks a step, or unticks it if it was ticked.
  void toggle(String employeeId, ChecklistItem item) {
    final set = _done.putIfAbsent(employeeId, () => {});
    if (!set.remove(item)) set.add(item);
    notifyListeners();
  }

  /// How many of [items] are done for this person.
  int doneCount(String employeeId, List<ChecklistItem> items) =>
      items.where((i) => isDone(employeeId, i)).length;
}

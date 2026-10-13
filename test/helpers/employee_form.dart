import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

/// The employee form's typed fields, in order. Department and Work location
/// are picked from lists (see [pickInForm]), so they have no index here.
abstract final class EmployeeField {
  static const name = 0;
  static const jobTitle = 1;
  static const email = 2;
  static const phone = 3;
  static const basic = 4;
  static const dearness = 5;
  static const transport = 6;
  static const bank = 7;
  static const account = 8;
}

/// Types into the form's text fields by position (see [EmployeeField]).
Future<void> fillForm(WidgetTester tester, Map<int, String> values) async {
  final fields = find.byType(CupertinoTextFormFieldRow);
  for (final entry in values.entries) {
    await tester.enterText(fields.at(entry.key), entry.value);
  }
  await tester.pumpAndSettle();
}

/// Taps the row labelled [rowLabel] (e.g. "Department") and picks [name]
/// from the list, or, if the list doesn't have it, adds it with the
/// "New …" row ([newLabel]) and [addLabel] in the dialog.
Future<void> pickInForm(
  WidgetTester tester,
  String rowLabel,
  String name, {
  String newLabel = 'New department…',
  String addLabel = 'Add',
}) async {
  await tester.tap(find.text(rowLabel));
  await tester.pumpAndSettle();
  final inList = find.descendant(
    of: find.byType(CupertinoActionSheet),
    matching: find.text(name),
  );
  if (inList.evaluate().isNotEmpty) {
    await tester.tap(inList);
  } else {
    await tester.tap(find.text(newLabel));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(CupertinoAlertDialog),
        matching: find.byType(CupertinoTextField),
      ),
      name,
    );
    await tester.tap(find.text(addLabel));
  }
  await tester.pumpAndSettle();
}

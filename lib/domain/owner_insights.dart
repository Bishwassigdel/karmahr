// What the CEO should look at first, worked out from the company's numbers.
// Pure Dart, so the rules can be tested without any screen.

import '../data/company_demo.dart';

/// A group smaller than this is never broken down on its own in the CEO
/// portal: with 2 people in a slice, "average attendance" would be one
/// person's attendance in disguise.
const minGroupForStats = 5;

/// Whether a slice of [headcount] people is big enough to show figures for.
bool largeEnoughToShow(int headcount) => headcount >= minGroupForStats;

enum AttentionKind { deptBehind, deptAttrition, deptShort, branchAttendance }

/// One thing worth the CEO's attention.
class Attention {
  final AttentionKind kind;

  /// The department or branch it is about.
  final String name;

  /// The number that makes it notable: a score, a percentage or a head
  /// count, depending on [kind].
  final int value;

  /// The id of that department or branch, so a tap can open it.
  final String id;

  const Attention(this.kind, this.name, this.value, this.id);
}

/// Departments at or above this yearly attrition are flagged.
const attritionAlertPercent = 12;

/// Departments this many people (or more) short of their plan are flagged.
const shortAlertPeople = 3;

/// Branches whose people attend less than this are flagged.
const branchAttendanceAlert = 90;

/// The things to look at, most serious first: a department that is behind,
/// then high attrition, then a department short of people, then a branch
/// with weak attendance. Within each, the worst comes first. Slices too
/// small to show are never flagged.
List<Attention> companyAttention(CompanyDemo c) {
  final behind = <Attention>[];
  final attrition = <Attention>[];
  final short = <Attention>[];
  final attendance = <Attention>[];

  for (final d in c.depts) {
    final p = c.progress(deptId: d.id);
    if (!largeEnoughToShow(p.headcount)) continue;

    if (p.status == ProgressStatus.behind) {
      behind.add(Attention(AttentionKind.deptBehind, d.name, p.score, d.id));
    }
    final attr = c.attritionPercent(deptId: d.id).round();
    if (attr >= attritionAlertPercent) {
      attrition.add(Attention(AttentionKind.deptAttrition, d.name, attr, d.id));
    }
    if (p.gap >= shortAlertPeople) {
      short.add(Attention(AttentionKind.deptShort, d.name, p.gap, d.id));
    }
  }
  for (final b in c.branches) {
    final p = c.progress(branchId: b.id);
    if (!largeEnoughToShow(p.headcount)) continue;
    if (p.attendance < branchAttendanceAlert) {
      attendance.add(
        Attention(AttentionKind.branchAttendance, b.name, p.attendance, b.id),
      );
    }
  }

  behind.sort((a, b) => a.value.compareTo(b.value)); // lowest score first
  attrition.sort((a, b) => b.value.compareTo(a.value)); // highest first
  short.sort((a, b) => b.value.compareTo(a.value));
  attendance.sort((a, b) => a.value.compareTo(b.value));
  return [...behind, ...attrition, ...short, ...attendance];
}

/// Big rupee amounts the way people in Nepal read them: lakh (100,000) and
/// crore (10,000,000). "Rs. 38,000", "Rs. 12.5 lakh", "Rs. 1.52 crore".
/// Pass translated words for [lakh] and [crore].
String compactRupees(
  double amount, {
  String lakh = 'lakh',
  String crore = 'crore',
}) {
  final negative = amount < 0;
  final a = amount.abs();
  String body;
  if (a >= 10000000) {
    body = 'Rs. ${_trim(a / 10000000, 2)} $crore';
  } else if (a >= 100000) {
    body = 'Rs. ${_trim(a / 100000, 1)} $lakh';
  } else {
    final whole = a.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i != 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    body = 'Rs. $buffer';
  }
  return negative ? '-$body' : body;
}

// 1.50 -> "1.5", 2.00 -> "2", 1.526 -> "1.53" (at 2 places)
String _trim(double v, int places) {
  final s = v.toStringAsFixed(places);
  if (!s.contains('.')) return s;
  return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

/// How a figure moved against another, as a rounded percentage. Null when
/// there is nothing to compare against.
int? percentChange(double now, double before) {
  if (before == 0) return null;
  return ((now - before) * 100 / before).round();
}

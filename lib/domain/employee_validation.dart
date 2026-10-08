// The rules for an employee's basic details, in one place so the Add form
// and the CSV import can never disagree about what is acceptable.

enum EmployeeProblem { name, job, email, phone, salary }

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

// A Nepali mobile: 10 digits starting 96, 97 or 98, optionally with +977.
final _mobile = RegExp(r'^(\+977)?9[678]\d{8}$');

bool isValidEmail(String value) => _email.hasMatch(value.trim());

bool isValidNepaliMobile(String value) =>
    _mobile.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''));

/// A non-negative amount from text like "45,000" or "45000.50". Blank is 0.
/// Null when it is not a number, or is negative.
double? parseMoney(String text) {
  final t = text.trim().replaceAll(',', '');
  if (t.isEmpty) return 0;
  final v = double.tryParse(t);
  return (v == null || v < 0) ? null : v;
}

/// The first thing wrong with these details, or null if they are fine.
EmployeeProblem? firstProblem({
  required String name,
  required String jobTitle,
  required String department,
  required String email,
  required String phone,
  required double? basicSalary,
}) {
  if (name.trim().isEmpty) return EmployeeProblem.name;
  if (jobTitle.trim().isEmpty || department.trim().isEmpty) {
    return EmployeeProblem.job;
  }
  if (!isValidEmail(email)) return EmployeeProblem.email;
  if (!isValidNepaliMobile(phone)) return EmployeeProblem.phone;
  if (basicSalary == null || basicSalary <= 0) return EmployeeProblem.salary;
  return null;
}

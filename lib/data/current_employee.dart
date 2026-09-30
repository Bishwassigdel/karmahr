// The logged-in employee's details and salary structure, in ONE place.
//
// The payslip and the salary certificate both print this person's
// salary — if each kept its own copy of the numbers, a certificate
// could state a different salary than the payslips it's meant to back
// up, which is exactly the kind of mismatch a bank checks for.
//
// Frontend-only: no login/session exists yet, so this is fixed demo
// data. With a backend it becomes whatever the auth/profile API returns.

class EmployeeProfile {
  final String name;
  final String employeeId;
  final String jobTitle;
  final String department;
  final String manager;
  final DateTime joiningDate;
  final String employmentType;
  final String workLocation;
  final String email;

  // Monthly, in NPR.
  final double basicSalary;
  final double dearnessAllowance;
  final double transportAllowance;

  const EmployeeProfile({
    required this.name,
    required this.employeeId,
    required this.jobTitle,
    required this.department,
    required this.manager,
    required this.joiningDate,
    required this.employmentType,
    required this.workLocation,
    required this.email,
    required this.basicSalary,
    required this.dearnessAllowance,
    required this.transportAllowance,
  });

  double get allowances => dearnessAllowance + transportAllowance;
  double get grossMonthly => basicSalary + allowances;
}

final currentEmployee = EmployeeProfile(
  name: 'Bishwas Sigdel',
  employeeId: 'MB-24071',
  jobTitle: 'HR Associate',
  department: 'Human Resources',
  manager: 'Suresh Karki',
  joiningDate: DateTime(2024, 1, 12),
  employmentType: 'Full-Time',
  workLocation: 'Kathmandu Head Office',
  email: 'bishwas.sigdel@karmahr.com',
  basicSalary: 45000,
  dearnessAllowance: 4500,
  transportAllowance: 3000,
);

/// "Rs. 45,000" — shared by the payslip screen and both PDFs so on-screen
/// and printed figures are always formatted identically.
String formatRupees(double amount) {
  final wholeNumber = amount.round().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < wholeNumber.length; i++) {
    final positionFromEnd = wholeNumber.length - i;
    if (i != 0 && positionFromEnd % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(wholeNumber[i]);
  }

  return 'Rs. $buffer';
}

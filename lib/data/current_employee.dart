// The logged-in employee's details and salary structure, in ONE place.
//
// The payslip and the salary certificate both print this person's
// salary — if each kept its own copy of the numbers, a certificate
// could state a different salary than the payslips it's meant to back
// up, which is exactly the kind of mismatch a bank checks for.
//
// [currentEmployee] is the demo person until someone signs in for real; then
// it is that person's own record from the database (see AuthState.signInAs),
// and it goes back to the demo person on logout.

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

  /// Just a name, for a signed-in person whose employee record we couldn't
  /// load (or who has none, like a Company Admin). Everything else is blank
  /// or zero, so nothing from the demo person leaks onto their screens.
  EmployeeProfile.nameOnly(this.name)
    : employeeId = '',
      jobTitle = '',
      department = '',
      manager = '',
      joiningDate = DateTime.now(),
      employmentType = '',
      workLocation = '',
      email = '',
      basicSalary = 0,
      dearnessAllowance = 0,
      transportAllowance = 0;

  double get allowances => dearnessAllowance + transportAllowance;
  double get grossMonthly => basicSalary + allowances;
}

final demoEmployee = EmployeeProfile(
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

/// Whose screens these are. Read it when a screen is built.
EmployeeProfile currentEmployee = demoEmployee;

void setCurrentEmployee(EmployeeProfile person) => currentEmployee = person;

void resetCurrentEmployee() => currentEmployee = demoEmployee;

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

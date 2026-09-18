// Data model + demo dataset for the Employee Directory feature.
//
// Same pattern as calendar_data.dart — a plain Dart class for the
// shape of one record, plus a hardcoded list standing in for a real
// backend. Swap `demoEmployees` for a real API call later; the
// screen that displays this data won't need to change at all.

/// One entry in the employee directory.
class Employee {
  final String name;
  final String initials; // shown in the circular avatar, e.g. "SK"
  final String jobTitle;
  final String department;
  final String phone;
  final String email;

  const Employee({
    required this.name,
    required this.initials,
    required this.jobTitle,
    required this.department,
    required this.phone,
    required this.email,
  });
}

/// Demo/placeholder data only — a handful of coworkers across a few
/// departments, so search and filtering have something real to work
/// against.
const List<Employee> demoEmployees = [
  Employee(
    name: 'Suresh Karki',
    initials: 'SK',
    jobTitle: 'HR Manager',
    department: 'Human Resources',
    phone: '+977 9801122334',
    email: 'suresh.karki@karmahr.com',
  ),
  Employee(
    name: 'Anita Shrestha',
    initials: 'AS',
    jobTitle: 'Finance Officer',
    department: 'Finance',
    phone: '+977 9812233445',
    email: 'anita.shrestha@karmahr.com',
  ),
  Employee(
    name: 'Bishwas Sigdel',
    initials: 'BS',
    jobTitle: 'HR Associate',
    department: 'Human Resources',
    phone: '+977 9823344556',
    email: 'bishwas.sigdel@karmahr.com',
  ),
  Employee(
    name: 'Ramesh Thapa',
    initials: 'RT',
    jobTitle: 'IT Support Engineer',
    department: 'Information Technology',
    phone: '+977 9834455667',
    email: 'ramesh.thapa@karmahr.com',
  ),
  Employee(
    name: 'Sita Gurung',
    initials: 'SG',
    jobTitle: 'Operations Lead',
    department: 'Operations',
    phone: '+977 9845566778',
    email: 'sita.gurung@karmahr.com',
  ),
  Employee(
    name: 'Prakash Adhikari',
    initials: 'PA',
    jobTitle: 'Software Developer',
    department: 'Information Technology',
    phone: '+977 9856677889',
    email: 'prakash.adhikari@karmahr.com',
  ),
  Employee(
    name: 'Manisha Rai',
    initials: 'MR',
    jobTitle: 'Recruitment Specialist',
    department: 'Human Resources',
    phone: '+977 9867788990',
    email: 'manisha.rai@karmahr.com',
  ),
  Employee(
    name: 'Bikash Lama',
    initials: 'BL',
    jobTitle: 'Accountant',
    department: 'Finance',
    phone: '+977 9878899001',
    email: 'bikash.lama@karmahr.com',
  ),
];

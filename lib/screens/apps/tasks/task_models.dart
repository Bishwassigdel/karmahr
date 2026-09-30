import 'package:flutter/cupertino.dart';

// 1. STATUS & PRIORITY
enum TaskStatus { pending, inProgress, completed }

enum TaskPriority { low, medium, high }

String taskStatusLabel(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return 'Pending';
    case TaskStatus.inProgress:
      return 'In Progress';
    case TaskStatus.completed:
      return 'Completed';
  }
}

CupertinoDynamicColor taskStatusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return CupertinoColors.systemGrey;
    case TaskStatus.inProgress:
      return CupertinoColors.systemBlue;
    case TaskStatus.completed:
      return CupertinoColors.systemGreen;
  }
}

String taskPriorityLabel(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return 'Low';
    case TaskPriority.medium:
      return 'Medium';
    case TaskPriority.high:
      return 'High';
  }
}

CupertinoDynamicColor taskPriorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return CupertinoColors.systemGrey;
    case TaskPriority.medium:
      return CupertinoColors.systemOrange;
    case TaskPriority.high:
      return CupertinoColors.systemRed;
  }
}

// 2. TASK MODEL
//
// `employeeId` is here for the same reason as AttendanceRecord — this
// exact model can later back an HR Portal's "assign task to employee"
// view without a second, parallel shape.
class TaskItem {
  final String employeeId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final double progress; // 0.0 - 1.0

  const TaskItem({
    required this.employeeId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.progress,
  });
}

// 3. DUMMY DATA SOURCE
//
// Stands in for a real repository/API call — swap the body of this
// function for a real fetch later; the screen doesn't change.
Future<List<TaskItem>> fetchMyTasks() async {
  await Future.delayed(const Duration(milliseconds: 600));

  const employeeId = 'MB-24071';
  final today = DateTime.now();

  return [
    TaskItem(
      employeeId: employeeId,
      title: 'Submit Q3 Expense Report',
      description:
          'Compile and submit all approved expense receipts for Q3 to Finance.',
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      dueDate: today.add(const Duration(days: 2)),
      progress: 0,
    ),
    TaskItem(
      employeeId: employeeId,
      title: 'Complete KarmaHR Onboarding Module',
      description: 'Finish the remaining onboarding training videos and quiz.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      dueDate: today.add(const Duration(days: 5)),
      progress: 0.6,
    ),
    TaskItem(
      employeeId: employeeId,
      title: 'Update Emergency Contact Details',
      description:
          'Review and confirm your emergency contact information in Profile.',
      status: TaskStatus.pending,
      priority: TaskPriority.low,
      dueDate: today.add(const Duration(days: 10)),
      progress: 0,
    ),
    TaskItem(
      employeeId: employeeId,
      title: 'Prepare Branch Audit Documents',
      description: 'Gather requested documents for the internal audit team.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      dueDate: today.subtract(const Duration(days: 1)),
      progress: 0.35,
    ),
    TaskItem(
      employeeId: employeeId,
      title: 'Sign Updated HR Policy Acknowledgement',
      description:
          'Read and digitally acknowledge the revised HR policy document.',
      status: TaskStatus.completed,
      priority: TaskPriority.medium,
      dueDate: today.subtract(const Duration(days: 4)),
      progress: 1,
    ),
    TaskItem(
      employeeId: employeeId,
      title: 'Complete Annual Health Checkup Form',
      description: 'Fill and submit the annual health checkup consent form.',
      status: TaskStatus.completed,
      priority: TaskPriority.low,
      dueDate: today.subtract(const Duration(days: 9)),
      progress: 1,
    ),
  ];
}

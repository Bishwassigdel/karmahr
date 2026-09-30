// Expense claims: taxi, fuel, client meals and so on, each with an
// optional receipt photo and a chosen payout method. Same shared-state
// pattern as LeaveState/HrRequestState.

import 'package:flutter/cupertino.dart';

enum ExpenseCategory {
  transport,
  fuel,
  clientMeal,
  travel,
  phoneInternet,
  other,
}

String expenseCategoryLabel(ExpenseCategory c) => switch (c) {
  ExpenseCategory.transport => 'Taxi / Transport',
  ExpenseCategory.fuel => 'Fuel',
  ExpenseCategory.clientMeal => 'Client Meal',
  ExpenseCategory.travel => 'Travel & Lodging',
  ExpenseCategory.phoneInternet => 'Phone / Internet',
  ExpenseCategory.other => 'Other',
};

IconData expenseCategoryIcon(ExpenseCategory c) => switch (c) {
  ExpenseCategory.transport => CupertinoIcons.car_detailed,
  ExpenseCategory.fuel => CupertinoIcons.drop_fill,
  ExpenseCategory.clientMeal => CupertinoIcons.person_2_fill,
  ExpenseCategory.travel => CupertinoIcons.airplane,
  ExpenseCategory.phoneInternet => CupertinoIcons.wifi,
  ExpenseCategory.other => CupertinoIcons.square_grid_2x2_fill,
};

// eSewa and Khalti first: they're how most Nepali employees actually
// receive small reimbursements, faster than a bank transfer.
enum PayoutMethod { esewa, khalti, bank }

String payoutLabel(PayoutMethod m) => switch (m) {
  PayoutMethod.esewa => 'eSewa',
  PayoutMethod.khalti => 'Khalti',
  PayoutMethod.bank => 'Bank Transfer',
};

enum ExpenseStatus { pending, approved, rejected, paid }

String expenseStatusLabel(ExpenseStatus s) => switch (s) {
  ExpenseStatus.pending => 'Pending',
  ExpenseStatus.approved => 'Approved',
  ExpenseStatus.rejected => 'Rejected',
  ExpenseStatus.paid => 'Paid',
};

CupertinoDynamicColor expenseStatusColor(ExpenseStatus s) => switch (s) {
  ExpenseStatus.pending => CupertinoColors.systemOrange,
  ExpenseStatus.approved => CupertinoColors.systemBlue,
  ExpenseStatus.rejected => CupertinoColors.systemRed,
  ExpenseStatus.paid => CupertinoColors.systemGreen,
};

/// NOTE(hr-review): placeholder policy — receipts required above this.
const receiptRequiredAbove = 1000.0;

class ExpenseClaim {
  final ExpenseCategory category;
  final double amount;
  final DateTime spentOn;
  final String description;
  final PayoutMethod payout;

  /// eSewa/Khalti ID (usually a mobile number) or bank account number.
  final String payoutAccount;

  /// Local file path of the receipt photo, if one was attached.
  final String? receiptPath;
  final ExpenseStatus status;
  final DateTime submittedAt;

  const ExpenseClaim({
    required this.category,
    required this.amount,
    required this.spentOn,
    required this.description,
    required this.payout,
    required this.payoutAccount,
    required this.status,
    required this.submittedAt,
    this.receiptPath,
  });
}

class ExpenseState extends ChangeNotifier {
  final List<ExpenseClaim> _claims = _seed();

  static List<ExpenseClaim> _seed() {
    final now = DateTime.now();
    return [
      ExpenseClaim(
        category: ExpenseCategory.clientMeal,
        amount: 3450,
        spentOn: now.subtract(const Duration(days: 3)),
        description: 'Lunch with Himalayan Traders — renewal meeting.',
        payout: PayoutMethod.esewa,
        payoutAccount: '98XXXXXXXX',
        status: ExpenseStatus.pending,
        submittedAt: now.subtract(const Duration(days: 2)),
      ),
      ExpenseClaim(
        category: ExpenseCategory.transport,
        amount: 780,
        spentOn: now.subtract(const Duration(days: 12)),
        description: 'Taxi to Lalitpur client site and back.',
        payout: PayoutMethod.khalti,
        payoutAccount: '98XXXXXXXX',
        status: ExpenseStatus.paid,
        submittedAt: now.subtract(const Duration(days: 11)),
      ),
    ];
  }

  List<ExpenseClaim> get claims => List.unmodifiable(_claims);

  double get pendingTotal => _claims
      .where(
        (c) =>
            c.status == ExpenseStatus.pending ||
            c.status == ExpenseStatus.approved,
      )
      .fold(0, (sum, c) => sum + c.amount);

  int get pendingCount =>
      _claims.where((c) => c.status == ExpenseStatus.pending).length;

  void submit(ExpenseClaim claim) {
    _claims.insert(0, claim);
    notifyListeners();
  }

  void reset() {
    _claims
      ..clear()
      ..addAll(_seed());
    notifyListeners();
  }
}

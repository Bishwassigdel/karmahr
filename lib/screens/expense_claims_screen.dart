// Expense claims: list + "New Claim" form with receipt photo and payout
// method (eSewa / Khalti / bank).

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/current_employee.dart';
import '../state/expense_state.dart';
import '../state/notification_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/photo_picker.dart';
import 'apps/widgets/ui_kit.dart';

/// Nepali mobile numbers (NTC/Ncell/Smart): 10 digits starting 96/97/98 —
/// which is also what eSewa and Khalti use as the wallet ID.
final nepaliMobile = RegExp(r'^9[678]\d{8}$');

class ExpenseClaimsScreen extends StatelessWidget {
  const ExpenseClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseState>();
    final claims = state.claims;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Expense Claims'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const NewExpenseClaimScreen()),
          ),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Awaiting reimbursement',
                          style: TextStyle(fontSize: 12.5, color: subtle),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupees(state.pendingTotal),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    color: AppColors.karmaRed,
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const NewExpenseClaimScreen(),
                      ),
                    ),
                    child: const Text(
                      'New Claim',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (claims.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'No claims yet.',
                    style: TextStyle(color: subtle),
                  ),
                ),
              )
            else
              CupertinoListSection.insetGrouped(
                margin: EdgeInsets.zero,
                header: const Text('YOUR CLAIMS'),
                children: [for (final c in claims) _ClaimTile(claim: c)],
              ),
          ],
        ),
      ),
    );
  }
}

class _ClaimTile extends StatelessWidget {
  final ExpenseClaim claim;

  const _ClaimTile({required this.claim});

  @override
  Widget build(BuildContext context) {
    final statusColor = expenseStatusColor(claim.status).resolveFrom(context);
    return CupertinoListTile(
      leading: Icon(expenseCategoryIcon(claim.category)),
      title: Text(expenseCategoryLabel(claim.category)),
      subtitle: Text(
        '${shortDate(claim.spentOn)} · ${payoutLabel(claim.payout)}'
        '${claim.receiptPath != null ? ' · 📎' : ''}',
      ),
      additionalInfo: TileInfoBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatRupees(claim.amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              expenseStatusLabel(claim.status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: statusColor),
            ),
          ],
        ),
      ),
      onTap: () => _showDetail(context),
    );
  }

  void _showDetail(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(
          '${expenseCategoryLabel(claim.category)} · ${formatRupees(claim.amount)}',
        ),
        message: Column(
          children: [
            Text(claim.description),
            const SizedBox(height: 8),
            Text(
              'Spent ${dayDate(claim.spentOn)} · ${expenseStatusLabel(claim.status)}\n'
              'Payout: ${payoutLabel(claim.payout)} (${claim.payoutAccount})',
            ),
            if (claim.receiptPath != null) ...[
              const SizedBox(height: 12),
              PhotoThumb(path: claim.receiptPath!, size: 140),
            ],
          ],
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Close'),
        ),
      ),
    );
  }
}

class NewExpenseClaimScreen extends StatefulWidget {
  const NewExpenseClaimScreen({super.key});

  @override
  State<NewExpenseClaimScreen> createState() => _NewExpenseClaimScreenState();
}

class _NewExpenseClaimScreenState extends State<NewExpenseClaimScreen> {
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _account = TextEditingController();

  ExpenseCategory? _category;
  DateTime _spentOn = dateOnly(DateTime.now());
  PayoutMethod _payout = PayoutMethod.esewa;
  String? _receiptPath;

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _account.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', ''));
    final account = _account.text.trim().replaceAll(' ', '');

    String? problem;
    if (_category == null) {
      problem = 'Choose what the expense was for.';
    } else if (amount == null || amount <= 0) {
      problem = 'Enter the amount you spent.';
    } else if (_description.text.trim().isEmpty) {
      problem = 'Add a short description (who, where, why).';
    } else if (amount > receiptRequiredAbove && _receiptPath == null) {
      problem =
          'Claims over ${formatRupees(receiptRequiredAbove)} need a receipt '
          'photo.';
    } else if (_payout != PayoutMethod.bank &&
        !nepaliMobile.hasMatch(account)) {
      problem =
          'Enter your ${payoutLabel(_payout)} ID — the 10-digit mobile '
          'number (starting 96, 97 or 98).';
    } else if (_payout == PayoutMethod.bank && account.length < 8) {
      problem = 'Enter your bank account number.';
    }
    if (problem != null) {
      await showMessage(context, title: 'Almost there', message: problem);
      return;
    }

    if (!mounted) return;
    context.read<ExpenseState>().submit(
      ExpenseClaim(
        category: _category!,
        amount: amount!,
        spentOn: _spentOn,
        description: _description.text.trim(),
        payout: _payout,
        payoutAccount: account,
        receiptPath: _receiptPath,
        status: ExpenseStatus.pending,
        submittedAt: DateTime.now(),
      ),
    );
    notifyUser(
      context,
      kind: AppNotificationKind.hrRequest,
      title: 'Expense claim submitted',
      body:
          '${expenseCategoryLabel(_category!)} · ${formatRupees(amount)} — '
          'paid to your ${payoutLabel(_payout)} once approved.',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fieldDecoration = BoxDecoration(
      color: CupertinoColors.systemGrey6.resolveFrom(context),
      borderRadius: BorderRadius.circular(10),
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('New Claim')),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('EXPENSE'),
              children: [
                FormRow(
                  label: 'Category',
                  value: _category == null
                      ? 'Choose'
                      : expenseCategoryLabel(_category!),
                  placeholder: _category == null,
                  onTap: () async {
                    final picked = await pickFromList(
                      context,
                      items: ExpenseCategory.values,
                      label: expenseCategoryLabel,
                      initial: _category,
                    );
                    if (picked != null && mounted) setState(() => _category = picked);
                  },
                ),
                FormRow(
                  label: 'Date',
                  value: dayDate(_spentOn),
                  onTap: () async {
                    final today = dateOnly(DateTime.now());
                    final picked = await pickDate(
                      context,
                      initial: _spentOn,
                      maximum: today,
                      minimum: DateTime(today.year, today.month - 3, today.day),
                    );
                    if (picked != null && mounted) setState(() => _spentOn = picked);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoTextField(
                    controller: _amount,
                    placeholder: 'Amount (Rs.)',
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text('Rs.'),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: fieldDecoration,
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _description,
                    placeholder: 'What was it for? e.g. Taxi to client site',
                    maxLines: 3,
                    minLines: 2,
                    padding: const EdgeInsets.all(12),
                    decoration: fieldDecoration,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Receipt',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_receiptPath != null) ...[
                        PhotoThumb(path: _receiptPath!),
                        const SizedBox(width: 12),
                      ],
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          final path = await pickPhoto(context);
                          if (path != null && mounted) setState(() => _receiptPath = path);
                        },
                        child: Text(
                          _receiptPath == null ? 'Attach photo' : 'Replace',
                        ),
                      ),
                      if (_receiptPath != null)
                        CupertinoButton(
                          padding: const EdgeInsets.only(left: 16),
                          onPressed: () => setState(() => _receiptPath = null),
                          child: const Text('Remove'),
                        ),
                    ],
                  ),
                  Text(
                    'Required for claims over ${formatRupees(receiptRequiredAbove)}.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: CupertinoColors.systemGrey.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Pay me via',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<PayoutMethod>(
                      groupValue: _payout,
                      children: {
                        for (final m in PayoutMethod.values)
                          m: Text(payoutLabel(m)),
                      },
                      onValueChanged: (m) =>
                          setState(() => _payout = m ?? _payout),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _account,
                    placeholder: _payout == PayoutMethod.bank
                        ? 'Bank account number'
                        : '${payoutLabel(_payout)} ID (mobile number)',
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.all(12),
                    decoration: fieldDecoration,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.karmaRed,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _submit,
                      child: const Text(
                        'Submit Claim',
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

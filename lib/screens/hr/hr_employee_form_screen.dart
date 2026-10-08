import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../domain/employee_validation.dart';
import '../../domain/nepal/tax_slabs.dart';
import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/employee_records_state.dart';
import '../apps/widgets/ui_kit.dart';

/// Add a new employee, or edit [existing]. Shared so the two can't drift.
class HrEmployeeFormScreen extends StatefulWidget {
  final EmployeeRecord? existing;

  /// For a new employee, details to start the form with (a hired applicant's
  /// name, email, job and department). Ignored when editing.
  final String initialName;
  final String initialEmail;
  final String initialJobTitle;
  final String initialDepartment;

  const HrEmployeeFormScreen({
    super.key,
    this.existing,
    this.initialName = '',
    this.initialEmail = '',
    this.initialJobTitle = '',
    this.initialDepartment = '',
  });

  @override
  State<HrEmployeeFormScreen> createState() => _HrEmployeeFormScreenState();
}

class _HrEmployeeFormScreenState extends State<HrEmployeeFormScreen> {
  late final _name = TextEditingController(
    text: widget.existing?.name ?? widget.initialName,
  );
  late final _jobTitle = TextEditingController(
    text: widget.existing?.jobTitle ?? widget.initialJobTitle,
  );
  late final _department = TextEditingController(
    text: widget.existing?.department ?? widget.initialDepartment,
  );
  late final _location = TextEditingController(
    text: widget.existing?.workLocation ?? 'Kathmandu Head Office',
  );
  late final _email = TextEditingController(
    text: widget.existing?.email ?? widget.initialEmail,
  );
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _basic = TextEditingController(
    text: _asText(widget.existing?.basicSalary),
  );
  late final _dearness = TextEditingController(
    text: _asText(widget.existing?.dearnessAllowance),
  );
  late final _transport = TextEditingController(
    text: _asText(widget.existing?.transportAllowance),
  );
  late final _bank = TextEditingController(text: widget.existing?.bankName);
  late final _account = TextEditingController(
    text: widget.existing?.accountNumber,
  );

  late DateTime _joined =
      widget.existing?.joiningDate ?? dateOnly(DateTime.now());
  late String _type = widget.existing?.employmentType ?? employmentTypes.first;
  late String _manager = widget.existing?.manager ?? '';
  late FilingStatus _filing =
      widget.existing?.filingStatus ?? FilingStatus.single;

  bool get _editing => widget.existing != null;

  // 45000.0 -> "45000", null -> ""
  static String _asText(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _jobTitle,
      _department,
      _location,
      _email,
      _phone,
      _basic,
      _dearness,
      _transport,
      _bank,
      _account,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _problem(String message) {
    return showMessage(
      context,
      title: context.l10n.hrCheckDetails,
      message: message,
    );
  }

  Future<void> _save() async {
    final l10n = context.l10n;

    final basic = parseMoney(_basic.text);
    final dearness = parseMoney(_dearness.text);
    final transport = parseMoney(_transport.text);
    final problem = firstProblem(
      name: _name.text,
      jobTitle: _jobTitle.text,
      department: _department.text,
      email: _email.text,
      phone: _phone.text,
      basicSalary: basic,
    );
    if (problem != null) {
      return _problem(switch (problem) {
        EmployeeProblem.name => l10n.hrErrName,
        EmployeeProblem.job => l10n.hrErrJob,
        EmployeeProblem.email => l10n.hrErrEmail,
        EmployeeProblem.phone => l10n.hrErrPhone,
        EmployeeProblem.salary => l10n.hrErrSalary,
      });
    }
    // Allowances can't be negative or text either.
    if (dearness == null || transport == null) {
      return _problem(l10n.hrErrSalary);
    }
    final email = _email.text.trim();

    final account = _account.text.replaceAll(RegExp(r'[\s-]'), '');
    if (account.isNotEmpty && !RegExp(r'^\d+$').hasMatch(account)) {
      return _problem(l10n.hrErrAccount);
    }

    final state = context.read<EmployeeRecordsState>();
    final record = EmployeeRecord(
      id: widget.existing?.id ?? state.nextId(),
      name: _name.text.trim(),
      jobTitle: _jobTitle.text.trim(),
      department: _department.text.trim(),
      manager: _manager,
      joiningDate: _joined,
      employmentType: _type,
      workLocation: _location.text.trim(),
      email: email,
      phone: _phone.text.trim(),
      basicSalary: basic!,
      dearnessAllowance: dearness,
      transportAllowance: transport,
      filingStatus: _filing,
      status: widget.existing?.status ?? EmploymentStatus.active,
      bankName: _bank.text.trim(),
      accountNumber: account,
    );
    if (_editing) {
      state.update(record);
    } else {
      state.add(record);
    }
    logAudit(
      context,
      _editing ? AuditAction.employeeUpdated : AuditAction.employeeAdded,
      record.name,
    );
    Navigator.pop(context);
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
  }) {
    return CupertinoTextFormFieldRow(
      prefix: SizedBox(
        width: 120,
        child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      controller: controller,
      keyboardType: keyboard,
      textAlign: TextAlign.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final records = context.read<EmployeeRecordsState>().records;
    final money = const TextInputType.numberWithOptions(decimal: true);
    final managerNames = [
      '',
      for (final r in records)
        if (r.isActive && r.id != widget.existing?.id) r.name,
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_editing ? l10n.hrEditEmployee : l10n.hrNewEmployee),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _save,
          child: Text(
            l10n.save,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              children: [
                const SizedBox(height: 12),
                CupertinoListSection.insetGrouped(
                  header: Text(l10n.infoTabJob.toUpperCase()),
                  footer: Text(
                    l10n.staffIdValue(
                      widget.existing?.id ??
                          context.read<EmployeeRecordsState>().nextId(),
                    ),
                  ),
                  children: [
                    _field(l10n.hrFieldName, _name),
                    _field(l10n.jobTitleLabel, _jobTitle),
                    _field(l10n.departmentLabel, _department),
                    FormRow(
                      label: l10n.managerLabel,
                      value: _manager.isEmpty ? l10n.hrNoManager : _manager,
                      onTap: () async {
                        final picked = await pickFromList<String>(
                          context,
                          items: managerNames,
                          initial: _manager,
                          label: (n) => n.isEmpty ? l10n.hrNoManager : n,
                        );
                        if (picked != null && mounted) {
                          setState(() => _manager = picked);
                        }
                      },
                    ),
                    FormRow(
                      label: l10n.joinedLabel,
                      value: '${shortDate(_joined)}, ${_joined.year}',
                      onTap: () async {
                        final today = dateOnly(DateTime.now());
                        final picked = await pickDate(
                          context,
                          initial: _joined,
                          minimum: DateTime(1990),
                          maximum: DateTime(
                            today.year + 1,
                            today.month,
                            today.day,
                          ),
                        );
                        if (picked != null && mounted) {
                          setState(() => _joined = picked);
                        }
                      },
                    ),
                    FormRow(
                      label: l10n.employmentTypeLabel,
                      value: _type,
                      onTap: () async {
                        final picked = await pickFromList<String>(
                          context,
                          items: employmentTypes,
                          initial: _type,
                          label: (t) => t,
                        );
                        if (picked != null && mounted) {
                          setState(() => _type = picked);
                        }
                      },
                    ),
                    _field(l10n.workLocationLabel, _location),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  header: Text(l10n.infoTabContact.toUpperCase()),
                  children: [
                    _field(
                      l10n.workEmailLabel,
                      _email,
                      keyboard: TextInputType.emailAddress,
                    ),
                    _field(
                      l10n.phoneLabel,
                      _phone,
                      keyboard: TextInputType.phone,
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  header: Text(l10n.infoTabPay.toUpperCase()),
                  children: [
                    _field(l10n.basicSalaryLabel, _basic, keyboard: money),
                    _field(
                      l10n.dearnessAllowanceLabel,
                      _dearness,
                      keyboard: money,
                    ),
                    _field(
                      l10n.transportAllowanceLabel,
                      _transport,
                      keyboard: money,
                    ),
                    _field(l10n.hrBankName, _bank),
                    _field(
                      l10n.hrAccountNumber,
                      _account,
                      keyboard: TextInputType.number,
                    ),
                    FormRow(
                      label: l10n.hrFilingStatus,
                      value: _filing == FilingStatus.married
                          ? l10n.hrFilingMarried
                          : l10n.hrFilingSingle,
                      onTap: () async {
                        final picked = await pickFromList<FilingStatus>(
                          context,
                          items: FilingStatus.values,
                          initial: _filing,
                          label: (f) => f == FilingStatus.married
                              ? l10n.hrFilingMarried
                              : l10n.hrFilingSingle,
                        );
                        if (picked != null && mounted) {
                          setState(() => _filing = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

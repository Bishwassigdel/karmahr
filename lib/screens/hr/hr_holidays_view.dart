import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/calendar_data.dart';
import '../../domain/nepal/bs_dates.dart';
import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/company_holidays_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/ui_kit.dart';

/// HR > Leave & Holidays > Holidays: the company's own holidays (add and
/// remove) and the next public holidays from the government calendar.
class HrHolidaysView extends StatelessWidget {
  const HrHolidaysView({super.key});

  Future<void> _add(BuildContext context) async {
    final entered =
        await showCupertinoModalPopup<({String title, DateTime date})>(
          context: context,
          builder: (_) => const _AddHolidaySheet(),
        );
    if (entered == null || !context.mounted) return;
    context.read<CompanyHolidaysState>().add(entered.title, entered.date);
    logAudit(context, AuditAction.holidayAdded, entered.title);
  }

  Future<void> _remove(BuildContext context, CompanyHoliday h) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.hrRemoveHolidayTitle(h.title),
      message: l10n.hrRemoveHoliday,
      confirmLabel: l10n.hrRemoveAction,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    context.read<CompanyHolidaysState>().remove(h.id);
    logAudit(context, AuditAction.holidayRemoved, h.title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final company = context.watch<CompanyHolidaysState>().holidays;
    final publicHolidays = getUpcomingMarkers(
      limit: 8,
      typesFilter: const {MarkerType.governmentHoliday},
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            CupertinoListSection.insetGrouped(
              header: Text(l10n.hrCompanyHolidays.toUpperCase()),
              children: [
                if (company.isEmpty)
                  CupertinoListTile(title: Text(l10n.hrNoCompanyHolidays))
                else
                  for (final h in company)
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.flag_fill),
                      title: Text(
                        h.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${dayDate(h.date)} · '
                        '${bsLabel(bsFromAd(h.date), nepali: isNepali)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () => _remove(context, h),
                        child: Icon(
                          CupertinoIcons.minus_circle,
                          color: CupertinoColors.destructiveRed,
                          semanticLabel: l10n.hrRemoveHoliday,
                        ),
                      ),
                    ),
                CupertinoListTile(
                  leading: const Icon(
                    CupertinoIcons.add_circled,
                    color: AppColors.karmaRed,
                  ),
                  title: Text(
                    l10n.hrAddHoliday,
                    style: const TextStyle(color: AppColors.karmaRed),
                  ),
                  onTap: () => _add(context),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text(l10n.hrPublicHolidays.toUpperCase()),
              children: [
                if (publicHolidays.isEmpty)
                  CupertinoListTile(title: Text(l10n.hrNoPublicHolidays))
                else
                  for (final m in publicHolidays)
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.flag),
                      title: Text(
                        m.marker.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        bsLabel(m.date, nepali: isNepali),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                l10n.hrHolidayNote,
                style: TextStyle(fontSize: 12.5, color: subtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: name + date. Owns its controller, so it is disposed only
/// when the sheet is truly gone.
class _AddHolidaySheet extends StatefulWidget {
  const _AddHolidaySheet();

  @override
  State<_AddHolidaySheet> createState() => _AddHolidaySheetState();
}

class _AddHolidaySheetState extends State<_AddHolidaySheet> {
  final _name = TextEditingController();
  DateTime _date = dateOnly(DateTime.now());

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      await showMessage(
        context,
        title: context.l10n.hrCheckDetails,
        message: context.l10n.hrHolidayNeedsName,
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, (title: _name.text.trim(), date: _date));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: AppColors.surface.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  Expanded(
                    child: Text(
                      l10n.hrAddHoliday,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _save,
                    child: Text(l10n.save),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _name,
                autofocus: true,
                placeholder: l10n.hrHolidayName,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
              CupertinoListSection.insetGrouped(
                margin: EdgeInsets.zero,
                children: [
                  FormRow(
                    label: l10n.hrHolidayDate,
                    value: dayDate(_date),
                    onTap: () async {
                      final picked = await pickDate(
                        context,
                        initial: _date,
                        minimum: DateTime(2020),
                        maximum: DateTime(DateTime.now().year + 3),
                      );
                      if (picked != null && mounted) {
                        setState(() => _date = picked);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

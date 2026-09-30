// Emergency contacts + health insurance card + Nepal's emergency numbers,
// all one tap from a call. Everything here works with no network.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/current_employee.dart';
import '../state/emergency_info_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/ui_kit.dart';

class EmergencyInfoScreen extends StatelessWidget {
  const EmergencyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EmergencyInfoState>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Emergency & Insurance'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: InsuranceCardView(card: state.insurance),
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('EMERGENCY CONTACTS'),
              footer: const Text(
                'Tap a contact to call them. Use ⋯ to remove one.',
              ),
              children: [
                for (final c in state.contacts)
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.person_crop_circle_fill),
                    title: Text(c.name),
                    subtitle: Text('${c.relation} · ${c.phone}'),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: () async {
                        final ok = await confirm(
                          context,
                          title: 'Remove ${c.name}?',
                          message: 'They will no longer be listed as an emergency contact.',
                          confirmLabel: 'Remove',
                          destructive: true,
                        );
                        if (ok && context.mounted) {
                          context.read<EmergencyInfoState>().remove(c.id);
                        }
                      },
                      child: const Icon(CupertinoIcons.ellipsis_circle),
                    ),
                    onTap: () => callNumber(context, c.phone),
                  ),
                CupertinoListTile(
                  leading: const Icon(
                    CupertinoIcons.add_circled_solid,
                    color: AppColors.karmaRed,
                  ),
                  title: const Text('Add emergency contact'),
                  onTap: () => _addContact(context),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('NEPAL EMERGENCY NUMBERS'),
              children: [
                for (final (name, number) in nepalEmergencyNumbers)
                  CupertinoListTile(
                    leading: const Icon(
                      CupertinoIcons.phone_fill,
                      color: AppColors.karmaRed,
                    ),
                    title: Text(name),
                    additionalInfo: Text(
                      number,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => callNumber(context, number),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _addContact(BuildContext context) async {
    final result = await showCupertinoDialog<(String, String, String)>(
      context: context,
      builder: (_) => const _ContactDialog(),
    );
    if (result == null || !context.mounted) return;

    final (name, relation, phone) = result;
    final valid =
        name.isNotEmpty && phone.replaceAll(RegExp(r'\D'), '').length >= 7;
    if (!valid) {
      await showMessage(
        context,
        title: 'Not saved',
        message: 'A name and a phone number (at least 7 digits) are needed.',
      );
      return;
    }
    context.read<EmergencyInfoState>().add(
      name: name,
      relation: relation.isEmpty ? 'Contact' : relation,
      phone: phone,
    );
  }
}

// Owns its text controllers so they're disposed when the dialog is truly
// gone — disposing them right after `await showCupertinoDialog` would be
// too early, because the dialog is still animating out and its fields
// still reference them.
class _ContactDialog extends StatefulWidget {
  const _ContactDialog();

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _name = TextEditingController();
  final _relation = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _relation.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Emergency Contact'),
      content: Column(
        children: [
          const SizedBox(height: 12),
          CupertinoTextField(controller: _name, placeholder: 'Name'),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _relation,
            placeholder: 'Relation (e.g. Spouse)',
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _phone,
            placeholder: 'Phone',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, (
            _name.text.trim(),
            _relation.text.trim(),
            _phone.text.trim(),
          )),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class InsuranceCardView extends StatelessWidget {
  final HealthInsuranceCard card;

  const InsuranceCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    const white = CupertinoColors.white;
    const faint = Color(0xCCFFFFFF);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFC62828), Color(0xFF8E1B1B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.heart_circle_fill,
                color: white,
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  card.provider,
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            currentEmployee.name,
            style: const TextStyle(
              color: white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            card.planName,
            style: const TextStyle(color: faint, fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 22,
            runSpacing: 10,
            children: [
              _field('Member ID', card.memberId),
              _field('Policy', card.policyNumber),
              _field('Cover', formatRupees(card.annualCoverage)),
              _field(
                'Valid until',
                '${shortDate(card.validUntil)}, ${card.validUntil.year}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => callNumber(context, card.claimsHotline),
            child: Row(
              children: [
                const Icon(CupertinoIcons.phone_fill, color: white, size: 16),
                const SizedBox(width: 6),
                // Wraps rather than truncating — a cut-off phone number
                // is useless in exactly the moment this card is needed.
                Flexible(
                  child: Text(
                    'Claims hotline ${card.claimsHotline}',
                    style: const TextStyle(
                      color: white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

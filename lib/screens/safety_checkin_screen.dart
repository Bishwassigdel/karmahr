// Earthquake / emergency "I'm safe" check-in. During an alert: two big
// buttons (I'm Safe / I Need Help), the team tally, and one-tap calls to
// Nepal's emergency numbers. With no HR console yet, an alert can be
// started here as a clearly-labelled DRILL.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/emergency_info_state.dart';
import '../state/notification_state.dart';
import '../state/safety_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/ui_kit.dart';

Future<void> respondSafe(BuildContext context) async {
  context.read<SafetyState>().respond(SafetyResponse.safe);
  notifyUser(
    context,
    kind: AppNotificationKind.system,
    title: 'Marked safe',
    body: 'HR can see that you are safe. Thank you.',
  );
}

Future<void> respondNeedHelp(BuildContext context) async {
  final note = await showCupertinoDialog<String>(
    context: context,
    builder: (_) => const _HelpDialog(),
  );
  if (note == null || !context.mounted) return;
  context.read<SafetyState>().respond(SafetyResponse.needHelp, note: note);
  notifyUser(
    context,
    kind: AppNotificationKind.system,
    title: 'Help requested',
    body: 'HR has been alerted. If you are in danger, call 100 or 102.',
  );
}

class SafetyCheckInScreen extends StatelessWidget {
  const SafetyCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final safety = context.watch<SafetyState>();
    final alert = safety.alert;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Safety Check-in'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (alert == null) ...[
              SectionCard(
                title: 'No active alert',
                subtitle:
                    'When HR raises an earthquake or emergency alert, it '
                    'appears here and on your Dashboard so you can tell '
                    'them you are safe in one tap.',
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.systemGrey5.resolveFrom(context),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      context.read<SafetyState>().startDrill();
                      notifyUser(
                        context,
                        kind: AppNotificationKind.system,
                        title: 'Earthquake drill started',
                        body: 'Practice checking in as safe.',
                      );
                    },
                    child: Text(
                      'Practice with a drill',
                      style: TextStyle(
                        color: CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              SafetyAlertBanner(showOpenButton: false),
              const SizedBox(height: 14),
              SectionCard(
                title: 'Team status',
                child: Row(
                  children: [
                    _Tally(
                      'Safe',
                      safety.safeCount,
                      CupertinoColors.systemGreen,
                    ),
                    _Tally(
                      'Need help',
                      safety.needHelpCount,
                      CupertinoColors.systemRed,
                    ),
                    _Tally(
                      'No response',
                      safety.noResponseCount,
                      CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ),
              if (alert.isDrill) ...[
                const SizedBox(height: 12),
                CupertinoButton(
                  onPressed: () => context.read<SafetyState>().endAlert(),
                  child: const Text('End drill'),
                ),
              ],
            ],
            const SizedBox(height: 16),
            const Text(
              'EMERGENCY NUMBERS',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final (name, number) in nepalEmergencyNumbers)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CupertinoButton(
                        color: AppColors.karmaRed,
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onPressed: () => callNumber(context, number),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              number,
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tally extends StatelessWidget {
  final String label;
  final int count;
  final CupertinoDynamicColor color;

  const _Tally(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color.resolveFrom(context),
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11.5)),
        ],
      ),
    );
  }
}

/// The red alert card: message + I'm Safe / I Need Help, or your answer
/// once given. Shown on the Dashboard (top) and the Safety screen.
class SafetyAlertBanner extends StatelessWidget {
  final bool showOpenButton;

  const SafetyAlertBanner({super.key, this.showOpenButton = true});

  @override
  Widget build(BuildContext context) {
    final safety = context.watch<SafetyState>();
    final alert = safety.alert;
    if (alert == null) return const SizedBox.shrink();

    const white = CupertinoColors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.title,
                  style: const TextStyle(
                    color: white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            alert.message,
            style: const TextStyle(color: white, fontSize: 13.5, height: 1.35),
          ),
          const SizedBox(height: 12),
          switch (safety.response) {
            SafetyResponse.none => Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    color: white,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () => respondSafe(context),
                    child: Text(
                      "I'm Safe",
                      style: TextStyle(
                        color: CupertinoColors.systemGreen.darkColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoButton(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () => respondNeedHelp(context),
                    child: const Text(
                      'I Need Help',
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SafetyResponse.safe => const Text(
              '✓ You marked yourself safe.',
              style: TextStyle(color: white, fontWeight: FontWeight.w600),
            ),
            SafetyResponse.needHelp => Text(
              '⚠ Help requested${safety.helpNote?.isNotEmpty == true ? ': "${safety.helpNote}"' : ''}. '
              'HR has been alerted.',
              style: const TextStyle(color: white, fontWeight: FontWeight.w600),
            ),
          },
          if (showOpenButton)
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: const EdgeInsets.only(top: 6),
                minimumSize: Size.zero,
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const SafetyCheckInScreen(),
                  ),
                ),
                child: const Text(
                  'Team status & emergency numbers →',
                  style: TextStyle(color: white, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HelpDialog extends StatefulWidget {
  const _HelpDialog();

  @override
  State<_HelpDialog> createState() => _HelpDialogState();
}

class _HelpDialogState extends State<_HelpDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('I Need Help'),
      content: Column(
        children: [
          const SizedBox(height: 8),
          const Text('Where are you, and what do you need? (optional)'),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: _note,
            placeholder: 'e.g. 3rd floor stairwell, minor injury',
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, _note.text),
          child: const Text('Send'),
        ),
      ],
    );
  }
}

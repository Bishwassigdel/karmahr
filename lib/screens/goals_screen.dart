// Goals / OKRs for the current Nepali fiscal quarter, with the kudos you
// received shown alongside — both are what you bring to an appraisal.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/current_employee.dart';
import '../state/goals_state.dart';
import '../state/kudos_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/progress_bar.dart';
import 'apps/widgets/ui_kit.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<GoalsState>();
    final kudos = context
        .watch<KudosState>()
        .posts
        .where((p) => p.toName == currentEmployee.name)
        .toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Goals'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => _addGoal(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              title: currentQuarterLabel(),
              subtitle: 'Overall progress across ${goals.goals.length} goals',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(goals.averageProgress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ProgressBar(
                    progress: goals.averageProgress,
                    color: AppColors.karmaRed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final g in goals.goals) ...[
              _GoalCard(goal: g),
              const SizedBox(height: 10),
            ],
            if (goals.goals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No goals yet — tap + to add one.')),
              ),
            const SizedBox(height: 8),
            SectionCard(
              title: 'Recognition this quarter',
              subtitle: 'Kudos you received — handy at appraisal time',
              child: kudos.isEmpty
                  ? const Text('No kudos yet.')
                  : Column(
                      children: [
                        for (final k in kudos)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '💬',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '"${k.message}" — ${k.fromName} · ${k.category}'
                                    '${k.points > 0 ? ' · +${k.points} pts' : ''}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addGoal(BuildContext context) async {
    final result = await showCupertinoDialog<(String, String)>(
      context: context,
      builder: (_) => const _GoalDialog(),
    );
    if (result == null || !context.mounted) return;
    final (title, keyResult) = result;
    if (title.isEmpty) return;
    context.read<GoalsState>().add(
      title: title,
      keyResult: keyResult.isEmpty
          ? 'Define how you will measure this'
          : keyResult,
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(goal.progress * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Key result: ${goal.keyResult}',
            style: TextStyle(fontSize: 12, color: subtle),
          ),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlider(
              value: goal.progress,
              divisions: 20,
              activeColor: AppColors.karmaRed,
              onChanged: (v) => context.read<GoalsState>().setProgress(goal, v),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog();

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  final _title = TextEditingController();
  final _keyResult = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _keyResult.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('New Goal'),
      content: Column(
        children: [
          const SizedBox(height: 12),
          CupertinoTextField(controller: _title, placeholder: 'Goal'),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _keyResult,
            placeholder: 'How will you measure it?',
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
            _title.text.trim(),
            _keyResult.text.trim(),
          )),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

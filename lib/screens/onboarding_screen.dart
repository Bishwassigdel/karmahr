// New-joiner onboarding checklist with a progress ring, grouped into
// documents / systems / people / policies.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/progress_bar.dart';
import 'apps/widgets/ui_kit.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingState>();
    final tasks = state.tasks;
    final pct = (state.progress * 100).round();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Onboarding')),
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.isComplete
                          ? 'All done — welcome aboard! 🎉'
                          : '$pct% complete',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.doneCount} of ${tasks.length} steps',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ProgressBar(
                      progress: state.progress,
                      color: AppColors.karmaRed,
                    ),
                  ],
                ),
              ),
            ),
            for (final group in OnboardingGroup.values)
              CupertinoListSection.insetGrouped(
                header: Text(onboardingGroupLabel(group)),
                children: [
                  for (final t in tasks.where((t) => t.group == group))
                    CupertinoListTile(
                      leading: Icon(
                        t.done
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.circle,
                        color: t.done
                            ? CupertinoColors.systemGreen.resolveFrom(context)
                            : CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                      title: Text(
                        t.title,
                        style: TextStyle(
                          decoration: t.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(t.detail),
                      onTap: () => context.read<OnboardingState>().toggle(t),
                    ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

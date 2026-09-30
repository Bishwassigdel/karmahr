// Weekly mood check-in + quick polls — anonymous by design (only totals
// are kept). Links through to Anonymous Feedback for anyone who wants to
// say more than an emoji.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/survey_state.dart';
import '../theme/app_colors.dart';
import 'anonymous_feedback_screen.dart';
import 'apps/widgets/ui_kit.dart';

class PulseSurveyScreen extends StatelessWidget {
  const PulseSurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SurveyState>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pulse & Polls'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PulseCheckInCard(showResults: true),
            const SizedBox(height: 16),
            for (final poll in state.polls) ...[
              _PollCard(poll: poll),
              const SizedBox(height: 12),
            ],
            const NoteBanner(
              icon: CupertinoIcons.eye_slash_fill,
              color: CupertinoColors.systemIndigo,
              text:
                  'Anonymous: only totals are recorded — never who answered '
                  'what. Same promise as Anonymous Feedback.',
            ),
          ],
        ),
      ),
    );
  }
}

/// The mood check-in. Before answering: five emoji buttons. After: the
/// team's anonymous results (on the full screen) or a thank-you (on the
/// Dashboard).
class PulseCheckInCard extends StatelessWidget {
  final bool showResults;

  const PulseCheckInCard({super.key, this.showResults = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SurveyState>();
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    if (!state.hasCheckedInThisWeek) {
      return SectionCard(
        title: 'How was your week?',
        subtitle: 'Anonymous · takes one tap',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < moodOptions.length; i++)
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  onPressed: () => context.read<SurveyState>().checkIn(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        moodOptions[i].$1,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        moodOptions[i].$2,
                        style: TextStyle(fontSize: 10.5, color: subtle),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final mine = moodOptions[state.myMood!];
    return SectionCard(
      title: 'Thanks for checking in ${mine.$1}',
      subtitle:
          'Team mood this week: ${state.averageMood.toStringAsFixed(1)} / 5 '
          'from ${state.moodResponses} responses',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showResults)
            for (var i = moodOptions.length - 1; i >= 0; i--)
              _ResultBar(
                label: '${moodOptions[i].$1} ${moodOptions[i].$2}',
                count: state.moodCounts[i],
                total: state.moodResponses,
                highlight: i == state.myMood,
              ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => const AnonymousFeedbackScreen(),
              ),
            ),
            child: const Text(
              'Want to say more? Share anonymous feedback →',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  final Poll poll;

  const _PollCard({required this.poll});

  @override
  Widget build(BuildContext context) {
    final voted = poll.myChoice != null;
    return SectionCard(
      title: poll.question,
      subtitle: voted ? '${poll.totalVotes} votes' : 'Tap an answer to vote',
      child: Column(
        children: [
          for (var i = 0; i < poll.options.length; i++)
            voted
                ? _ResultBar(
                    label: poll.options[i],
                    count: poll.votes[i],
                    total: poll.totalVotes,
                    highlight: i == poll.myChoice,
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoColors.systemGrey5.resolveFrom(context),
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onPressed: () =>
                            context.read<SurveyState>().vote(poll, i),
                        child: Text(
                          poll.options[i],
                          style: TextStyle(
                            color: CupertinoColors.label.resolveFrom(context),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final bool highlight;

  const _ResultBar({
    required this.label,
    required this.count,
    required this.total,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;
    final track = CupertinoColors.systemGrey5.resolveFrom(context);
    final fill = highlight
        ? AppColors.karmaRed
        : CupertinoColors.systemGrey3.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  highlight ? '$label  (you)' : label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                '${(fraction * 100).round()}%',
                style: const TextStyle(fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: track,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(color: fill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

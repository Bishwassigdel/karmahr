import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/kudos_state.dart';
import '../theme/app_colors.dart';

// Shows exactly how the kudos card will look before it's actually
// posted. "Edit" just pops back to the form (nothing was posted
// yet, so there's nothing to undo). "Confirm & Post" is the ONLY
// place that calls KudosState.giveKudos() — this screen is the
// single point where a kudos becomes real.
class KudosPreviewScreen extends StatelessWidget {
  final String recipientName;
  final String category;
  final String message;
  final int points;

  const KudosPreviewScreen({
    super.key,
    required this.recipientName,
    required this.category,
    required this.message,
    required this.points,
  });

  // "Bishwas Sigdel" stands in for the logged-in user — same
  // hardcoded-current-user assumption used on ProfileScreen, since
  // there's no real login/session yet.
  static const _currentUserName = 'Bishwas Sigdel';

  void _confirmAndPost(BuildContext context) {
    context.read<KudosState>().giveKudos(
      fromName: _currentUserName,
      toName: recipientName,
      category: category,
      message: message,
      points: points,
    );

    // Pop twice: closes this Preview screen AND the Give Kudos form
    // behind it, landing back on the wall where the new post is now
    // visible at the top.
    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  Widget build(BuildContext context) {
    final cardBackground = AppColors.surface.resolveFrom(context);
    final borderColor = AppColors.border.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Preview')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Here's how this will appear on the wall:",
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 16),

              // The actual preview card — styled the same as a real
              // card on the wall, so there's no surprise after posting.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$_currentUserName → $recipientName',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.karmaRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.karmaRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(message, style: const TextStyle(fontSize: 13.5)),
                    if (points > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '⭐ $points points',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemOrange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      color: AppColors.karmaRed,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () => _confirmAndPost(context),
                      child: const Text(
                        'Confirm & Post',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

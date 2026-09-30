import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/current_employee.dart';
import '../state/kudos_state.dart';
import '../theme/app_colors.dart';
import 'give_kudos_screen.dart';

// The wall itself — a feed of kudos posts, newest first.
class KudosScreen extends StatelessWidget {
  const KudosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<KudosState>().posts;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Kudos Wall'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const GiveKudosScreen()),
          ),
          child: const Icon(CupertinoIcons.add_circled_solid),
        ),
      ),
      child: SafeArea(
        child: posts.isEmpty
            ? const Center(
                child: Text(
                  'No kudos posted yet — be the first!',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return _kudosCard(context, posts[index]);
                },
              ),
      ),
    );
  }

  Widget _kudosCard(BuildContext context, KudosPost post) {
    final cardBackground = AppColors.surface.resolveFrom(context);
    final borderColor = AppColors.border.resolveFrom(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  '${post.fromName} → ${post.toName}',
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
                  post.category,
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

          Text(post.message, style: const TextStyle(fontSize: 13.5)),

          if (post.points > 0) ...[
            const SizedBox(height: 6),
            Text(
              '⭐ ${post.points} points',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemOrange,
              ),
            ),
          ],

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _timeAgo(post.postedAt),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: CupertinoColors.systemGrey,
                ),
              ),

              Row(
                children: [
                  // Reaction — tapping increments the count directly.
                  GestureDetector(
                    onTap: () => context.read<KudosState>().addReaction(post),
                    child: Row(
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${post.reactionCount}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Comments — tapping opens the comments sheet.
                  GestureDetector(
                    onTap: () => _showComments(context, post),
                    child: Row(
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${post.comments.length}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context, KudosPost post) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        // A separate StatefulWidget for the sheet's content, since
        // typing a new comment needs its own local text state —
        // something this StatelessWidget screen can't hold itself.
        return _CommentsSheet(post: post);
      },
    );
  }

  String _timeAgo(DateTime postedAt) {
    final diff = DateTime.now().difference(postedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// The bottom sheet showing a post's comments plus a field to add a
// new one. Kept private to this file since nothing else needs it.
class _CommentsSheet extends StatefulWidget {
  final KudosPost post;
  const _CommentsSheet({required this.post});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // "Bishwas Sigdel" stands in for the logged-in user, same
    // assumption used everywhere else without real login yet.
    context.read<KudosState>().addComment(widget.post, currentEmployee.name, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch here (not in the parent) so ONLY this sheet
    // rebuilds when a new comment is added — the wall behind it
    // updates too since both read the same KudosState, but this
    // sheet doesn't need to re-fetch anything manually.
    final comments = widget.post.comments;

    return Container(
      height: 420,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: AppColors.surface.resolveFrom(context),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: comments.isEmpty
                ? const Center(
                    child: Text(
                      'No comments yet.',
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.authorName,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              comment.text,
                              style: const TextStyle(fontSize: 13.5),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _controller,
                    placeholder: 'Write a comment...',
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6.resolveFrom(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _submitComment,
                  child: const Icon(
                    CupertinoIcons.arrow_up_circle_fill,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

// Fixed list (not free text) so the wall stays consistent and easy
// to scan — same idea as RequestCategory being an enum instead of
// letting people type anything.
const List<String> kudosCategories = [
  'Teamwork',
  'Helpfulness',
  'Great Work',
  'Innovation',
  'Leadership',
];

// Optional point tiers a giver can attach — purely a fun/gamified
// touch for now, not tied to any real reward or currency system.
const List<int> kudosPointOptions = [0, 5, 10, 20];

/// One comment left on a kudos post.
class KudosComment {
  final String authorName;
  final String text;
  final DateTime postedAt;

  KudosComment({
    required this.authorName,
    required this.text,
    required this.postedAt,
  });
}

/// One "shoutout" from one employee to another.
class KudosPost {
  final String fromName;
  final String toName;
  final String category;
  final String message;
  final DateTime postedAt;
  final int points;

  // Not final — these two change in place (a new reaction, a new
  // comment) without replacing the whole post object.
  int reactionCount;
  final List<KudosComment> comments;

  KudosPost({
    required this.fromName,
    required this.toName,
    required this.category,
    required this.message,
    required this.postedAt,
    this.points = 0,
    this.reactionCount = 0,
    List<KudosComment>? comments,
  }) : comments = comments ?? [];
}

// Shared Provider state — same ChangeNotifier pattern as
// LeaveState/HrRequestState/AttendanceState.
class KudosState extends ChangeNotifier {
  // Seeded with two examples (one with points + a comment already on
  // it) so the wall demonstrates every feature on first open.
  final List<KudosPost> _posts = [
    KudosPost(
      fromName: 'Suresh Karki',
      toName: 'Bishwas Sigdel',
      category: 'Great Work',
      message:
          'Thanks for getting the onboarding docs done ahead of schedule!',
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
      points: 10,
      reactionCount: 4,
      comments: [
        KudosComment(
          authorName: 'Anita Shrestha',
          text: 'Well deserved!',
          postedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
    KudosPost(
      fromName: 'Anita Shrestha',
      toName: 'Sita Gurung',
      category: 'Teamwork',
      message: 'Really appreciated you covering for me during my leave.',
      postedAt: DateTime.now().subtract(const Duration(hours: 6)),
      reactionCount: 2,
    ),
  ];

  List<KudosPost> get posts => List.unmodifiable(_posts);

  void giveKudos({
    required String fromName,
    required String toName,
    required String category,
    required String message,
    int points = 0,
  }) {
    _posts.insert(
      0,
      KudosPost(
        fromName: fromName,
        toName: toName,
        category: category,
        message: message,
        postedAt: DateTime.now(),
        points: points,
      ),
    );
    notifyListeners();
  }

  void addReaction(KudosPost post) {
    post.reactionCount++;
    notifyListeners();
  }

  void addComment(KudosPost post, String authorName, String text) {
    post.comments.add(
      KudosComment(authorName: authorName, text: text, postedAt: DateTime.now()),
    );
    notifyListeners();
  }
}

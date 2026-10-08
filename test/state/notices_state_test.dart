import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/data/notices_data.dart';
import 'package:my_first_flutter_app/state/notices_state.dart';

void main() {
  group('NoticesState', () {
    test('starts with the existing demo notices', () {
      expect(NoticesState().notices.length, demoNotices.length);
    });

    test('publish puts the notice first, dated today', () {
      final state = NoticesState();
      final ok = state.publish(
        title: '  Office picnic  ',
        category: 'General',
        body: ' Bring a friend. ',
        now: DateTime(2026, 10, 5),
      );

      expect(ok, isTrue);
      final first = state.notices.first;
      expect(first.title, 'Office picnic');
      expect(first.body, 'Bring a friend.');
      expect(first.date, 'Oct 5, 2026');
      expect(first.category, 'General');
      expect(state.notices.length, demoNotices.length + 1);
    });

    test('a notice needs a title and a body', () {
      final state = NoticesState();
      var notified = 0;
      state.addListener(() => notified++);

      expect(state.publish(title: '', category: 'General', body: 'x'), isFalse);
      expect(
        state.publish(title: 'x', category: 'General', body: '  '),
        isFalse,
      );

      expect(state.notices.length, demoNotices.length);
      expect(notified, 0);
    });

    test('remove deletes just that notice', () {
      final state = NoticesState();
      final target = state.notices.first;
      state.remove(target);
      expect(state.notices.length, demoNotices.length - 1);
      expect(state.notices.contains(target), isFalse);
    });

    test('removing something that is not there does not notify', () {
      final state = NoticesState();
      var notified = 0;
      state.addListener(() => notified++);
      state.remove(
        const Notice(title: 'x', date: 'd', category: 'c', body: 'b'),
      );
      expect(notified, 0);
    });

    test('every category the form offers is one the screens know', () {
      expect(noticeCategories, ['General', 'Urgent', 'Policy', 'Holiday']);
    });
  });
}

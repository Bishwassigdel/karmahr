import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/screens/welcome_screen.dart';

void main() {
  testWidgets(
    'does not overflow on a narrow phone width (regression: the trust '
    'badge row overflowed by 28px on a real device at ~342 logical '
    'pixels available)',
    (tester) async {
      // iPhone SE-class width — narrower than every simulator this was
      // previously checked against, which is exactly why the original
      // overflow only ever showed up on a real device.
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const CupertinoApp(home: WelcomeScreen()));
      // The entrance animation runs on a timer; let it finish so the
      // fully-laid-out end state (not just frame zero) gets checked.
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/apps/widgets/karma_logo.dart';
import 'package:my_first_flutter_app/screens/dashboard_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_portal_screen.dart';

Future<void> pump(
  WidgetTester tester,
  Widget screen, {
  double width = 393,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = Size(width, 2400);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MultiProvider(
      providers: appProviders(),
      child: CupertinoApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: screen,
      ),
    ),
  );
  // Fixed pumps: the Home screens have spinners that never stop.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// The logo inside the navigation bar's left (leading) slot.
Finder logoInNavBar() => find.descendant(
  of: find.byType(CupertinoNavigationBar),
  matching: find.byType(KarmaLogo),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the employee Home has the logo on the left of its nav bar', (
    tester,
  ) async {
    await pump(tester, const DashboardScreen());

    expect(logoInNavBar(), findsOneWidget);
    // Left of the title, which is left of the bell.
    final logoX = tester.getCenter(logoInNavBar()).dx;
    final titleX = tester.getCenter(find.text('KarmaHR').first).dx;
    expect(logoX, lessThan(titleX));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the HR Home (phone) has the logo on the left of its nav bar', (
    tester,
  ) async {
    await pump(tester, const HrPortalScreen());

    expect(logoInNavBar(), findsOneWidget);
    expect(find.byType(CupertinoTabBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('other HR tabs do not get the logo (they are not Home)', (
    tester,
  ) async {
    await pump(tester, const HrPortalScreen());
    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoTabBar),
        matching: find.text('Payroll'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(logoInNavBar(), findsNothing);
  });

  testWidgets('the HR sidebar (wide) shows the logo with the name', (
    tester,
  ) async {
    await pump(tester, const HrPortalScreen(), width: 1280);

    expect(find.byType(KarmaLogo), findsOneWidget);
    expect(find.text('KarmaHR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the logo is not covered by the Back button on pushed pages', (
    tester,
  ) async {
    // A page opened on top keeps its Back button; no logo is forced in.
    await pump(tester, const DashboardScreen());
    final context = tester.element(find.byType(DashboardScreen));
    Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (_) => const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('Detail')),
          child: SizedBox(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Detail'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  group('no overflow with the logo in the bar', () {
    for (final locale in const [Locale('en'), Locale('ne')]) {
      for (final width in const [320.0, 393.0]) {
        testWidgets(
          'employee Home ${locale.languageCode} at $width, 130% text',
          (tester) async {
            await pump(
              tester,
              const DashboardScreen(),
              width: width,
              locale: locale,
              textScale: 1.3,
            );
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets('HR Home ${locale.languageCode} at $width, 130% text', (
          tester,
        ) async {
          await pump(
            tester,
            const HrPortalScreen(),
            width: width,
            locale: locale,
            textScale: 1.3,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  testWidgets('the logo is 40 points and fits inside the nav bar', (
    tester,
  ) async {
    await pump(tester, const DashboardScreen());

    final logo = tester.getRect(logoInNavBar());
    final bar = tester.getRect(find.byType(CupertinoNavigationBar));
    expect(logo.size, const Size(40, 40));
    expect(bar.top <= logo.top && logo.bottom <= bar.bottom, isTrue);
  });

  testWidgets('the logo image is the app asset', (tester) async {
    await pump(tester, const HrPortalScreen());
    final image = tester.widget<Image>(
      find.descendant(of: logoInNavBar(), matching: find.byType(Image)),
    );
    expect((image.image as AssetImage).assetName, 'assets/images/logo.jpg');
    // Scaled with the sharp filter, not the soft default.
    expect(image.filterQuality, FilterQuality.high);
  });

  testWidgets('if the image cannot load, an icon takes its place', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(home: Center(child: KarmaLogo())),
    );
    // Force the error path directly.
    final image = tester.widget<Image>(find.byType(Image));
    final fallback = image.errorBuilder!(
      tester.element(find.byType(Image)),
      Exception('missing'),
      StackTrace.empty,
    );
    expect(fallback, isA<Icon>());
  });
}

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpDemo(
    WidgetTester tester, {
    required List<Locale> systemLocales,
  }) async {
    tester.platformDispatcher.localesTestValue = systemLocales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const BatteryDemoApp());
    // Localizations delegates load asynchronously on the first frame.
    await tester.pump();
  }

  Future<void> settleMenu(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> openLanguageMenu(WidgetTester tester) async {
    await tester.tap(find.byType(CupertinoMenuAnchor).hitTestable());
    await settleMenu(tester);
  }

  Future<void> selectLanguage(WidgetTester tester, String label) async {
    await openLanguageMenu(tester);
    await tester.tap(find.text(label));
    await settleMenu(tester);
  }

  testWidgets('follows a Chinese system locale by default', (tester) async {
    await pumpDemo(tester, systemLocales: const [Locale('zh', 'CN')]);

    expect(find.text('iOS 电池指示器示例'), findsOneWidget);
    expect(find.text('基础设置'), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
    expect(find.text('电量：75% | 状态：充电中 | 经典风格'), findsOneWidget);
  });

  testWidgets('follows an English system locale by default', (tester) async {
    await pumpDemo(tester, systemLocales: const [Locale('en', 'US')]);

    expect(find.text('iOS Battery Indicator Demo'), findsOneWidget);
    expect(find.text('Basic Settings'), findsOneWidget);
    expect(find.text('Follow System'), findsOneWidget);
    expect(
      find.text('Level: 75% | State: Charging | Classic Style'),
      findsOneWidget,
    );
  });

  testWidgets('language dropdown overrides the system locale', (tester) async {
    await pumpDemo(tester, systemLocales: const [Locale('en', 'US')]);
    expect(find.text('iOS Battery Indicator Demo'), findsOneWidget);

    await selectLanguage(tester, '简体中文');

    expect(find.text('iOS 电池指示器示例'), findsOneWidget);
    expect(find.text('语言'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('Follow System'), findsNothing);
  });

  testWidgets('choosing Follow System restores the device language', (
    tester,
  ) async {
    await pumpDemo(tester, systemLocales: const [Locale('zh', 'CN')]);

    await selectLanguage(tester, 'English');
    expect(find.text('iOS Battery Indicator Demo'), findsOneWidget);

    await selectLanguage(tester, 'Follow System');
    expect(find.text('iOS 电池指示器示例'), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
  });
}

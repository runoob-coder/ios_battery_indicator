import 'dart:async';

import 'package:battery_plus_platform_interface/battery_plus_platform_interface.dart';
import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_battery_indicator/ios_battery_indicator.dart';
import 'package:material_ui/material_ui.dart';

/// A fake [BatteryPlatform] installed via `BatteryPlatform.instance`, letting
/// the system-mode tests drive level, state and save-mode reads without any
/// platform channel.
class _FakeBatteryPlatform extends BatteryPlatform {
  _FakeBatteryPlatform({
    this.level = 50,
    this.state = BatteryState.discharging,
    this.inSaveMode = false,
    Duration? levelReadDelay,
  }) : _levelReadDelay = levelReadDelay;

  int level;
  BatteryState state;
  bool inSaveMode;
  final Duration? _levelReadDelay;

  final _stateController = StreamController<BatteryState>.broadcast();
  int levelReads = 0;
  int stateReads = 0;
  int saveModeReads = 0;

  /// Pushes a new state into [onBatteryStateChanged].
  void emitState(BatteryState state) => _stateController.add(state);

  @override
  Future<int> get batteryLevel async {
    levelReads++;
    if (_levelReadDelay != null) {
      await Future.delayed(_levelReadDelay);
    }
    return level;
  }

  @override
  Future<BatteryState> get batteryState async {
    stateReads++;
    return state;
  }

  @override
  Future<bool> get isInBatterySaveMode async {
    saveModeReads++;
    return inSaveMode;
  }

  @override
  Stream<BatteryState> get onBatteryStateChanged => _stateController.stream;

  Future<void> close() => _stateController.close();
}

/// Installs [fake] as the battery platform and restores the previous one when
/// the test finishes.
_FakeBatteryPlatform _installFakeBattery(_FakeBatteryPlatform fake) {
  final original = BatteryPlatform.instance;
  addTearDown(() {
    BatteryPlatform.instance = original;
    fake.close();
  });
  BatteryPlatform.instance = fake;
  return fake;
}

/// Hosts [child] under a material_ui [Theme] — the widget resolves its
/// [BatteryIndicatorTheme] through `Theme.of`, so the host must use the same
/// theme machinery as the widget itself.
Widget _host(Widget child, {ThemeData? theme}) {
  return Theme(
    data: theme ?? ThemeData.light(),
    child: Directionality(
      textDirection: .ltr,
      child: Center(child: child),
    ),
  );
}

/// Counts the bolt glyphs (drawn by the private `_BoltPainter`) currently on
/// screen. `Cutout` extends `Stack` and adds no `CustomPaint` of its own, so
/// this is a reliable way to detect the bolt overlay.
int _boltCount(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .where(
      (cp) =>
          (cp.painter ?? cp.foregroundPainter)?.runtimeType.toString() ==
          '_BoltPainter',
    )
    .length;

Color? _textColor(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

void main() {
  group('manual mode', () {
    testWidgets('renders the percentage label', (tester) async {
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('64'), findsOneWidget);
    });

    testWidgets('hides the percentage when showBatteryPercentage is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
            showBatteryPercentage: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('64'), findsNothing);
      expect(find.byType(IosBatteryIndicator), findsOneWidget);
    });

    testWidgets('treats BatteryState.full as 100%', (tester) async {
      await tester.pumpWidget(
        _host(const IosBatteryIndicator(batteryLevel: 50, batteryState: .full)),
      );
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('applies tabularFigures by default and drops them at 100%', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('64'));
      expect(text.style?.fontFeatures, contains(FontFeature.tabularFigures()));

      await tester.pumpWidget(
        _host(const IosBatteryIndicator(batteryLevel: 64, batteryState: .full)),
      );
      await tester.pumpAndSettle();

      final fullText = tester.widget<Text>(find.text('100'));
      expect(
        fullText.style?.fontFeatures ?? const <FontFeature>[],
        isNot(contains(FontFeature.tabularFigures())),
      );
    });

    testWidgets('uses CupertinoSystemText outside and the bundled rounded '
        'face inside iOS 27 style', (tester) async {
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('64')).style?.fontFamily,
        'CupertinoSystemText',
      );

      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
            isIOS27Style: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('64')).style?.fontFamily,
        // The bundled face is package-scoped, so the merged style carries the
        // fully qualified family name.
        'packages/ios_battery_indicator/SF-Pro-Rounded-Medium',
      );
    });

    testWidgets('renders the bolt only while charging', (tester) async {
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
            showBatteryPercentage: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_boltCount(tester), 0);

      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .charging,
            showBatteryPercentage: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Cutout mask + overlay.
      expect(_boltCount(tester), 2);
    });

    testWidgets('chargingWithBolt: false hides the bolt', (tester) async {
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .charging,
            chargingWithBolt: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_boltCount(tester), 0);
    });

    testWidgets('does not call the system callbacks in manual mode', (
      tester,
    ) async {
      final levels = <int>[];
      final states = <BatteryState>[];

      await tester.pumpWidget(
        _host(
          IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
            onBatteryLevelChanged: levels.add,
            onBatteryStateChanged: states.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(levels, isEmpty);
      expect(states, isEmpty);
    });

    testWidgets('updates the label when the manual level changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('64'), findsOneWidget);

      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 30,
            batteryState: .discharging,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('30'), findsOneWidget);
      expect(find.text('64'), findsNothing);
    });

    testWidgets('renders with a forced brightness', (tester) async {
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
            brightness: .dark,
          ),
          theme: ThemeData(brightness: .light),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('64'), findsOneWidget);
    });

    testWidgets('honors a custom BatteryIndicatorTheme extension', (
      tester,
    ) async {
      final custom = BatteryIndicatorTheme.dark().copyWith(
        dischargingTrackColor: CupertinoColors.systemPurple,
      );

      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevel: 64,
            batteryState: .discharging,
          ),
          theme: ThemeData(extensions: [custom]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('64'), findsOneWidget);
    });

    testWidgets('respects the height constraint', (tester) async {
      await tester.pumpWidget(
        _host(
          const Center(
            child: IosBatteryIndicator(
              height: 24,
              batteryLevel: 64,
              batteryState: .discharging,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(IosBatteryIndicator)).height, 24);
    });

    testWidgets('renders at extreme sizes without overflow', (tester) async {
      for (final size in const [10.0, 150.0]) {
        await tester.pumpWidget(
          _host(
            Center(
              child: IosBatteryIndicator(
                height: size,
                batteryLevel: 64,
                batteryState: .charging,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    test('asserts reject invalid configurations', () {
      expect(
        () => IosBatteryIndicator(batteryLevel: 101),
        throwsAssertionError,
      );
      expect(() => IosBatteryIndicator(batteryLevel: -1), throwsAssertionError);
      expect(
        () => IosBatteryIndicator(height: 10, width: 10),
        throwsAssertionError,
      );
      expect(
        () => IosBatteryIndicator(lowBatteryThreshold: 9),
        throwsAssertionError,
      );
      expect(
        () => IosBatteryIndicator(lowBatteryThreshold: 31),
        throwsAssertionError,
      );
      expect(
        () => IosBatteryIndicator(
          isInBatterySaveMode: true,
          monitorBatterySaveMode: true,
        ),
        throwsAssertionError,
      );
    });

    test('accepts valid boundary configurations', () {
      expect(() => IosBatteryIndicator(batteryLevel: 0), returnsNormally);
      expect(() => IosBatteryIndicator(batteryLevel: 100), returnsNormally);
      expect(() => IosBatteryIndicator(height: 24), returnsNormally);
      expect(() => IosBatteryIndicator(width: 24), returnsNormally);
      expect(
        () => IosBatteryIndicator(lowBatteryThreshold: 10),
        returnsNormally,
      );
      expect(
        () => IosBatteryIndicator(lowBatteryThreshold: 30),
        returnsNormally,
      );
      expect(
        () => IosBatteryIndicator(monitorBatterySaveMode: true),
        returnsNormally,
      );
    });
  });

  group('system mode', () {
    testWidgets('reads level, state and save mode from the system on mount', (
      tester,
    ) async {
      final fake = _installFakeBattery(
        _FakeBatteryPlatform(
          level: 42,
          state: BatteryState.charging,
          inSaveMode: true,
        ),
      );

      await tester.pumpWidget(_host(const IosBatteryIndicator()));
      await tester.pump();

      expect(find.text('42'), findsOneWidget);
      expect(fake.levelReads, 1);
      expect(fake.stateReads, 1);
      expect(fake.saveModeReads, 1);

      await tester.pumpWidget(_host(const SizedBox()));
    });

    testWidgets('fires the system callbacks with the initial values', (
      tester,
    ) async {
      final fake = _installFakeBattery(
        _FakeBatteryPlatform(level: 42, state: BatteryState.discharging),
      );
      final levels = <int>[];
      final states = <BatteryState>[];

      await tester.pumpWidget(
        _host(
          IosBatteryIndicator(
            onBatteryLevelChanged: levels.add,
            onBatteryStateChanged: states.add,
          ),
        ),
      );
      await tester.pump();

      expect(levels, [42]);
      expect(states, [BatteryState.discharging]);
      expect(fake.levelReads, 1);
      expect(fake.stateReads, 1);

      await tester.pumpWidget(_host(const SizedBox()));
    });

    testWidgets('updates on streamed state changes and syncs the level', (
      tester,
    ) async {
      final fake = _installFakeBattery(
        _FakeBatteryPlatform(level: 42, state: BatteryState.discharging),
      );

      await tester.pumpWidget(_host(const IosBatteryIndicator()));
      await tester.pump();
      expect(_boltCount(tester), 0);

      fake.emitState(BatteryState.charging);
      await tester.pump();
      // The style flips from cutout to plain, which cross-fades the battery
      // subtree — wait for the animation before counting the bolt.
      await tester.pump(const Duration(milliseconds: 300));

      expect(_boltCount(tester), 1);
      // The level is re-read when the state changes.
      expect(fake.levelReads, 2);

      await tester.pumpWidget(_host(const SizedBox()));
    });

    testWidgets('applies a streamed discharging transition immediately on '
        'non-iOS hosts', (tester) async {
      // The 1-second deferred "charging → discharging" commit is gated on
      // Platform.isIOS and cannot be exercised on the default test host; the
      // token guard around it is covered by the immediate path below.
      final fake = _installFakeBattery(
        _FakeBatteryPlatform(level: 42, state: BatteryState.charging),
      );

      await tester.pumpWidget(_host(const IosBatteryIndicator()));
      await tester.pump();
      expect(_boltCount(tester), 1);

      fake.emitState(BatteryState.discharging);
      await tester.pump();
      // Wait for the plain → cutout cross-fade to finish.
      await tester.pump(const Duration(milliseconds: 300));

      expect(_boltCount(tester), 0);

      await tester.pumpWidget(_host(const SizedBox()));
    });

    testWidgets('polls the battery level on batteryLevelPollInterval', (
      tester,
    ) async {
      final fake = _installFakeBattery(_FakeBatteryPlatform(level: 42));

      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevelPollInterval: Duration(seconds: 10),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('42'), findsOneWidget);
      expect(fake.levelReads, 1);

      fake.level = 7;
      await tester.pump(const Duration(seconds: 9));
      expect(find.text('42'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('7'), findsOneWidget);
      expect(fake.levelReads, 2);

      await tester.pumpWidget(_host(const SizedBox()));
    });

    testWidgets('restarts the level poll timer when the interval changes', (
      tester,
    ) async {
      final fake = _installFakeBattery(_FakeBatteryPlatform(level: 42));

      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevelPollInterval: Duration(seconds: 10),
          ),
        ),
      );
      await tester.pump();

      fake.level = 7;
      await tester.pump(const Duration(seconds: 11)); // one poll at t=10s
      expect(find.text('7'), findsOneWidget);

      // Switch to a 60s interval: the timer restarts (re-reading the level
      // immediately), so the old 10s cadence must not fire anymore.
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            batteryLevelPollInterval: Duration(seconds: 60),
          ),
        ),
      );
      await tester.pump(); // immediate re-read on restart (still 7)
      expect(find.text('7'), findsOneWidget);
      expect(fake.levelReads, 3); // initial + poll + restart read

      // Only now change the level, so any further read can be attributed to
      // the new timer.
      fake.level = 8;
      await tester.pump(const Duration(seconds: 20)); // t=31s: no poll
      expect(find.text('7'), findsOneWidget);
      expect(fake.levelReads, 3);

      await tester.pump(const Duration(seconds: 40)); // t=71s: new timer fires
      expect(find.text('8'), findsOneWidget);

      await tester.pumpWidget(_host(const SizedBox()));
    });

    testWidgets('starts and stops save-mode polling with '
        'monitorBatterySaveMode', (tester) async {
      final fake = _installFakeBattery(
        _FakeBatteryPlatform(level: 42, inSaveMode: false),
      );

      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            saveModePollInterval: Duration(seconds: 10),
          ),
        ),
      );
      await tester.pump();
      expect(fake.saveModeReads, 1); // initial read only

      // Monitoring disabled: no polls.
      await tester.pump(const Duration(seconds: 30));
      expect(fake.saveModeReads, 1);

      // Enable monitoring at runtime.
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            monitorBatterySaveMode: true,
            saveModePollInterval: Duration(seconds: 10),
          ),
        ),
      );
      await tester.pump();

      fake.inSaveMode = true;
      await tester.pump(const Duration(seconds: 10));
      expect(fake.saveModeReads, 2);
      // Save mode switches the percentage text to the plain style, whose
      // color is black (readable on the yellow track). The style flip
      // cross-fades the battery subtree, so let the animation finish first.
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        _textColor(tester, '42')?.toARGB32(),
        CupertinoColors.black.toARGB32(),
      );

      // Disable again: the timer stops.
      await tester.pumpWidget(
        _host(
          const IosBatteryIndicator(
            monitorBatterySaveMode: false,
            saveModePollInterval: Duration(seconds: 10),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      expect(fake.saveModeReads, 2);

      await tester.pumpWidget(_host(const SizedBox()));
    });

    testWidgets('a manual save mode keeps system level and state monitoring '
        'alive', (tester) async {
      final fake = _installFakeBattery(
        _FakeBatteryPlatform(level: 42, state: BatteryState.discharging),
      );

      await tester.pumpWidget(_host(const IosBatteryIndicator()));
      await tester.pump();
      expect(find.text('42'), findsOneWidget);

      // Manual save mode only — level and state stay in system mode.
      await tester.pumpWidget(
        _host(const IosBatteryIndicator(isInBatterySaveMode: true)),
      );
      await tester.pump();

      fake.level = 7;
      await tester.pump(const Duration(seconds: 31)); // default 30s interval
      expect(find.text('7'), findsOneWidget);

      fake.emitState(BatteryState.charging);
      await tester.pump();
      expect(_boltCount(tester), 1);

      await tester.pumpWidget(_host(const SizedBox()));
    });

    testWidgets('a platform read resolving after dispose does not throw', (
      tester,
    ) async {
      _installFakeBattery(
        _FakeBatteryPlatform(levelReadDelay: const Duration(seconds: 5)),
      );

      await tester.pumpWidget(_host(const IosBatteryIndicator()));
      await tester.pump(); // the reads are still pending

      // Unmount before the platform read resolves.
      await tester.pumpWidget(_host(const SizedBox()));

      // Without the mounted guard this would call setState after dispose
      // and leave the poll timer running forever.
      await tester.pump(const Duration(seconds: 6));

      expect(tester.takeException(), isNull);
    });
  });
}

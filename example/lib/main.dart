import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widget_previews.dart';
import 'package:ios_battery_indicator/ios_battery_indicator.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const BatteryDemoApp());
}

class BatteryDemoApp extends StatefulWidget {
  const BatteryDemoApp({super.key});

  @override
  State<BatteryDemoApp> createState() => _BatteryDemoAppState();
}

class _BatteryDemoAppState extends State<BatteryDemoApp> {
  double _batteryLevel = 75;

  BatteryState _batteryState = .charging;

  bool _useSystemBattery = false;

  bool _isInBatterySaveMode = false;

  bool _monitorBatterySaveMode = false;

  bool _showBatteryPercentage = false;

  bool _useTabularFigures = false;

  bool _chargingWithBolt = true;

  bool _playChargingSound = true;

  bool _isIOS27Style = false;

  Brightness _brightness = .light;

  int _lowBatteryThreshold = 20;

  double _widgetSize = 24;

  /// A null locale means "follow the system language", which is the default.
  Locale? _locale;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalCupertinoLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: CupertinoThemeData(brightness: _brightness),
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return CupertinoPageScaffold(
            backgroundColor: CupertinoColors.systemGrey6,
            navigationBar: CupertinoNavigationBar(middle: Text(l10n.appTitle)),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: .max,
                children: [
                  /// Preview section
                  _buildPreviewSection(l10n),

                  /// Controls section
                  Expanded(child: _buildControlsSection(l10n)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectLocale(Locale? locale) => setState(() => _locale = locale);

  String _languageLabel(AppLocalizations l10n) {
    if (_locale == null) return l10n.languageFollowSystem;
    return _locale!.languageCode == 'zh'
        ? l10n.languageChinese
        : l10n.languageEnglish;
  }

  Widget _buildLanguageMenu(AppLocalizations l10n) {
    return CupertinoMenuAnchor(
      menuChildren: [
        CupertinoMenuItem(
          trailing: _locale == null
              ? const Icon(CupertinoIcons.check_mark)
              : null,
          onPressed: () => _selectLocale(null),
          child: Text(l10n.languageFollowSystem),
        ),
        CupertinoMenuItem(
          trailing: _locale?.languageCode == 'en'
              ? const Icon(CupertinoIcons.check_mark)
              : null,
          onPressed: () => _selectLocale(const Locale('en')),
          child: Text(l10n.languageEnglish),
        ),
        CupertinoMenuItem(
          trailing: _locale?.languageCode == 'zh'
              ? const Icon(CupertinoIcons.check_mark)
              : null,
          onPressed: () => _selectLocale(const Locale('zh')),
          child: Text(l10n.languageChinese),
        ),
      ],
      builder: (context, controller, _) => CupertinoButton(
        padding: const .symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        child: Row(
          mainAxisSize: .min,
          children: [
            Text(_languageLabel(l10n)),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_down, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(AppLocalizations l10n) {
    return Container(
      width: .infinity,
      padding: const .symmetric(vertical: 20),
      margin: const .all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: .topLeft,
          end: .bottomRight,
          colors: [
            CupertinoColors.systemBlue.withValues(alpha: .3),
            CupertinoColors.systemPurple.withValues(alpha: .3),
          ],
        ),
        borderRadius: .circular(16),
      ),
      child: Column(
        spacing: 16,
        children: [
          /// Battery indicator preview
          IosBatteryIndicator(
            height: _widgetSize,
            batteryLevel: _useSystemBattery ? null : _batteryLevel.round(),
            batteryLevelPollInterval: const Duration(seconds: 10),
            batteryState: _useSystemBattery ? null : _batteryState,
            // Only fires when batteryLevel/batteryState is null (system mode).
            onBatteryLevelChanged: (level) =>
                setState(() => _batteryLevel = level.toDouble()),
            onBatteryStateChanged: (state) =>
                setState(() => _batteryState = state),
            // In system mode the save mode is read from the device, so the
            // monitor switch below takes effect. In manual mode the explicit
            // value is used instead.
            isInBatterySaveMode: _useSystemBattery && _monitorBatterySaveMode
                ? null
                : _isInBatterySaveMode,
            monitorBatterySaveMode:
                _useSystemBattery && _monitorBatterySaveMode,
            showBatteryPercentage: _showBatteryPercentage,
            fontFeatures: _useTabularFigures ? const [.tabularFigures()] : null,
            chargingWithBolt: _chargingWithBolt,
            playChargingSound: _playChargingSound,
            isIOS27Style: _isIOS27Style,
            brightness: _brightness,
            lowBatteryThreshold: _lowBatteryThreshold,
          ),

          /// Current status info
          Container(
            padding: const .symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill,
              borderRadius: .circular(8),
            ),
            child: Text(
              _getStatusText(l10n),
              style: TextStyle(fontSize: 16),
              maxLines: 2,
              textAlign: .center,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(AppLocalizations l10n) {
    final levelStr = l10n.percentValue('${_batteryLevel.round()}');
    final stateStr = switch (_batteryState) {
      .discharging => l10n.stateDischarging,
      .charging => l10n.stateCharging,
      .full => l10n.stateFull,
      .connectedNotCharging => l10n.stateConnectedNotCharging,
      .unknown => l10n.stateUnknown,
    };
    final styleStr = _isIOS27Style ? l10n.styleIOS27 : l10n.styleClassic;

    return l10n.statusLine(levelStr, stateStr, styleStr);
  }

  Widget _buildControlsSection(AppLocalizations l10n) {
    return ListView(
      padding: .zero,
      children: [
        /// Language
        CupertinoListSection.insetGrouped(
          header: Text(l10n.languageSectionHeader),
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.globe),
              title: Text(l10n.languageSetting),
              trailing: _buildLanguageMenu(l10n),
            ),
          ],
        ),

        /// Basic Settings
        CupertinoListSection.insetGrouped(
          header: Text(l10n.basicSettings),
          hasLeading: kIsWeb ? true : false,
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.battery_full),
              title: Text(l10n.useSystemBattery),
              trailing: CupertinoSwitch(
                value: _useSystemBattery,
                onChanged: (v) => setState(() => _useSystemBattery = v),
              ),
            ),
            if (!_useSystemBattery) ...[
              if (_batteryState != .full)
                CupertinoListTile(
                  leading: kIsWeb
                      ? const Icon(CupertinoIcons.battery_full)
                      : null,
                  title: Text(l10n.batteryLevel),
                  additionalInfo: Text(
                    l10n.percentValue('${_batteryLevel.round()}'),
                    style: TextStyle(
                      color: _useSystemBattery
                          ? CupertinoColors.secondaryLabel
                          : CupertinoColors.activeBlue,
                    ),
                  ),
                  trailing: SizedBox(
                    width: kIsWeb ? null : 150,
                    child: CupertinoSlider(
                      value: _batteryLevel,
                      min: 1,
                      max: 100,
                      onChanged: _useSystemBattery
                          ? null
                          : (v) => setState(() => _batteryLevel = v),
                    ),
                  ),
                ),
              CupertinoListTile(
                leading: kIsWeb ? const Icon(CupertinoIcons.bolt) : null,
                title: Text(l10n.batteryState),
                trailing: SizedBox(
                  child: CupertinoSlidingSegmentedControl<BatteryState>(
                    // Only the three iOS-selectable states are shown. Android may
                    // report `connectedNotCharging`/`unknown` from system mode;
                    // clamp those to a valid key so the control never overflows
                    // its keys assertion.
                    groupValue:
                        const <BatteryState>{
                          .discharging,
                          .charging,
                          .full,
                        }.contains(_batteryState)
                        ? _batteryState
                        : .charging,
                    proportionalWidth: kIsWeb ? false : true,
                    children: {
                      .discharging: Text(l10n.stateDischarging),
                      .charging: Text(l10n.stateCharging),
                      .full: Text(l10n.stateFull),
                    },
                    onValueChanged: (v) {
                      if (!_useSystemBattery && v != null) {
                        setState(() => _batteryState = v);
                      }
                    },
                  ),
                ),
              ),
            ] else ...[
              if (!kIsWeb && !Platform.isLinux)
                CupertinoListTile(
                  title: Text(l10n.monitorBatterySaveMode),
                  subtitle: Text(l10n.monitorBatterySaveModeHint),
                  trailing: CupertinoSwitch(
                    value: _monitorBatterySaveMode,
                    onChanged: (v) =>
                        setState(() => _monitorBatterySaveMode = v),
                  ),
                ),
            ],
          ],
        ),

        /// Display Options
        CupertinoListSection.insetGrouped(
          header: Text(l10n.displayOptions),
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.percent),
              title: Text(l10n.showBatteryPercentage),
              trailing: CupertinoSwitch(
                value: _showBatteryPercentage,
                onChanged: (v) => setState(() => _showBatteryPercentage = v),
              ),
            ),
            if (_showBatteryPercentage)
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.textformat),
                title: Text(l10n.useTabularFigures),
                subtitle: Text(l10n.useTabularFiguresHint, maxLines: 2),
                trailing: CupertinoSwitch(
                  value: _useTabularFigures,
                  onChanged: (v) => setState(() => _useTabularFigures = v),
                ),
              ),

            if (!_useSystemBattery && !kIsWeb && Platform.isIOS)
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.speaker_2_fill),
                title: Text(l10n.playChargingSound),
                subtitle: Text(l10n.playChargingSoundHint),
                trailing: CupertinoSwitch(
                  value: _playChargingSound,
                  onChanged: (v) => setState(() => _playChargingSound = v),
                ),
              ),
            if (_batteryState == .charging)
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.bolt_fill),
                title: Text(l10n.showBoltWhenCharging),
                trailing: CupertinoSwitch(
                  value: _chargingWithBolt,
                  onChanged: (v) => setState(() => _chargingWithBolt = v),
                ),
              ),
            if (!_monitorBatterySaveMode)
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.moon_fill),
                title: Text(l10n.batterySaveMode),
                trailing: CupertinoSwitch(
                  value: _isInBatterySaveMode,
                  onChanged: (v) => setState(() => _isInBatterySaveMode = v),
                ),
              ),
          ],
        ),

        /// Style Settings
        CupertinoListSection.insetGrouped(
          header: Text(l10n.styleSettings),
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.app_badge),
              title: Text(l10n.styleIOS27),
              subtitle: Text(l10n.ios27StyleHint),
              trailing: CupertinoSwitch(
                value: _isIOS27Style,
                onChanged: (v) => setState(() => _isIOS27Style = v),
              ),
            ),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.sun_max_fill),
              title: Text(l10n.themeBrightness),
              trailing: CupertinoSlidingSegmentedControl<Brightness>(
                groupValue: _brightness,
                children: {
                  .light: Text(l10n.brightnessLight),
                  .dark: Text(l10n.brightnessDark),
                },
                onValueChanged: (v) {
                  if (v != null) setState(() => _brightness = v);
                },
              ),
            ),
          ],
        ),

        /// Advanced Settings
        CupertinoListSection.insetGrouped(
          header: Text(l10n.advancedSettings),
          hasLeading: kIsWeb ? true : false,
          children: [
            CupertinoListTile(
              leading: kIsWeb ? const Icon(CupertinoIcons.resize) : null,
              title: Text(l10n.widgetSize),
              additionalInfo: Text(
                '${_widgetSize.round()}',
                style: const TextStyle(color: CupertinoColors.activeBlue),
              ),
              trailing: SizedBox(
                width: kIsWeb ? null : 150,
                child: CupertinoSlider(
                  value: _widgetSize,
                  min: 10,
                  max: 150,
                  onChanged: (v) => setState(() => _widgetSize = v),
                ),
              ),
            ),
            CupertinoListTile(
              leading: kIsWeb
                  ? const Icon(CupertinoIcons.exclamationmark_triangle)
                  : null,
              title: Text(l10n.lowBatteryThreshold, maxLines: 2),
              additionalInfo: Text(
                l10n.percentValue('${_lowBatteryThreshold.round()}'),
                style: const TextStyle(color: CupertinoColors.activeBlue),
              ),
              trailing: SizedBox(
                width: kIsWeb ? null : 150,
                child: CupertinoSlider(
                  value: _lowBatteryThreshold.toDouble(),
                  min: 10,
                  max: 30,
                  onChanged: (v) =>
                      setState(() => _lowBatteryThreshold = v.round()),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ============================================================================
// Widget Previews
// ============================================================================

final class BatteryIndicatorPreview extends Preview {
  const BatteryIndicatorPreview({
    super.name,
    super.group,
    super.size = const Size(.infinity, 100),
    super.textScaleFactor,
    super.wrapper,
    super.brightness,
    super.localizations,
  }) : super(theme: BatteryIndicatorPreview.themeBuilder);

  static PreviewThemeData themeBuilder() {
    return _CupertinoPreviewTheme(
      light: CupertinoThemeData(brightness: .light),
      dark: CupertinoThemeData(brightness: .dark),
    );
  }
}

final class _CupertinoPreviewTheme extends PreviewThemeData {
  const _CupertinoPreviewTheme({this.light, this.dark});

  final CupertinoThemeData? light;
  final CupertinoThemeData? dark;

  @override
  Widget apply(BuildContext context, Widget child) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    return CupertinoTheme(
      data: brightness == .dark
          ? (dark ?? const CupertinoThemeData(brightness: .dark))
          : (light ?? const CupertinoThemeData(brightness: .light)),
      child: child,
    );
  }
}

// ---- 电量状态（显示百分比）/ Battery States (with percentage) ----
@BatteryIndicatorPreview(
  name: 'Discharging',
  group: 'Battery States (with percentage)',
)
Widget stateDischarging() =>
    IosBatteryIndicator(batteryLevel: 64, batteryState: .discharging);

@BatteryIndicatorPreview(
  name: 'Charging',
  group: 'Battery States (with percentage)',
)
Widget stateCharging() =>
    IosBatteryIndicator(batteryLevel: 64, batteryState: .charging);

@BatteryIndicatorPreview(
  name: 'Full',
  group: 'Battery States (with percentage)',
)
Widget stateFull() =>
    IosBatteryIndicator(batteryLevel: 100, batteryState: .full);

@BatteryIndicatorPreview(
  name: 'Low battery',
  group: 'Battery States (with percentage)',
)
Widget stateLow() =>
    IosBatteryIndicator(batteryLevel: 12, batteryState: .discharging);

@BatteryIndicatorPreview(
  name: 'Low Power Mode',
  group: 'Battery States (with percentage)',
)
Widget saveMode() => IosBatteryIndicator(
  batteryLevel: 70,
  batteryState: .discharging,
  isInBatterySaveMode: true,
);

@BatteryIndicatorPreview(
  name: 'Low Power Mode (charging)',
  group: 'Battery States (with percentage)',
)
Widget saveModeCharging() => IosBatteryIndicator(
  batteryLevel: 25,
  batteryState: .charging,
  isInBatterySaveMode: true,
);

// ---- 电量状态（显示百分比 / iOS 27 风格）/ Battery States (with percentage, iOS 27) ----
@BatteryIndicatorPreview(
  name: 'Discharging',
  group: 'Battery States (with percentage, iOS 27)',
)
Widget stateDischargingIOS27Pct() => IosBatteryIndicator(
  batteryLevel: 64,
  batteryState: .discharging,
  isIOS27Style: true,
);

@BatteryIndicatorPreview(
  name: 'Charging',
  group: 'Battery States (with percentage, iOS 27)',
)
Widget stateChargingIOS27Pct() => IosBatteryIndicator(
  batteryLevel: 64,
  batteryState: .charging,
  isIOS27Style: true,
);

@BatteryIndicatorPreview(
  name: 'Full',
  group: 'Battery States (with percentage, iOS 27)',
)
Widget stateFullIOS27Pct() => IosBatteryIndicator(
  batteryLevel: 100,
  batteryState: .full,
  isIOS27Style: true,
);

@BatteryIndicatorPreview(
  name: 'Low battery',
  group: 'Battery States (with percentage, iOS 27)',
)
Widget stateLowIOS27Pct() => IosBatteryIndicator(
  batteryLevel: 12,
  batteryState: .discharging,
  isIOS27Style: true,
);

@BatteryIndicatorPreview(
  name: 'Low Power Mode',
  group: 'Battery States (with percentage, iOS 27)',
)
Widget saveModeIOS27Pct() => IosBatteryIndicator(
  batteryLevel: 70,
  batteryState: .discharging,
  isInBatterySaveMode: true,
  isIOS27Style: true,
);

@BatteryIndicatorPreview(
  name: 'Low Power Mode (charging)',
  group: 'Battery States (with percentage, iOS 27)',
)
Widget saveModeChargingIOS27Pct() => IosBatteryIndicator(
  batteryLevel: 25,
  batteryState: .charging,
  isInBatterySaveMode: true,
  isIOS27Style: true,
);

// ---- 电量状态（隐藏百分比）/ Battery States (no percentage) ----
@BatteryIndicatorPreview(
  name: 'Discharging',
  group: 'Battery States (no percentage)',
)
Widget stateDischargingHidden() => IosBatteryIndicator(
  batteryLevel: 64,
  batteryState: .discharging,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(
  name: 'Charging',
  group: 'Battery States (no percentage)',
)
Widget stateChargingHidden() => IosBatteryIndicator(
  batteryLevel: 64,
  batteryState: .charging,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(name: 'Full', group: 'Battery States (no percentage)')
Widget stateFullHidden() => IosBatteryIndicator(
  batteryLevel: 100,
  batteryState: .full,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(
  name: 'Low battery',
  group: 'Battery States (no percentage)',
)
Widget stateLowHidden() => IosBatteryIndicator(
  batteryLevel: 12,
  batteryState: .discharging,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(
  name: 'Low Power Mode',
  group: 'Battery States (no percentage)',
)
Widget saveModeHidden() => IosBatteryIndicator(
  batteryLevel: 70,
  batteryState: .discharging,
  isInBatterySaveMode: true,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(
  name: 'Low Power Mode (charging)',
  group: 'Battery States (no percentage)',
)
Widget saveModeChargingHidden() => IosBatteryIndicator(
  batteryLevel: 80,
  batteryState: .charging,
  isInBatterySaveMode: true,
  showBatteryPercentage: false,
);

// ---- 电量状态（隐藏百分比 / iOS 27 风格）/ Battery States (no percentage, iOS 27) ----
@BatteryIndicatorPreview(
  name: 'Discharging',
  group: 'Battery States (no percentage, iOS 27)',
)
Widget stateDischargingIOS27() => IosBatteryIndicator(
  batteryLevel: 64,
  batteryState: .discharging,
  isIOS27Style: true,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(
  name: 'Charging',
  group: 'Battery States (no percentage, iOS 27)',
)
Widget stateChargingIOS27() => IosBatteryIndicator(
  batteryLevel: 64,
  batteryState: .charging,
  isIOS27Style: true,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(
  name: 'Full',
  group: 'Battery States (no percentage, iOS 27)',
)
Widget stateFullIOS27() => IosBatteryIndicator(
  batteryLevel: 100,
  batteryState: .full,
  isIOS27Style: true,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(
  name: 'Low battery',
  group: 'Battery States (no percentage, iOS 27)',
)
Widget stateLowIOS27() => IosBatteryIndicator(
  batteryLevel: 12,
  batteryState: .discharging,
  isIOS27Style: true,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(
  name: 'Low Power Mode',
  group: 'Battery States (no percentage, iOS 27)',
)
Widget saveModeIOS27() => IosBatteryIndicator(
  batteryLevel: 70,
  batteryState: .discharging,
  isInBatterySaveMode: true,
  isIOS27Style: true,
  showBatteryPercentage: false,
);

@BatteryIndicatorPreview(
  name: 'Low Power Mode (charging)',
  group: 'Battery States (no percentage, iOS 27)',
)
Widget saveModeChargingIOS27() => IosBatteryIndicator(
  batteryLevel: 65,
  batteryState: .charging,
  isInBatterySaveMode: true,
  isIOS27Style: true,
  showBatteryPercentage: false,
);

// ---- Animation ----

@BatteryIndicatorPreview(name: 'Long animation', group: 'Animation')
Widget appearanceLongAnimation() => IosBatteryIndicator(
  batteryLevel: 50,
  batteryState: .discharging,
  animationDuration: const Duration(seconds: 1),
);

import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ios_battery_indicator/ios_battery_indicator.dart';

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

  bool _chargingWithBolt = true;

  bool _playChargingSound = true;

  bool _isIOS27Style = false;

  Brightness _brightness = .light;

  int _lowBatteryThreshold = 20;

  double _widgetSize = 24;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(brightness: _brightness),
      home: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGrey6,
        navigationBar: const CupertinoNavigationBar(
          middle: Text('iOS Battery Indicator Demo'),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: .max,
            children: [
              /// Preview section
              _buildPreviewSection(),

              /// Controls section
              Expanded(child: _buildControlsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
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
            monitorBatterySaveMode: _monitorBatterySaveMode,
            showBatteryPercentage: _showBatteryPercentage,
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
              _getStatusText(),
              style: TextStyle(fontSize: 16),
              maxLines: 2,
              textAlign: .center,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    final levelStr = '${_batteryLevel.round()}%';
    final stateStr =
        _batteryState.name[0].toUpperCase() + _batteryState.name.substring(1);
    final styleStr = _isIOS27Style ? 'iOS 27 Style' : 'Classic Style';

    return 'Level: $levelStr | State: $stateStr | $styleStr';
  }

  Widget _buildControlsSection() {
    return ListView(
      padding: .zero,
      children: [
        /// Basic Settings
        CupertinoListSection.insetGrouped(
          header: const Text('Basic Settings'),
          hasLeading: kIsWeb ? true : false,
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.battery_full),
              title: const Text('Use System Battery'),
              trailing: CupertinoSwitch(
                value: _useSystemBattery,
                onChanged: (v) => setState(() => _useSystemBattery = v),
              ),
            ),
            if (!_useSystemBattery) ...[
              CupertinoListTile(
                leading: kIsWeb
                    ? const Icon(CupertinoIcons.battery_full)
                    : null,
                title: const Text('Battery Level'),
                additionalInfo: Text(
                  '${_batteryLevel.round()}%',
                  style: TextStyle(
                    color: _useSystemBattery || _batteryState == .full
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
                    onChanged: _useSystemBattery || _batteryState == .full
                        ? null
                        : (v) => setState(() => _batteryLevel = v),
                  ),
                ),
              ),
              CupertinoListTile(
                leading: kIsWeb ? const Icon(CupertinoIcons.bolt) : null,
                title: const Text('Battery State'),
                trailing: SizedBox(
                  child: CupertinoSlidingSegmentedControl<BatteryState>(
                    groupValue: _batteryState,
                    proportionalWidth: kIsWeb ? false : true,
                    children: const {
                      .discharging: Text('Discharging'),
                      .charging: Text('Charging'),
                      .full: Text('Full'),
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
                  title: const Text('Monitor Battery Save Mode'),
                  subtitle: const Text('Poll Low Power Mode every 30s'),
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
          header: const Text('Display Options'),
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.percent),
              title: const Text('Show Battery Percentage'),
              trailing: CupertinoSwitch(
                value: _showBatteryPercentage,
                onChanged: (v) => setState(() => _showBatteryPercentage = v),
              ),
            ),
            if (!_useSystemBattery && !kIsWeb && Platform.isIOS)
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.speaker_2_fill),
                title: const Text('Play Charging Sound'),
                subtitle: const Text('Only plays when charging'),
                trailing: CupertinoSwitch(
                  value: _playChargingSound,
                  onChanged: (v) => setState(() => _playChargingSound = v),
                ),
              ),
            if (_batteryState == .charging)
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.bolt_fill),
                title: const Text('Show Bolt When Charging'),
                trailing: CupertinoSwitch(
                  value: _chargingWithBolt,
                  onChanged: (v) => setState(() => _chargingWithBolt = v),
                ),
              ),
            if (!_monitorBatterySaveMode)
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.moon_fill),
                title: const Text('Battery Save Mode'),
                trailing: CupertinoSwitch(
                  value: _isInBatterySaveMode,
                  onChanged: (v) => setState(() => _isInBatterySaveMode = v),
                ),
              ),
          ],
        ),

        /// Style Settings
        CupertinoListSection.insetGrouped(
          header: const Text('Style Settings'),
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.app_badge),
              title: const Text('iOS 27 Style'),
              subtitle: const Text('Use iOS 27+ borderless design'),
              trailing: CupertinoSwitch(
                value: _isIOS27Style,
                onChanged: (v) => setState(() => _isIOS27Style = v),
              ),
            ),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.sun_max_fill),
              title: const Text('Theme Brightness'),
              trailing: CupertinoSlidingSegmentedControl<Brightness>(
                groupValue: _brightness,
                children: const {.light: Text('Light'), .dark: Text('Dark')},
                onValueChanged: (v) {
                  if (v != null) setState(() => _brightness = v);
                },
              ),
            ),
          ],
        ),

        /// Advanced Settings
        CupertinoListSection.insetGrouped(
          header: const Text('Advanced Settings'),
          hasLeading: kIsWeb ? true : false,
          children: [
            CupertinoListTile(
              leading: kIsWeb ? const Icon(CupertinoIcons.resize) : null,
              title: const Text('Widget Size'),
              additionalInfo: Text(
                '${_widgetSize.round()}',
                style: const TextStyle(color: CupertinoColors.activeBlue),
              ),
              trailing: SizedBox(
                width: kIsWeb ? null : 150,
                child: CupertinoSlider(
                  value: _widgetSize,
                  min: 10,
                  max: 100,
                  onChanged: (v) => setState(() => _widgetSize = v),
                ),
              ),
            ),
            CupertinoListTile(
              leading: kIsWeb
                  ? const Icon(CupertinoIcons.exclamationmark_triangle)
                  : null,
              title: const Text('Low Battery Threshold'),
              additionalInfo: Text(
                '${_lowBatteryThreshold.round()}%',
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

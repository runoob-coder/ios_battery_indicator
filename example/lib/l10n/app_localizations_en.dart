// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'iOS Battery Indicator Demo';

  @override
  String get languageSectionHeader => 'Language';

  @override
  String get languageSetting => 'App Language';

  @override
  String get languageFollowSystem => 'Follow System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String statusLine(String level, String state, String style) {
    return 'Level: $level | State: $state | $style';
  }

  @override
  String percentValue(String value) {
    return '$value%';
  }

  @override
  String get styleIOS27 => 'iOS 27 Style';

  @override
  String get styleClassic => 'Classic Style';

  @override
  String get stateDischarging => 'Discharging';

  @override
  String get stateCharging => 'Charging';

  @override
  String get stateFull => 'Full';

  @override
  String get stateConnectedNotCharging => 'Plugged';

  @override
  String get stateUnknown => 'Unknown';

  @override
  String get basicSettings => 'Basic Settings';

  @override
  String get useSystemBattery => 'Use System Battery';

  @override
  String get batteryLevel => 'Battery Level';

  @override
  String get batteryState => 'Battery State';

  @override
  String get monitorBatterySaveMode => 'Monitor Battery Save Mode';

  @override
  String get monitorBatterySaveModeHint => 'Poll Low Power Mode every 30s';

  @override
  String get displayOptions => 'Display Options';

  @override
  String get showBatteryPercentage => 'Show Battery Percentage';

  @override
  String get useTabularFigures => 'Use Tabular Figures';

  @override
  String get useTabularFiguresHint =>
      'Monospaced digits (no shift); disabled at 100%';

  @override
  String get playChargingSound => 'Play Charging Sound';

  @override
  String get playChargingSoundHint => 'Only plays when charging';

  @override
  String get showBoltWhenCharging => 'Show Bolt When Charging';

  @override
  String get batterySaveMode => 'Battery Save Mode';

  @override
  String get styleSettings => 'Style Settings';

  @override
  String get ios27StyleHint => 'Use iOS 27+ borderless design';

  @override
  String get themeBrightness => 'Theme Brightness';

  @override
  String get brightnessLight => 'Light';

  @override
  String get brightnessDark => 'Dark';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get widgetSize => 'Widget Size';

  @override
  String get lowBatteryThreshold => 'Low Battery Threshold';
}

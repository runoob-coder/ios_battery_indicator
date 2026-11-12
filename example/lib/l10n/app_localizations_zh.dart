// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'iOS 电池指示器示例';

  @override
  String get languageSectionHeader => '语言';

  @override
  String get languageSetting => '应用语言';

  @override
  String get languageFollowSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String statusLine(String level, String state, String style) {
    return '电量：$level | 状态：$state | $style';
  }

  @override
  String percentValue(String value) {
    return '$value%';
  }

  @override
  String get styleIOS27 => 'iOS 27 风格';

  @override
  String get styleClassic => '经典风格';

  @override
  String get stateDischarging => '放电中';

  @override
  String get stateCharging => '充电中';

  @override
  String get stateFull => '已充满';

  @override
  String get stateConnectedNotCharging => '已插电';

  @override
  String get stateUnknown => '未知';

  @override
  String get basicSettings => '基础设置';

  @override
  String get useSystemBattery => '使用系统电量';

  @override
  String get batteryLevel => '电池电量';

  @override
  String get batteryState => '电池状态';

  @override
  String get monitorBatterySaveMode => '监听省电模式';

  @override
  String get monitorBatterySaveModeHint => '每 30 秒读取一次低电量模式';

  @override
  String get displayOptions => '显示选项';

  @override
  String get showBatteryPercentage => '显示电量百分比';

  @override
  String get useTabularFigures => '使用等宽数字';

  @override
  String get useTabularFiguresHint => '等宽数字（数字不跳动）；100% 时禁用';

  @override
  String get playChargingSound => '播放充电提示音';

  @override
  String get playChargingSoundHint => '仅在充电时播放';

  @override
  String get showBoltWhenCharging => '充电时显示闪电';

  @override
  String get batterySaveMode => '省电模式';

  @override
  String get styleSettings => '样式设置';

  @override
  String get ios27StyleHint => '使用 iOS 27+ 无边框设计';

  @override
  String get themeBrightness => '主题亮度';

  @override
  String get brightnessLight => '浅色';

  @override
  String get brightnessDark => '深色';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get widgetSize => '组件尺寸';

  @override
  String get lowBatteryThreshold => '低电量阈值';
}

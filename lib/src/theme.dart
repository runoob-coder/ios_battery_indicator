import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// iOS Battery Indicator Theme
class BatteryIndicatorTheme extends ThemeExtension<BatteryIndicatorTheme> {
  /// Battery Background Color
  final Color bgColor;

  /// Battery Track Color (Discharging)
  final Color dischargingTrackColor;

  /// Battery Track Color (Charging)
  ///
  /// Defaults to [CupertinoColors.activeGreen].
  final Color chargingTrackColor;

  /// Battery Track Color (Critically Low)
  ///
  /// Defaults to [CupertinoColors.destructiveRed].
  final Color criticallyLowTrackColor;

  /// Battery Track Color (Battery Save Mode)
  ///
  /// Defaults to [CupertinoColors.systemYellow].
  final Color saveModeTrackColor;

  /// Battery Content Color
  final Color contentColor;

  /// Battery Content Anti Color
  final Color contentAntiColor;

  const BatteryIndicatorTheme({
    required this.bgColor,
    required this.dischargingTrackColor,
    this.chargingTrackColor = CupertinoColors.activeGreen,
    this.criticallyLowTrackColor = CupertinoColors.destructiveRed,
    this.saveModeTrackColor = CupertinoColors.systemYellow,
    required this.contentColor,
    required this.contentAntiColor,
  });

  factory BatteryIndicatorTheme.light() {
    return BatteryIndicatorTheme(
      /// Battery background color (light theme).
      ///
      /// For the iOS 27 style [bgColor] fills the battery body at `.28`. For
      /// non-iOS 27 styles it is overridden to `.38` and drawn as a 1px outline
      /// stroke (see `ios_battery_indicator.dart`).
      bgColor: CupertinoColors.black.withValues(alpha: .28),
      dischargingTrackColor: CupertinoColors.black,
      contentColor: CupertinoColors.black,
      contentAntiColor: CupertinoColors.white,
    );
  }

  factory BatteryIndicatorTheme.dark() {
    return BatteryIndicatorTheme(
      bgColor: CupertinoColors.white.withValues(alpha: .4),
      dischargingTrackColor: CupertinoColors.white,
      contentColor: CupertinoColors.white,
      contentAntiColor: CupertinoColors.black,
    );
  }

  @override
  BatteryIndicatorTheme copyWith({
    Color? bgColor,
    Color? dischargingTrackColor,
    Color? chargingTrackColor,
    Color? criticallyLowTrackColor,
    Color? saveModeTrackColor,
    Color? contentColor,
    Color? contentAntiColor,
  }) {
    return BatteryIndicatorTheme(
      bgColor: bgColor ?? this.bgColor,
      dischargingTrackColor:
          dischargingTrackColor ?? this.dischargingTrackColor,
      chargingTrackColor: chargingTrackColor ?? this.chargingTrackColor,
      criticallyLowTrackColor:
          criticallyLowTrackColor ?? this.criticallyLowTrackColor,
      saveModeTrackColor: saveModeTrackColor ?? this.saveModeTrackColor,
      contentColor: contentColor ?? this.contentColor,
      contentAntiColor: contentAntiColor ?? this.contentAntiColor,
    );
  }

  @override
  BatteryIndicatorTheme lerp(BatteryIndicatorTheme? other, double t) {
    if (other is! BatteryIndicatorTheme) {
      return this;
    }
    return BatteryIndicatorTheme(
      bgColor: .lerp(bgColor, other.bgColor, t) ?? bgColor,
      dischargingTrackColor:
          .lerp(dischargingTrackColor, other.dischargingTrackColor, t) ??
          dischargingTrackColor,
      chargingTrackColor:
          .lerp(chargingTrackColor, other.chargingTrackColor, t) ??
          chargingTrackColor,
      criticallyLowTrackColor:
          .lerp(criticallyLowTrackColor, other.criticallyLowTrackColor, t) ??
          criticallyLowTrackColor,
      saveModeTrackColor:
          .lerp(saveModeTrackColor, other.saveModeTrackColor, t) ??
          saveModeTrackColor,
      contentColor: .lerp(contentColor, other.contentColor, t) ?? contentColor,
      contentAntiColor:
          .lerp(contentAntiColor, other.contentAntiColor, t) ??
          contentAntiColor,
    );
  }
}

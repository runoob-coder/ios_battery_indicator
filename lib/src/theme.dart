import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS Battery Indicator Theme
class BatteryIndicatorTheme extends ThemeExtension<BatteryIndicatorTheme> {
  /// Battery Background Color
  final Color bgColor;

  /// Battery Track Color (Discharging)
  final Color dischargingTrackColor;

  /// Battery Content Color
  final Color contentColor;

  /// Battery Content Anti Color
  final Color contentAntiColor;

  const BatteryIndicatorTheme({
    required this.bgColor,
    required this.dischargingTrackColor,
    required this.contentColor,
    required this.contentAntiColor,
  });

  factory BatteryIndicatorTheme.light() {
    return BatteryIndicatorTheme(
      bgColor: CupertinoColors.black.withValues(alpha: .2),
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
    Color? contentColor,
    Color? contentAntiColor,
  }) {
    return BatteryIndicatorTheme(
      bgColor: bgColor ?? this.bgColor,
      dischargingTrackColor:
          dischargingTrackColor ?? this.dischargingTrackColor,
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
      contentColor: .lerp(contentColor, other.contentColor, t) ?? contentColor,
      contentAntiColor:
          .lerp(contentAntiColor, other.contentAntiColor, t) ??
          contentAntiColor,
    );
  }
}

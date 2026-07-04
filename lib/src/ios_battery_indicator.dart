import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:cutout/cutout.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:version/version.dart';

import 'theme.dart';

/// A Flutter widget that replicates the native iOS battery indicator,
/// including support for iOS 27 style and automatic system battery monitoring.
class IosBatteryIndicator extends StatefulWidget {
  const IosBatteryIndicator({
    super.key,
    this.height,
    this.width,
    this.batteryLevel,
    this.batteryState,
    this.showBatteryPercentage = true,
    this.isInBatterySaveMode,
    this.lowBatteryThreshold = 20,
    this.chargingWithBolt = true,
    this.isIOS27Style,
    this.brightness,
    this.animationDuration = const Duration(milliseconds: 250),
    this.themeAnimationDuration = kThemeAnimationDuration,
  }) : assert(
         batteryLevel == null || (batteryLevel >= 0 && batteryLevel <= 100),
         'batteryLevel must be between 0 and 100',
       ),
       assert(
         height == null || width == null,
         'Cannot set both height and width at the same time',
       ),
       assert(
         lowBatteryThreshold >= 10 && lowBatteryThreshold <= 30,
         'lowBatteryThreshold must be between 10 and 30',
       );

  /// The preferred height of the indicator. Mutually exclusive with [width].
  final double? height;

  /// The preferred width of the indicator. Mutually exclusive with [height].
  final double? width;

  /// The battery level (0–100). When `null`, the level is read from the
  /// system at runtime via [Battery].
  final int? batteryLevel;

  /// The battery state (charging, discharging, etc.). When `null`, the state
  /// is read from the system at runtime via [Battery].
  ///
  /// When the state is [BatteryState.full], the battery level is automatically
  /// treated as 100, regardless of the value provided via [batteryLevel] or
  /// read from the system.
  final BatteryState? batteryState;

  /// Whether to render the battery percentage label inside the indicator.
  final bool showBatteryPercentage;

  /// Whether the device is in Low Power Mode / Battery Saver mode.
  /// When `null`, the value is read from the system at runtime.
  final bool? isInBatterySaveMode;

  /// The threshold (10–30) below which the battery is considered low.
  /// iPhone default: 20, Mac default: 10.
  final int lowBatteryThreshold;

  /// Whether to show a bolt glyph (⚡) overlay when the battery is charging.
  final bool chargingWithBolt;

  /// Whether to render the battery indicator in the iOS 27 style.
  final bool? isIOS27Style;

  /// The brightness of the indicator.
  final Brightness? brightness;

  /// The duration of battery indicator animations (fill level, bolt, etc.).
  final Duration animationDuration;

  /// The duration of the theme animation.
  final Duration themeAnimationDuration;

  @override
  State<IosBatteryIndicator> createState() => _IosBatteryIndicatorState();
}

class _IosBatteryIndicatorState extends State<IosBatteryIndicator> {
  final _battery = Battery();

  int _systemBatteryLevel = 0;
  BatteryState? _systemBatteryState;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  Timer? _batteryLevelTimer;

  bool _systemIsIOS27Style = false;
  bool _systemIsInBatterySaveMode = false;

  // ---- resolution getters: widget prop takes priority, system value as fallback ----

  int get _batteryLevel {
    if (_batteryState == BatteryState.full) return 100;
    return widget.batteryLevel ?? _systemBatteryLevel;
  }

  BatteryState? get _batteryState => widget.batteryState ?? _systemBatteryState;

  bool get _isIOS27Style => widget.isIOS27Style ?? _systemIsIOS27Style;

  bool get _isInBatterySaveMode =>
      widget.isInBatterySaveMode ?? _systemIsInBatterySaveMode;

  // ---- computed helpers (derived from [_batteryLevel] + [_batteryState]) ----

  bool get _isFull => _batteryLevel == 100 || _batteryState == .full;

  bool get _isCharging =>
      _batteryState == .charging ||
      (_batteryLevel == 100 && _batteryState == .full);

  bool get _isCriticallyLow => _batteryLevel <= widget.lowBatteryThreshold;

  /// Returns `true` when the battery is full, charging, or critically low.
  /// In these states a solid color fill is used (no cutout).
  bool get _usePlainStyle => _isFull || _isCharging || _isCriticallyLow;

  /// Returns `true` when the bolt overlay should be shown.
  bool get _showBolt => _isCharging && !_isFull && widget.chargingWithBolt;

  // ---- theme helpers ----

  /// Reads the custom [BatteryIndicatorTheme] from the widget tree.
  ///
  /// **Important**: the [context] comes from the [Builder] nested inside
  /// [AnimatedTheme] in [build].  This ensures [Theme.of] resolves through
  /// the animated theme wrapper and returns the correct theme extension.
  /// Using the outer [build] context directly would bypass [AnimatedTheme]
  /// and may retrieve a stale or default value.
  BatteryIndicatorTheme _theme(BuildContext context) =>
      Theme.of(context).extension<BatteryIndicatorTheme>()!;

  Color _trackColor(BatteryIndicatorTheme theme) {
    return _isInBatterySaveMode
        ? CupertinoColors.systemYellow
        : _isCriticallyLow
        ? CupertinoColors.destructiveRed
        : _isCharging
        ? CupertinoColors.activeGreen
        : theme.dischargingTrackColor;
  }

  @override
  void initState() {
    super.initState();
    _initBattery();
    if (widget.isIOS27Style != null) {
      setState(() => _systemIsIOS27Style = widget.isIOS27Style!);
    } else {
      _checkIosVersion();
    }
  }

  @override
  void didUpdateWidget(covariant IosBatteryIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.batteryLevel == null && oldWidget.batteryLevel != null) {
      _initBattery();
      return;
    }
    if (widget.batteryState == null && oldWidget.batteryState != null) {
      _initBattery();
    }
  }

  Future<void> _initBattery() async {
    if (widget.batteryLevel != null) {
      _systemBatteryLevel = widget.batteryLevel!;
    } else {
      _systemBatteryLevel = await _battery.batteryLevel;
      _batteryLevelTimer?.cancel();
      _batteryLevelTimer = Timer.periodic(const Duration(seconds: 30), (
        _,
      ) async {
        final level = await _battery.batteryLevel;
        if (mounted) setState(() => _systemBatteryLevel = level);
      });
    }

    if (widget.batteryState != null) {
      _systemBatteryState = widget.batteryState!;
    } else {
      _systemBatteryState = await _battery.batteryState;

      _batteryStateSubscription?.cancel();
      _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
        state,
      ) async {
        /// Sync the latest battery level when the state changes.
        if (widget.batteryLevel == null) {
          final level = await _battery.batteryLevel;
          if (mounted) setState(() => _systemBatteryLevel = level);
        }

        /// When transitioning from charging to discharging, defer the update
        /// by 1 second to avoid a brief flicker of the bolt icon on unplug.
        /// Only applies on iOS (not Web).
        if (!kIsWeb &&
            Platform.isIOS &&
            _systemBatteryState == .charging &&
            state == .discharging) {
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            setState(() => _systemBatteryState = state);
          });
        } else {
          setState(() => _systemBatteryState = state);
        }
      });
    }

    if (widget.isInBatterySaveMode != null) {
      _systemIsInBatterySaveMode = widget.isInBatterySaveMode!;
    } else {
      bool isInBatterySaveMode = await _battery.isInBatterySaveMode;
      setState(() => _systemIsInBatterySaveMode = isInBatterySaveMode);
    }

    setState(() {});
  }

  Future<void> _checkIosVersion() async {
    if (!kIsWeb && Platform.isIOS) {
      IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      setState(() {
        _systemIsIOS27Style = Version.parse(iosInfo.systemVersion).major >= 27;
      });
    }
  }

  @override
  void dispose() {
    _batteryLevelTimer?.cancel();
    _batteryStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    final brightness = widget.brightness ?? themeData.brightness;
    if (widget.brightness != null ||
        themeData.extension<BatteryIndicatorTheme>() == null) {
      themeData = themeData.copyWith(
        brightness: brightness,
        extensions: [
          ...themeData.extensions.values,
          brightness == Brightness.light
              ? BatteryIndicatorTheme.light()
              : BatteryIndicatorTheme.dark(),
        ],
      );
    }

    Widget child = AnimatedTheme(
      duration: widget.themeAnimationDuration,
      data: themeData,
      child: Builder(
        builder: (context) {
          final child = FittedBox(
            child: Row(
              mainAxisSize: .min,
              spacing: 1,
              children: [
                /// Battery content with a crossfade transition between basic
                /// and percentage modes.
                AnimatedSwitcher(
                  duration: widget.animationDuration,
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: widget.showBatteryPercentage
                      ? KeyedSubtree(
                          key: const ValueKey('with_percentage'),
                          child: _buildBatteryWithPercentage(context),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('basic'),
                          child: _buildBattery(context),
                        ),
                ),

                /// Positive pole (small circle on the right).
                _buildPositivePole(context),
              ],
            ),
          );

          if (widget.height != null || widget.width != null) {
            return SizedBox(
              height: widget.height,
              width: widget.width,
              child: child,
            );
          }

          return child;
        },
      ),
    );

    return DefaultTextStyle.merge(
      style: const TextStyle(height: 1, fontWeight: .w500),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      child: child,
    );
  }

  /// Basic battery icon (no percentage label).
  /// iOS 27 style renders without a border.
  Widget _buildBattery(BuildContext context) {
    final batteryIndicatorTheme = _theme(context);

    Widget child;

    child = Container(
      width: 25,
      height: 13,
      padding: _isIOS27Style ? .zero : const .all(1),
      decoration: ShapeDecoration(
        color: _isIOS27Style ? batteryIndicatorTheme.bgColor : null,
        shape: RoundedSuperellipseBorder(
          borderRadius: const .all(.circular(4)),
          side: _isIOS27Style
              ? .none
              : BorderSide(color: batteryIndicatorTheme.bgColor, width: 1),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: (_batteryLevel / 100).clamp(.05, 1)),
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return FractionallySizedBox(
              widthFactor: value,
              heightFactor: 1,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: widget.animationDuration,
            curve: Curves.easeOutCubic,
            decoration: _isIOS27Style
                ? null
                : ShapeDecoration(
                    shape: const RoundedSuperellipseBorder(
                      borderRadius: .all(.circular(2)),
                    ),
                    color: _trackColor(batteryIndicatorTheme),
                  ),
            color: _isIOS27Style ? _trackColor(batteryIndicatorTheme) : null,
          ),
        ),
      ),
    );

    if (_isCharging) {
      child = Stack(
        alignment: .center,
        children: [
          Cutout(
            alignment: .center,
            maskChild: FittedBox(
              fit: .scaleDown,
              child: _buildBolt(
                context,
                style: TextStyle(
                  fontSize: 13,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2,
                ),
              ),
            ),
            child: child,
          ),
          FittedBox(
            fit: .scaleDown,
            child: _buildBolt(
              context,
              color: batteryIndicatorTheme.contentColor,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    if (_isIOS27Style) {
      const shape = RoundedSuperellipseBorder(borderRadius: .all(.circular(4)));
      return ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: child,
      );
    }

    return AnimatedSwitcher(
      duration: widget.animationDuration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: child,
    );
  }

  /// Battery icon with a percentage label and no border.
  Widget _buildBatteryWithPercentage(BuildContext context) {
    final batteryIndicatorTheme = _theme(context);

    final batteryLevelText = Text(
      _batteryLevel.toString(),
      textAlign: .center,
      style: TextStyle(
        color: _isInBatterySaveMode
            ? CupertinoColors.black
            : !_isCharging
            ? batteryIndicatorTheme.contentAntiColor
            : CupertinoColors.white,
        fontSize: 12,
        letterSpacing: .1,
        fontWeight: .bold,
      ),
    );

    Widget child = Container(
      color: batteryIndicatorTheme.bgColor,
      alignment: .center,
      child: Stack(
        alignment: .center,
        children: [
          Align(
            alignment: .centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: (_batteryLevel / 100).clamp(.05, 1)),
              duration: widget.animationDuration,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  widthFactor: value,
                  heightFactor: 1,
                  child: child,
                );
              },
              child: AnimatedContainer(
                duration: widget.animationDuration,
                curve: Curves.easeOutCubic,
                color: _trackColor(batteryIndicatorTheme),
              ),
            ),
          ),
          if (_usePlainStyle)
            Transform.scale(
              scale: 1.05,
              child: FittedBox(
                fit: .fitWidth,
                child: Row(
                  mainAxisAlignment: .center,
                  spacing: 1,
                  children: [
                    batteryLevelText,

                    /// Bolt overlay — shown when charging and not full.
                    if (_isCharging || _isCriticallyLow)
                      AnimatedSwitcher(
                        duration: widget.animationDuration,
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        child: _showBolt
                            ? _buildBolt(
                                context,
                                key: const ValueKey('bolt'),
                                fontSize: 10,
                                color: _isInBatterySaveMode
                                    ? CupertinoColors.black
                                    : CupertinoColors.white,
                              )
                            : const SizedBox.shrink(key: ValueKey('empty')),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    /// Cutout style: punch the percentage text through the fill.
    /// Skip cutout when using plain style (full / charging / critically low).
    if (!_usePlainStyle) {
      child = Cutout(
        alignment: .center,
        maskChild: Transform.scale(
          scale: 1.1,
          child: FittedBox(fit: .scaleDown, child: batteryLevelText),
        ),
        child: child,
      );
    }

    return ClipPath(
      clipper: ShapeBorderClipper(
        shape: RoundedSuperellipseBorder(borderRadius: .all(.circular(4))),
      ),
      child: SizedBox(
        width: 25,
        height: 13,
        child: AnimatedSwitcher(
          duration: _batteryState == .discharging && _batteryLevel == 100
              ? .zero
              : widget.animationDuration,
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: child,
        ),
      ),
    );
  }

  /// Positive pole (small circle on the right).
  Widget _buildPositivePole(BuildContext context) {
    final batteryIndicatorTheme = _theme(context);

    const double circleDiameter = 4.2;
    const double visibleWidth = circleDiameter / 3;

    /// adaptive color when full but not charging
    Color color = batteryIndicatorTheme.bgColor;
    if (_isFull && (widget.showBatteryPercentage || _isIOS27Style)) {
      color = _isInBatterySaveMode
          ? CupertinoColors.systemYellow
          : _isCharging
          ? CupertinoColors.activeGreen
          : batteryIndicatorTheme.dischargingTrackColor;
    }

    return SizedBox(
      width: visibleWidth,
      height: circleDiameter,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              curve: Curves.easeOutCubic,
              width: circleDiameter,
              height: circleDiameter,
              decoration: BoxDecoration(color: color, shape: .circle),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a [Text] widget rendering the Cupertino bolt (⚡) glyph.
  ///
  /// The returned widget uses the Cupertino icon font so that the bolt
  /// renders natively rather than as an emoji.
  Widget _buildBolt(
    BuildContext context, {
    Key? key,
    IconData icon = CupertinoIcons.bolt_fill,
    double? fontSize,
    Color? color,
    TextStyle? style,
  }) {
    return Text(
      String.fromCharCode(icon.codePoint),
      key: key,
      style: TextStyle(
        fontFamily: CupertinoIcons.iconFont,
        package: CupertinoIcons.iconFontPackage,
      ).merge(style).copyWith(fontSize: fontSize, color: color),
    );
  }
}

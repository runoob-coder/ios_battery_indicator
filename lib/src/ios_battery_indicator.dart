import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:cutout/cutout.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ios_system_sound/ios_system_sound.dart';
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
    this.fontFeatures = const [.tabularFigures()],
    this.isInBatterySaveMode,
    this.monitorBatterySaveMode = false,
    this.saveModePollInterval = const Duration(seconds: 30),
    this.batteryLevelPollInterval = const Duration(seconds: 30),
    this.lowBatteryThreshold = 20,
    this.chargingWithBolt = true,
    this.playChargingSound = false,
    this.isIOS27Style,
    this.brightness,
    this.animationDuration = const Duration(milliseconds: 250),
    this.themeAnimationDuration = kThemeAnimationDuration,
    this.onBatteryLevelChanged,
    this.onBatteryStateChanged,
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
       ),
       assert(
         !monitorBatterySaveMode || isInBatterySaveMode == null,
         'isInBatterySaveMode must be null when monitorBatterySaveMode is true',
       );

  /// The preferred height of the indicator. Mutually exclusive with [width].
  final double? height;

  /// The preferred width of the indicator. Mutually exclusive with [height].
  final double? width;

  /// The battery level (0–100). When `null`, the level is read from the
  /// system at runtime via [Battery].
  ///
  /// Note that when the resolved battery state is [BatteryState.full], the
  /// level is unconditionally treated as 100 — even if a different manual
  /// value is supplied here. See [batteryState].
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

  /// The font features applied to the battery percentage text.
  ///
  /// Defaults to `[FontFeature.tabularFigures()]`, which renders each digit
  /// with the same width so the label does not shift horizontally as the number
  /// of digits changes (e.g. `9` → `99` → `100`). Pass `null` to use the font's
  /// default (proportional) figures, or supply other [FontFeature]s as needed.
  ///
  /// Only has an effect when [showBatteryPercentage] is `true`.
  ///
  /// Note: when the battery level is exactly 100, any `tabularFigures`
  /// feature is removed from this list (other features are preserved).
  final List<FontFeature>? fontFeatures;

  /// Whether the device is in Low Power Mode / Battery Saver mode.
  /// When `null`, the value is read from the system at runtime.
  final bool? isInBatterySaveMode;

  /// Whether to continuously poll the system Low Power Mode / Battery Saver
  /// state while [isInBatterySaveMode] is `null` (system mode).
  ///
  /// When `false` (the default), the save-mode state is read once when the
  /// widget is initialized. When `true`, it is re-checked on a periodic timer
  /// (see [saveModePollInterval], default 30 seconds) so that toggling Low
  /// Power Mode at runtime is reflected in the indicator.
  ///
  /// This has no effect when [isInBatterySaveMode] is explicitly provided. It
  /// is only supported on Android, iOS, macOS and Windows — it has no effect
  /// on web or other platforms.
  final bool monitorBatterySaveMode;

  /// The interval at which the system Low Power Mode / Battery Saver state is
  /// polled when [monitorBatterySaveMode] is `true`.
  ///
  /// Defaults to 30 seconds. Only used in system mode (`isInBatterySaveMode` is
  /// `null`). Has no effect when [monitorBatterySaveMode] is `false`.
  final Duration saveModePollInterval;

  /// The interval at which the system battery level is polled in system mode
  /// (`batteryLevel` is `null`).
  ///
  /// Defaults to 30 seconds. Has no effect when [batteryLevel] is explicitly
  /// provided (manual mode).
  final Duration batteryLevelPollInterval;

  /// The threshold (10–30) below which the battery is considered low.
  /// iPhone default: 20, Mac default: 10.
  final int lowBatteryThreshold;

  /// Whether to show a bolt glyph (⚡) overlay when the battery is charging.
  final bool chargingWithBolt;

  /// Whether to play the iOS charging sound ([SystemSoundID.connectedToPower])
  /// when entering the charging state.
  ///
  /// This **only** takes effect when [batteryState] is explicitly provided
  /// (i.e. manual mode). When [batteryState] is `null` and the system
  /// monitors the battery automatically, the sound is never played, regardless
  /// of this flag.
  ///
  /// The sound is played via the [ios_system_sound](https://pub.dev/packages/ios_system_sound)
  /// package and is only supported on iOS — it has no effect on the web or
  /// other platforms.
  ///
  /// Defaults to `false`.
  final bool playChargingSound;

  /// Whether to render the battery indicator in the iOS 27 style.
  final bool? isIOS27Style;

  /// The brightness of the indicator.
  final Brightness? brightness;

  /// The duration of battery indicator animations (fill level, bolt, etc.).
  final Duration animationDuration;

  /// The duration of the theme animation.
  final Duration themeAnimationDuration;

  /// Called when the system battery level changes.
  /// Only fires when [batteryLevel] is `null` (system mode).
  final ValueChanged<int>? onBatteryLevelChanged;

  /// Called when the system battery state changes.
  /// Only fires when [batteryState] is `null` (system mode).
  final ValueChanged<BatteryState>? onBatteryStateChanged;

  @override
  State<IosBatteryIndicator> createState() => _IosBatteryIndicatorState();
}

class _IosBatteryIndicatorState extends State<IosBatteryIndicator> {
  final _battery = Battery();
  final _sound = IosSystemSound();

  int _systemBatteryLevel = 0;
  BatteryState? _systemBatteryState;
  BatteryState? _previousBatteryState;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  Timer? _batteryLevelTimer;
  Timer? _batterySaveModeTimer;

  bool _systemIsIOS26 = false;
  bool _systemIsIOS27Style = false;
  bool _systemIsInBatterySaveMode = false;

  // ---- resolution getters: widget prop takes priority, system value as fallback ----

  int get _batteryLevel {
    if (_batteryState == .full) return 100;
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

  /// Returns `true` when a solid color fill should be used instead of the
  /// cutout-percentage style. This happens while the battery is charging,
  /// critically low, or in low-power (battery save) mode.
  bool get _usePlainStyle =>
      _isCharging || _isCriticallyLow || _isInBatterySaveMode;

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
        ? theme.saveModeTrackColor
        : _isCriticallyLow
        ? theme.criticallyLowTrackColor
        : _isCharging
        ? theme.chargingTrackColor
        : theme.dischargingTrackColor;
  }

  // ---- layout constants ----

  static const double _batteryPadding = 3;

  double get _batteryWidth => _isIOS27Style ? 75 : 68;

  double get _batteryHeight => _isIOS27Style
      ? (widget.showBatteryPercentage ? 41 : 39)
      : (widget.showBatteryPercentage ? 38 : 36);

  double get _baseOuterRadius => _isIOS27Style || _systemIsIOS26 ? 12 : 9.4;

  BorderRadius get _outerBorderRadius => .all(.circular(_baseOuterRadius));

  BorderRadius get _innerBorderRadius =>
      .all(.circular(_baseOuterRadius - _batteryPadding - 2));

  /// Plays the iOS charging sound when the battery state transitions to
  /// [BatteryState.charging] and [IosBatteryIndicator.playChargingSound] is
  /// `true`. Only fires on iOS, not on the web or other platforms.
  void _playChargingSoundIfNeeded(BatteryState? newState) {
    if (widget.playChargingSound &&
        newState == .charging &&
        _previousBatteryState != .charging &&
        !kIsWeb &&
        Platform.isIOS) {
      _sound.play(SystemSoundID.connectedToPower);
    }
    _previousBatteryState = newState;
  }

  // ---- platform detection helpers ----

  /// Whether system Low Power Mode / Battery Saver polling is supported.
  /// Only Android, iOS, macOS and Windows are supported; web and Linux are not.
  bool get _supportsSaveModePolling => !kIsWeb && !Platform.isLinux;

  /// Whether the current platform is macOS (excluding web, where [Platform]
  /// is unavailable). Used to work around macOS-specific font metrics.
  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _initBattery();
    if (widget.isIOS27Style != null) {
      setState(() => _systemIsIOS27Style = widget.isIOS27Style!);
    }
    _checkIosVersion();
  }

  @override
  void didUpdateWidget(covariant IosBatteryIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // System → manual: cancel system monitoring.
    if ((widget.batteryLevel != null && oldWidget.batteryLevel == null) ||
        (widget.batteryState != null && oldWidget.batteryState == null) ||
        (widget.isInBatterySaveMode != null &&
            oldWidget.isInBatterySaveMode == null)) {
      _batteryLevelTimer?.cancel();
      _batteryStateSubscription?.cancel();
      _batterySaveModeTimer?.cancel();
    }
    // Manual → system: restart system monitoring.
    // _initBattery() handles level, state and save mode, so only call it once.
    if ((widget.batteryLevel == null && oldWidget.batteryLevel != null) ||
        (widget.batteryState == null && oldWidget.batteryState != null) ||
        (widget.isInBatterySaveMode == null &&
            oldWidget.isInBatterySaveMode != null)) {
      _initBattery();
    }

    // Start save-mode polling when the flag is enabled at runtime (system mode).
    if (widget.monitorBatterySaveMode &&
        !oldWidget.monitorBatterySaveMode &&
        widget.isInBatterySaveMode == null) {
      _startSaveModePolling();
    }

    // Play charging sound when the external batteryState changes to charging.
    if (widget.batteryState != null &&
        widget.batteryState != oldWidget.batteryState) {
      _playChargingSoundIfNeeded(widget.batteryState);
    }
  }

  Future<void> _initBattery() async {
    if (widget.batteryLevel != null) {
      _systemBatteryLevel = widget.batteryLevel!;
    } else {
      _systemBatteryLevel = await _battery.batteryLevel;
      widget.onBatteryLevelChanged?.call(_systemBatteryLevel);
      _batteryLevelTimer?.cancel();
      _batteryLevelTimer = .periodic(widget.batteryLevelPollInterval, (
        _,
      ) async {
        final level = await _battery.batteryLevel;
        if (mounted) {
          setState(() => _systemBatteryLevel = level);
          widget.onBatteryLevelChanged?.call(level);
        }
      });
    }

    if (widget.batteryState != null) {
      _systemBatteryState = widget.batteryState!;
      _playChargingSoundIfNeeded(widget.batteryState);
    } else {
      _systemBatteryState = await _battery.batteryState;
      widget.onBatteryStateChanged?.call(_systemBatteryState!);

      _batteryStateSubscription?.cancel();
      _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
        state,
      ) async {
        /// Sync the latest battery level when the state changes.
        if (widget.batteryLevel == null) {
          final level = await _battery.batteryLevel;
          if (mounted) {
            setState(() => _systemBatteryLevel = level);
            widget.onBatteryLevelChanged?.call(level);
          }
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
            widget.onBatteryStateChanged?.call(state);
          });
        } else {
          setState(() => _systemBatteryState = state);
          widget.onBatteryStateChanged?.call(state);
        }
      });
    }

    if (widget.isInBatterySaveMode != null) {
      _systemIsInBatterySaveMode = widget.isInBatterySaveMode!;
    } else if (_supportsSaveModePolling) {
      final isInBatterySaveMode = await _battery.isInBatterySaveMode;
      setState(() => _systemIsInBatterySaveMode = isInBatterySaveMode);
      // When monitoring is enabled, re-poll the save-mode state on the
      // configured interval so runtime toggles are reflected.
      if (widget.monitorBatterySaveMode) {
        _startSaveModePolling();
      }
    }

    setState(() {});
  }

  Future<void> _checkIosVersion() async {
    if (!kIsWeb && Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      if (!mounted) return;
      final major = Version.parse(iosInfo.systemVersion).major;
      setState(() {
        _systemIsIOS26 = major >= 26;
        if (widget.isIOS27Style == null) {
          _systemIsIOS27Style = major >= 27;
        }
      });
    }
  }

  /// Polls the system Low Power Mode / Battery Saver state at the interval
  /// configured via [IosBatteryIndicator.saveModePollInterval], updating
  /// [_systemIsInBatterySaveMode] so runtime toggles are reflected.
  /// Only meaningful when [IosBatteryIndicator.monitorBatterySaveMode] is
  /// `true` and [IosBatteryIndicator.isInBatterySaveMode] is `null`.
  void _startSaveModePolling() {
    if (!_supportsSaveModePolling) return;
    _batterySaveModeTimer?.cancel();
    _batterySaveModeTimer = .periodic(widget.saveModePollInterval, (_) async {
      final enabled = await _battery.isInBatterySaveMode;
      if (mounted) setState(() => _systemIsInBatterySaveMode = enabled);
    });
  }

  @override
  void dispose() {
    _batteryLevelTimer?.cancel();
    _batteryStateSubscription?.cancel();
    _batterySaveModeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    final brightness = widget.brightness ?? themeData.brightness;
    if (widget.brightness != null ||
        themeData.extension<BatteryIndicatorTheme>() == null) {
      BatteryIndicatorTheme indicatorTheme = brightness == .light
          ? () {
              BatteryIndicatorTheme light = .light();
              return _isIOS27Style
                  ? light
                  : light.copyWith(
                      bgColor: light.bgColor.withValues(alpha: .38),
                    );
            }()
          : .dark();
      themeData = themeData.copyWith(
        brightness: brightness,
        extensions: [...themeData.extensions.values, indicatorTheme],
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
              spacing: _isIOS27Style ? 2 : 3,
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

    return DefaultTextStyle(
      style: TextStyle(
        height: 1,
        fontFamily: _isIOS27Style ? 'SF-Pro-Rounded-Medium' : 'SF-Pro',
        package: 'ios_battery_indicator',
        fontWeight: .w500,
        leadingDistribution: .even,
      ),
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
    final theme = _theme(context);

    final fillChild = AnimatedContainer(
      duration: widget.animationDuration,
      curve: Curves.easeOutCubic,
      decoration: _isIOS27Style
          ? null
          : ShapeDecoration(
              shape: RoundedSuperellipseBorder(
                borderRadius: _innerBorderRadius,
              ),
              color: _trackColor(theme),
            ),
      color: _isIOS27Style ? _trackColor(theme) : null,
    );

    Widget child = Container(
      width: _batteryWidth,
      height: _batteryHeight,
      padding: _isIOS27Style
          ? .zero
          : .all(
              widget.chargingWithBolt ? _batteryPadding : _batteryPadding - .5,
            ),
      decoration: ShapeDecoration(
        color: _isIOS27Style ? theme.bgColor : null,
        shape: RoundedSuperellipseBorder(
          borderRadius: _outerBorderRadius,
          side: _isIOS27Style
              ? .none
              : BorderSide(color: theme.bgColor, width: 3),
        ),
      ),
      child: Align(
        alignment: .centerLeft,
        child: _buildFillAnimation(fillChild, dynamicHeight: !_isIOS27Style),
      ),
    );

    if (_isCharging && widget.chargingWithBolt) {
      child = Stack(
        alignment: .center,
        children: [
          Cutout(
            alignment: .center,
            maskChild: _buildBolt(context, strokeWidth: 2.8),
            child: child,
          ),
          _buildBolt(context, color: theme.contentColor),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: widget.animationDuration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _isIOS27Style
          ? KeyedSubtree(
              key: ValueKey((
                _isCharging,
                _isCriticallyLow,
                widget.chargingWithBolt,
              )),
              child: _clipBatteryShape(child),
            )
          : KeyedSubtree(
              key: ValueKey((_isCharging, widget.chargingWithBolt)),
              child: child,
            ),
    );
  }

  /// Battery icon with a percentage label and no border.
  Widget _buildBatteryWithPercentage(BuildContext context) {
    final theme = _theme(context);

    Widget batteryLevelText = Text(
      _batteryLevel.toString(),
      textAlign: .center,
      style: DefaultTextStyle.of(context).style.merge(
        TextStyle(
          color: _isInBatterySaveMode
              ? CupertinoColors.black
              : CupertinoColors.white,
          fontSize: _batteryHeight,
          // At 100% remove the tabular-figures feature while keeping any other font features,
          // so "100" uses proportional spacing.
          fontFeatures: _isFull
              ? widget.fontFeatures
                    ?.where((f) => f != .tabularFigures())
                    .toList()
              : widget.fontFeatures,
          letterSpacing: kIsWeb || _isIOS27Style || !_isCharging ? 0 : -1,
          fontWeight: _isMacOS ? .w600 : .w700,
        ),
      ),
    );

    if (!_isIOS27Style && _isCharging && !_isFull) {
      batteryLevelText = Transform.scale(scaleX: .9, child: batteryLevelText);
    }

    Widget child = Container(
      color: theme.bgColor,
      alignment: .center,
      child: Stack(
        alignment: .center,
        children: [
          Align(
            alignment: .centerLeft,
            child: _buildFillAnimation(
              AnimatedContainer(
                duration: widget.animationDuration,
                curve: Curves.easeOutCubic,
                color: _trackColor(theme),
              ),
            ),
          ),
          if (_usePlainStyle)
            FittedBox(
              fit: .scaleDown,
              child: Row(
                mainAxisAlignment: .center,
                spacing: _isIOS27Style ? 2 : 1,
                children: [
                  batteryLevelText,

                  /// Bolt overlay — shown when charging and not full.
                  if (_isCharging && _showBolt)
                    _buildBolt(
                      context,
                      height: _batteryHeight * .70,
                      color: _isInBatterySaveMode
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                    ),
                ],
              ),
            ),
        ],
      ),
    );

    /// Cutout style: punch the percentage text through the fill.
    /// Skip the cutout when using the plain style (charging, critically low,
    /// or battery save mode) and render a solid fill instead.
    if (!_usePlainStyle) {
      child = Cutout(
        alignment: .center,
        maskChild: FittedBox(fit: .scaleDown, child: batteryLevelText),
        child: child,
      );
    }

    return _clipBatteryShape(
      AnimatedSwitcher(
        duration: widget.animationDuration,
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: child,
      ),
      constrainSize: true,
    );
  }

  /// Positive pole (small circle on the right).
  Widget _buildPositivePole(BuildContext context) {
    final theme = _theme(context);

    double circleDiameter = _isIOS27Style ? 15 : 13;

    /// adaptive color when full but not charging
    final Color color =
        _isFull && (widget.showBatteryPercentage || _isIOS27Style)
        ? _trackColor(theme)
        : theme.bgColor;

    return SizedBox(
      width: _isIOS27Style ? 6 : 4,
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

  // ---- reusable builders ----

  /// Animates the fill level of [fillChild] from 0 to the current battery
  /// level using a [TweenAnimationBuilder] with an ease-out-cubic curve.
  Widget _buildFillAnimation(Widget fillChild, {bool dynamicHeight = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: (_batteryLevel / 100).clamp(_minFillLevel, 1)),
      duration: widget.animationDuration * .8,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // Only reduce height dynamically for the classic (non-iOS27) icon
        // style when battery is low, so the fill stays within the rounded
        // corners.  Below [_minFillLevel] the fill is at [_minHeightFactor]
        // height, easing up to full height at [_lowThreshold] (20 %).
        final heightFactor = dynamicHeight && value <= _lowThreshold
            ? () {
                final t =
                    (value - _minFillLevel) / (_lowThreshold - _minFillLevel);
                return _minHeightFactor +
                    (1 - _minHeightFactor) * (2 * t - t * t);
              }()
            : 1.0;
        return FractionallySizedBox(
          widthFactor: value,
          heightFactor: heightFactor,
          child: child,
        );
      },
      child: fillChild,
    );
  }

  /// Lowest displayed fill level (matches the tween's clamp).
  static const double _minFillLevel = 0.02;

  /// Battery level below which the fill height starts shrinking; the fill
  /// reaches full height again at this point (20 % low-battery boundary).
  static const double _lowThreshold = 0.20;

  /// Height factor applied at the lowest level ([_minFillLevel]) so the fill
  /// is still clearly visible but shorter than full height.
  static const double _minHeightFactor = 0.9;

  /// Clips [child] with the battery's rounded superellipse shape.
  /// When [constrainSize] is true, also constrains to [_batteryWidth] x
  /// [_batteryHeight].
  Widget _clipBatteryShape(Widget child, {bool constrainSize = false}) {
    final shape = RoundedSuperellipseBorder(borderRadius: _outerBorderRadius);
    final clipped = ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: child,
    );
    if (constrainSize) {
      return SizedBox(
        width: _batteryWidth,
        height: _batteryHeight,
        child: clipped,
      );
    }
    return clipped;
  }

  /// Builds a bolt (⚡) glyph by vector-drawing a [CustomPaint] widget.
  Widget _buildBolt(
    BuildContext context, {
    double? height,
    Color? color,
    double strokeWidth = 0,
  }) {
    final theme = _theme(context);
    return SizedBox(
      height: height ?? _batteryHeight,
      child: FittedBox(
        child: SizedBox(
          width: _boltWidth,
          height: _boltHeight,
          child: CustomPaint(
            painter: _BoltPainter(
              strokeWidth: strokeWidth,
              color: color ?? theme.contentColor,
            ),
          ),
        ),
      ),
    );
  }
}

const double _boltWidth = 10;
const double _boltHeight = 16;

class _BoltPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  _BoltPainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / _boltWidth;
    final double scaleY = size.height / _boltHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double dx = (size.width - _boltWidth * scale) / 2;
    final double dy = (size.height - _boltHeight * scale) / 2;

    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final path = Path();
    path.moveTo(0, 8.92);
    path.cubicTo(0, 9.15, .18, 9.33, .45, 9.33);
    path.lineTo(4.59, 9.33);
    path.lineTo(2.40, 15.27);
    path.cubicTo(2.15, 15.92, 2.82, 16.26, 3.25, 15.73);
    path.lineTo(9.84, 7.49);
    path.cubicTo(9.95, 7.35, 10.01, 7.22, 10.01, 7.07);
    path.cubicTo(10.01, 6.84, 9.84, 6.65, 9.57, 6.65);
    path.lineTo(5.43, 6.65);
    path.lineTo(7.61, .73);
    path.cubicTo(7.86, .07, 7.19, -.27, 6.76, .27);
    path.lineTo(.17, 8.50);
    path.cubicTo(.06, 8.64, 0, 8.77, 0, 8.92);
    path.close();

    final paint = Paint()
      ..style = .fill
      ..color = color
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);

    final strokePaint = Paint()
      ..style = .stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..isAntiAlias = true;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _BoltPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth || oldDelegate.color != color;
  }
}

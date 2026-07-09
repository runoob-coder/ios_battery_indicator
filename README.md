# 🔋 iOS Battery Indicator

A Flutter widget that replicates the native iOS battery indicator, including
support for iOS 27 style and automatic system battery monitoring.

[![Pub Version](https://img.shields.io/pub/v/ios_battery_indicator.svg)](https://pub.dev/packages/ios_battery_indicator)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter Demo](https://img.shields.io/badge/demo-Flutter-brightgreen.svg)](https://runoob-coder.github.io/ios_battery_indicator/)
[![API Reference](https://img.shields.io/badge/API-Reference-0175C2.svg)](https://pub.dev/documentation/ios_battery_indicator/latest/)
[![GitHub stars](https://img.shields.io/github/stars/runoob-coder/ios_battery_indicator.svg?style=social)](https://github.com/runoob-coder/ios_battery_indicator)

Language: English | [中文](https://github.com/runoob-coder/ios_battery_indicator/blob/master/README_CN.md)

| [![iOS Battery Indicator](https://github.com/runoob-coder/ios_battery_indicator/raw/master/screenshots/1.png)](https://runoob-coder.github.io/ios_battery_indicator/) | [![iOS Battery Indicator](https://github.com/runoob-coder/ios_battery_indicator/raw/master/screenshots/2.png)](https://runoob-coder.github.io/ios_battery_indicator/) | [![iOS Battery Indicator](https://github.com/runoob-coder/ios_battery_indicator/raw/master/screenshots/3.png)](https://runoob-coder.github.io/ios_battery_indicator/) | [![iOS Battery Indicator](https://github.com/runoob-coder/ios_battery_indicator/raw/master/screenshots/4.png)](https://runoob-coder.github.io/ios_battery_indicator/) |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|

## ✨ Features

- **Native iOS look & feel** — faithfully reproduces the iOS battery icon with
  rounded superellipse shape and proper sizing.
- **Automatic system battery** — reads battery level, charging state, and
  low-power mode from the device in real time when no manual value is supplied.
- **System event callbacks** — `onBatteryLevelChanged` and
  `onBatteryStateChanged` notify the parent when system values change in auto
  mode.
- **Manual control** — optionally pass `batteryLevel`, `batteryState`, and
  `isInBatterySaveMode` for demo or custom scenarios.
- **iOS 27 style** — supports the new borderless design introduced in iOS 27,
  with automatic detection of the iOS version.
- **Charging bolt overlay** — renders a bolt (⚡) glyph using the native
  Cupertino icon font when the battery is charging.
- **Cutout percentage** — in normal discharging mode, the percentage text is
  punched through the fill using a cutout effect for a polished look.
- **Low battery warning** — the indicator turns red when the battery level
  drops below a configurable threshold (10–30, defaults to 20).
- **Battery save mode** — the track turns yellow when low-power mode is active.
- **Real-time save-mode monitoring** — `monitorBatterySaveMode` polls Low Power Mode (auto mode only; poll interval configurable via `saveModePollInterval`, default 30s; supported on Android, iOS, macOS and Windows; not on web or other platforms).
- **Light / Dark mode** — automatically adapts to the ambient `Brightness`, or
  force a specific brightness via the `brightness` property.
- **Smooth animations** — animated fill level, color changes, charging bolt
  transitions, and crossfade between basic and percentage display. All
  animation durations are configurable via `animationDuration`.
- **Charging sound** — optionally play the native iOS charging sound
  (`connectedToPower`) when entering the charging state in manual mode
  (iOS only).

## 🚀 Getting started

Install via pub.dev → [pub.dev/packages/ios_battery_indicator/install](https://pub.dev/packages/ios_battery_indicator/install)

[Live Demo](https://runoob-coder.github.io/ios_battery_indicator/) — try it out online

### ⚙️ Platform setup

This package depends on `battery_plus` and `device_info_plus`. No additional
configuration is required for iOS and macOS. For Android, ensure the
`android/app/build.gradle.kts` targets API 21 or higher (the default Flutter
template already satisfies this).

## 📖 Usage

### 🤖 Auto mode (system battery)

The simplest usage — the widget reads everything from the device:

```dart
IosBatteryIndicator();
```

You can configure how often the system battery level is polled (default 30s):

```dart
IosBatteryIndicator(
  batteryLevelPollInterval: const Duration(seconds: 15), // level poll interval (default 30s)
);
```

- Battery percentage display is enabled by default.
- Listen to `Battery.onBatteryStateChanged` for real-time state updates.
- Automatically detect iOS 27+ and render the borderless style.

### 🎮 Manual control

Provide explicit values to bypass the system readings:

```dart
IosBatteryIndicator(
  batteryLevel: 80,
  batteryState: BatteryState.charging,
);
```

### 🎛️ Controlling display options

```dart
IosBatteryIndicator(
  showBatteryPercentage: false, // hide the percentage number
  chargingWithBolt: false,      // hide the bolt when charging
);
```

### 🔊 Charging sound (iOS only)

When in manual mode, you can play the native iOS charging sound when the
battery state is set to `BatteryState.charging`:

```dart
IosBatteryIndicator(
  batteryState: BatteryState.charging,
  playChargingSound: true, // play iOS charging sound
);
```

> [!NOTE]
> This feature requires the [ios_system_sound](https://pub.dev/packages/ios_system_sound)
> package and is only supported on iOS. It has no effect on the web or other
> platforms, and is ignored in auto mode (when `batteryState` is `null`).

### 🎨 Styling

```dart
IosBatteryIndicator(
  isIOS27Style: true,            // force iOS 27 borderless style
  brightness: Brightness.dark,   // force dark mode colors
  lowBatteryThreshold: 15,       // turn red when ≤ 15%
  animationDuration: const Duration(milliseconds: 500),  // slow down animations
);
```

### 📐 Sizing

Use `height` or`width` (mutually exclusive) to scale it:

```dart
IosBatteryIndicator(height: 36); // 36 logical pixels tall, width auto
```

```dart
IosBatteryIndicator(width: 40); // 40 logical pixels wide, height auto
```

### 📡 Callbacks

Receive real-time system battery updates when in auto mode:

```dart
IosBatteryIndicator(
  onBatteryLevelChanged: (level) => print('Battery: $level%'),
  onBatteryStateChanged: (state) => print('State: $state'),
);
```

> [!NOTE]
> These callbacks only fire when `batteryLevel` / `batteryState` is
> `null` (system mode). When providing manual values, use your own state
> management instead.

### 🔋 Battery save mode monitoring

By default the system Low Power Mode is read only once when the widget
initializes. To keep it in sync when the user toggles it at runtime, enable
`monitorBatterySaveMode` — this only takes effect when `isInBatterySaveMode`
is `null` (system mode). Note this is only supported on Android, iOS, macOS
and Windows — it has no effect on web or other platforms:

```dart
IosBatteryIndicator(
  isInBatterySaveMode: null,     // read from the system
  monitorBatterySaveMode: true,   // re-poll periodically
  saveModePollInterval: const Duration(seconds: 10), // poll interval (default 30s)
);
```

> [!NOTE]
> This has no effect when `isInBatterySaveMode` is explicitly provided.

### 🖌️ Custom theme

You can customize the colors by providing a `BatteryIndicatorTheme` via
`ThemeData.extensions`:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      BatteryIndicatorTheme(
        bgColor: Colors.grey.withValues(alpha: .3),
        dischargingTrackColor: Colors.blue,
        contentColor: Colors.blue,
        contentAntiColor: Colors.white,
      ),
    ],
  ),
  home: /* ... */,
);
```

For Cupertino apps, wrap the indicator in a `Theme` widget or use
`CupertinoThemeData` extensions.

## 📚 API reference

### 🧩 `IosBatteryIndicator`

| Property                 | Type            | Default                   | Description                                                        |
|--------------------------|-----------------|---------------------------|--------------------------------------------------------------------|
| `height`                 | `double?`       | `null`                    | Preferred height. Mutually exclusive with `width`.                 |
| `width`                  | `double?`       | `null`                    | Preferred width. Mutually exclusive with `height`.                 |
| `batteryLevel`           | `int?`          | `null`                    | Battery level 0–100. When `null`, read from the system.            |
| `batteryLevelPollInterval` | `Duration`   | `30s`                     | Interval between battery-level polls in system mode.               |
| `batteryState`           | `BatteryState?` | `null`                    | Charging / discharging / full. When `null`, read from the system.  |
| `showBatteryPercentage`  | `bool`          | `true`                    | Show the percentage number inside the indicator.                   |
| `isInBatterySaveMode`    | `bool?`         | `null`                    | Low-power mode. When `null`, read from the system.                 |
| `monitorBatterySaveMode` | `bool`          | `false`                   | Poll system Low Power Mode when `isInBatterySaveMode` is `null`. Supported on Android, iOS, macOS and Windows only (no effect on web or other platforms). |
| `saveModePollInterval`   | `Duration`     | `30s`                     | Interval between save-mode polls when `monitorBatterySaveMode` is `true`. |
| `lowBatteryThreshold`    | `int`           | `20`                      | Low Battery Threshold (10–30) below which the indicator turns red. |
| `chargingWithBolt`       | `bool`          | `true`                    | Show a bolt icon when charging. Only effective when `batteryState` is `.charging`. |
| `playChargingSound`      | `bool`          | `false`                   | Play iOS charging sound in manual mode (iOS only).                 |
| `isIOS27Style`           | `bool?`         | `null`                    | Force iOS 27 style. When `null`, auto-detect the iOS version.      |
| `brightness`             | `Brightness?`   | `null`                    | Force light or dark colors. When `null`, use ambient brightness.   |
| `animationDuration`      | `Duration`      | `Duration(milliseconds: 250)` | Duration for battery indicator animations (fill, colors, bolt). |
| `themeAnimationDuration` | `Duration`      | `kThemeAnimationDuration` | Animation duration for theme transitions.                          |
| `onBatteryLevelChanged`  | `ValueChanged<int>?` | `null`               | Called when system battery level changes (system mode only).       |
| `onBatteryStateChanged`  | `ValueChanged<BatteryState>?` | `null`         | Called when system battery state changes (system mode only).       |

### 🎨 `BatteryIndicatorTheme`

| Property                | Type    | Description                                             |
|-------------------------|---------|---------------------------------------------------------|
| `bgColor`               | `Color` | Background / border color of the battery shell.         |
| `dischargingTrackColor` | `Color` | Fill color when discharging (normal state).             |
| `contentColor`          | `Color` | Color used for the bolt icon and cutout text outline.   |
| `contentAntiColor`      | `Color` | Color used for the percentage text in plain-style mode. |

Factory constructors `BatteryIndicatorTheme.light()` and
`BatteryIndicatorTheme.dark()` provide sensible defaults.

### 👁️ Visual states

| Condition                 | Appearance                                              |
|---------------------------|---------------------------------------------------------|
| Normal discharging        | Shell border + solid fill proportional to level.        |
| Charging                  | Green fill + bolt icon (if `chargingWithBolt` is true). |
| Full (100%)               | Green fill + no bolt.                                   |
| Low battery (≤ threshold) | Red fill, solid (no cutout).                            |
| Battery save mode         | Yellow fill.                                            |

## ℹ️ Additional information

- **Repository**: [github.com/runoob-coder/ios_battery_indicator](https://github.com/runoob-coder/ios_battery_indicator)
- **Issue tracker**: [github.com/runoob-coder/ios_battery_indicator/issues](https://github.com/runoob-coder/ios_battery_indicator/issues)
- **Example app**: See the `example/` directory for a full interactive demo
  that lets you tweak every property in real time.
- **Contributions**: Pull requests and issues are welcome!

## 💛 Support

If `ios_battery_indicator` helps you build better UIs, please consider supporting it.  
It only takes a few seconds and helps other Flutter developers discover the library.

- ⭐ [Star on GitHub](https://github.com/runoob-coder/ios_battery_indicator)
- 👍 [Like on pub.dev](https://pub.dev/packages/ios_battery_indicator)

## ☕️ Buy Me a Coffee

<a href="https://ko-fi.com/noob_coder" target="_blank">
  <img src="https://storage.ko-fi.com/cdn/kofi6.png" alt="Buy Me a Coffee at ko-fi.com" />
</a>
## 1.4.0

- ✨ Add configurable `batteryLevelPollInterval` for the battery-level poll in system mode (default 30s)

## 1.3.0

- ✨ Add `monitorBatterySaveMode` to poll Low Power Mode at runtime when `isInBatterySaveMode` is `null`, with configurable `saveModePollInterval` (default 30s)

## 1.2.7

- 🎨 Shrink fill bar height at low battery (< 20%) in classic style to match corner radius
- 🐛 Fix `AnimatedSwitcher` key for classic style so charging/bolt transitions animate
- ✨ Use `w800` font weight at 100%, `w700` otherwise, for percentage text

## 1.2.6

- 🎬 Unify crossfade animation for both iOS 27 and non-iOS 27 styles in basic battery mode

## 1.2.5

- 🎨 Restore cutout percentage style when battery is full — plain fill now only applies when charging or critically low
- 🎨 Use `FontFeature.tabularFigures()` for percentage text to prevent digit-width jitter
- 🎨 Shrink positive pole diameter from 4.2 to 3.9 for better visual proportion
- 🎨 Prevent "100" text overflow by reducing scale when battery is full
- 🎨 Reduce minimum fill bar from 5% to 2% for more accurate low-level display

## 1.2.4

- 📝 Fix screenshot images and language link in README — use absolute GitHub URLs so they render correctly on pub.dev

## 1.2.3

- 📦 Add `platforms` declaration to `pubspec.yaml` for all supported platforms

## 1.2.2

- 🎨 Refine battery indicator layout and fill animation for smoother, more polished appearance
- 🐛 Fix `chargingWithBolt` display logic
- 🧹 Simplify positive pole color logic by delegating to `_trackColor(theme)`

## 1.2.1

- 🎨 Refine percentage text rendering: increase font size from 12 to 13, remove letter spacing for cleaner appearance
- 🎨 Adjust bolt icon size from 10 to 9.6 for better visual balance with percentage text
- 🎨 Remove `Transform.scale` wrappers from percentage text and cutout mask, use `Padding` inset instead for more predictable layout

## 1.2.0

- 🔊 **New `playChargingSound` parameter** — optionally play the native iOS charging sound (`connectedToPower`) when entering the charging state in manual mode. Uses the [ios_system_sound](https://pub.dev/packages/ios_system_sound) package and is only supported on iOS. Disabled by default.

## 1.1.0

- 📡 **New callbacks** — added `onBatteryLevelChanged` and `onBatteryStateChanged` to receive real-time system battery updates in auto mode
- 🐛 Fix percentage text vertical misalignment by applying `TextHeightBehavior` to suppress extra ascent/descent

## 1.0.3

- 🎬 Added `animationDuration` parameter to control all indicator animations, including fill progress, color changes, bolt icon, and crossfade transitions
- 🎨 Fix cutout percentage text overflow by wrapping `maskChild` with `FittedBox` for proper scaling

## 1.0.2

- 🎨 Adjust text rendering: wrap battery indicator in `DefaultTextStyle` with `height: 1` and `fontWeight: .w500` for consistent typography
- 🎨 Refine cutout percentage font size from 14 to 13 for better visual balance
- 📱 Update example app defaults: battery state set to charging, percentage display toggled off
- 🔧 Fix formatting of Repository and Issue tracker links in README
- 🌐 Improve example web page SEO: update meta description, keywords, title, and apple-mobile-web-app-title
- 📝 Add class-level documentation comment to `IosBatteryIndicator`
- 📦 Include `screenshots/` in published package files

## 1.0.1

- 📝 Improve code formatting in README and README_CN documentation examples
- Bump version to 1.0.1

## 1.0.0

- 🎉 Initial stable release
- **Core widget**: Added `IosBatteryIndicator` widget that faithfully replicates the native iOS battery indicator
- **Auto system battery monitoring**: Reads battery level, charging state, and low-power mode from the device in real time
- **Manual control mode**: Supports manually specifying battery state via `batteryLevel`, `batteryState`, and `isInBatterySaveMode`
- **iOS 27 style support**: Supports the new borderless design introduced in iOS 27, with automatic iOS version detection
- **Charging bolt overlay**: Renders a bolt (⚡) icon using the native Cupertino icon font when the battery is charging
- **Cutout percentage effect**: Percentage text is punched through the fill using a cutout effect for a polished look when discharging
- **Low battery warning**: Indicator turns red when the battery level drops below a configurable threshold (10–30, defaults to 20)
- **Battery save mode**: Track turns yellow when low-power mode is active
- **Light / Dark mode**: Automatically adapts to ambient `Brightness`, with an option to force a specific brightness via the `brightness` property
- **Smooth animations**: Uses `AnimatedSwitcher` for display mode transitions and `AnimatedTheme` for theme transitions
- **Flexible sizing**: Supports scaling via `height` or `width` properties (mutually exclusive)
- **Display option controls**: Supports `showBatteryPercentage` to hide the percentage number and `chargingWithBolt` to hide the charging bolt icon
- **Custom theme**: Added `BatteryIndicatorTheme`, supports custom color schemes via `ThemeData.extensions`, with built-in `.light()` and `.dark()` factory constructors

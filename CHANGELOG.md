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

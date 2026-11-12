# iOS Battery Indicator Demo

## Preview

```bash
cd example
flutter widget-preview clean
flutter widget-preview start
```

## Localization

The demo follows the device language by default and supports English (`en`) and Simplified Chinese (`zh`). The language dropdown at the top of the settings list overrides it for the current session; "Follow System" / "跟随系统" restores the device language.

Translations live in `lib/l10n/app_en.arb` (template) and `lib/l10n/app_zh.arb`. Run `flutter gen-l10n` after editing them (configuration is in `l10n.yaml`). To add a language, add `app_<locale>.arb` and list the locale in `CFBundleLocalizations` in `ios/Runner/Info.plist` and `macos/Runner/Info.plist`.

// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// App title shown in the navigation bar and used as the localized task-switcher title.
  ///
  /// In en, this message translates to:
  /// **'iOS Battery Indicator Demo'**
  String get appTitle;

  /// Header of the section that contains the in-app language selector.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionHeader;

  /// Label of the language dropdown.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get languageSetting;

  /// Dropdown option that makes the app use the device language.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get languageFollowSystem;

  /// English language option, written in its own language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Simplified Chinese language option, written in its own language.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// Summary of the current preview settings.
  ///
  /// In en, this message translates to:
  /// **'Level: {level} | State: {state} | {style}'**
  String statusLine(String level, String state, String style);

  /// A battery percentage value with its percent sign.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentValue(String value);

  /// Name of the borderless iOS 27 indicator style.
  ///
  /// In en, this message translates to:
  /// **'iOS 27 Style'**
  String get styleIOS27;

  /// Name of the classic outlined indicator style.
  ///
  /// In en, this message translates to:
  /// **'Classic Style'**
  String get styleClassic;

  /// Battery state: the device is running on battery.
  ///
  /// In en, this message translates to:
  /// **'Discharging'**
  String get stateDischarging;

  /// Battery state: the device is plugged in.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get stateCharging;

  /// Battery state: the battery is fully charged.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get stateFull;

  /// Battery state: power is connected but the battery is not charging.
  ///
  /// In en, this message translates to:
  /// **'Plugged'**
  String get stateConnectedNotCharging;

  /// Battery state: the current battery state is unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get stateUnknown;

  /// Header of the basic settings section.
  ///
  /// In en, this message translates to:
  /// **'Basic Settings'**
  String get basicSettings;

  /// Switch that reads the real device battery instead of the simulated level.
  ///
  /// In en, this message translates to:
  /// **'Use System Battery'**
  String get useSystemBattery;

  /// Label of the slider that sets the simulated battery level.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get batteryLevel;

  /// Label of the segmented control that sets the simulated battery state.
  ///
  /// In en, this message translates to:
  /// **'Battery State'**
  String get batteryState;

  /// Switch that polls the device low power mode.
  ///
  /// In en, this message translates to:
  /// **'Monitor Battery Save Mode'**
  String get monitorBatterySaveMode;

  /// Explanation of the low power mode polling interval.
  ///
  /// In en, this message translates to:
  /// **'Poll Low Power Mode every 30s'**
  String get monitorBatterySaveModeHint;

  /// Header of the display options section.
  ///
  /// In en, this message translates to:
  /// **'Display Options'**
  String get displayOptions;

  /// Switch that shows the percentage text inside the indicator.
  ///
  /// In en, this message translates to:
  /// **'Show Battery Percentage'**
  String get showBatteryPercentage;

  /// Switch that uses monospaced digits for the percentage.
  ///
  /// In en, this message translates to:
  /// **'Use Tabular Figures'**
  String get useTabularFigures;

  /// Explanation of the tabular figures behavior.
  ///
  /// In en, this message translates to:
  /// **'Monospaced digits (no shift); disabled at 100%'**
  String get useTabularFiguresHint;

  /// Switch that enables the charging sound.
  ///
  /// In en, this message translates to:
  /// **'Play Charging Sound'**
  String get playChargingSound;

  /// Explanation of when the charging sound is played.
  ///
  /// In en, this message translates to:
  /// **'Only plays when charging'**
  String get playChargingSoundHint;

  /// Switch that shows the bolt icon while charging.
  ///
  /// In en, this message translates to:
  /// **'Show Bolt When Charging'**
  String get showBoltWhenCharging;

  /// Switch that renders the indicator in low power mode.
  ///
  /// In en, this message translates to:
  /// **'Battery Save Mode'**
  String get batterySaveMode;

  /// Header of the style settings section.
  ///
  /// In en, this message translates to:
  /// **'Style Settings'**
  String get styleSettings;

  /// Explanation of the iOS 27 indicator style.
  ///
  /// In en, this message translates to:
  /// **'Use iOS 27+ borderless design'**
  String get ios27StyleHint;

  /// Label of the light/dark theme segmented control.
  ///
  /// In en, this message translates to:
  /// **'Theme Brightness'**
  String get themeBrightness;

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get brightnessLight;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get brightnessDark;

  /// Header of the advanced settings section.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// Label of the slider that sets the indicator height.
  ///
  /// In en, this message translates to:
  /// **'Widget Size'**
  String get widgetSize;

  /// Label of the slider that sets the low battery threshold.
  ///
  /// In en, this message translates to:
  /// **'Low Battery Threshold'**
  String get lowBatteryThreshold;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

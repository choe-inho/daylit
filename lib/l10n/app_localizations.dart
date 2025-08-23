import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ko'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'DayLit'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @quest.
  ///
  /// In en, this message translates to:
  /// **'Quest'**
  String get quest;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your goals with us'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in easily and create a better day'**
  String get loginSubtitle;

  /// No description provided for @kakao.
  ///
  /// In en, this message translates to:
  /// **'KAKAO'**
  String get kakao;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'GOOGLE'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'APPLE'**
  String get apple;

  /// No description provided for @discord.
  ///
  /// In en, this message translates to:
  /// **'DISCORD'**
  String get discord;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with {provider}'**
  String continueWith(String provider);

  /// No description provided for @settingsAccountPayment.
  ///
  /// In en, this message translates to:
  /// **'Account & Payment'**
  String get settingsAccountPayment;

  /// No description provided for @settingsAppSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settingsAppSettings;

  /// No description provided for @settingsInfoPolicy.
  ///
  /// In en, this message translates to:
  /// **'Info & Policy'**
  String get settingsInfoPolicy;

  /// No description provided for @settingsAccountManagement.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get settingsAccountManagement;

  /// No description provided for @litCharge.
  ///
  /// In en, this message translates to:
  /// **'Charge Lit'**
  String get litCharge;

  /// No description provided for @litChargeDesc.
  ///
  /// In en, this message translates to:
  /// **'Charge Lit to use more features'**
  String get litChargeDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @colorMode.
  ///
  /// In en, this message translates to:
  /// **'Color Mode'**
  String get colorMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @usagePolicy.
  ///
  /// In en, this message translates to:
  /// **'Usage Policy'**
  String get usagePolicy;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version Info'**
  String get versionInfo;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @colorModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Mode'**
  String get colorModeTitle;

  /// No description provided for @colorModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your app\'s color theme'**
  String get colorModeDesc;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'Follow System Settings'**
  String get systemMode;

  /// No description provided for @systemModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically changes according to device settings'**
  String get systemModeDesc;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @lightModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Fixed to bright theme'**
  String get lightModeDesc;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Fixed to dark theme'**
  String get darkModeDesc;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageTitle;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the language to use in the app'**
  String get languageDesc;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language has been changed'**
  String get languageChanged;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @emptyQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'What goal would you like\nto set and pursue?'**
  String get emptyQuestTitle;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoal;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @regDate.
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
  String get regDate;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get none;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

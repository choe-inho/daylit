// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DayLit';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get quest => 'Quest';

  @override
  String get loginTitle => 'Start your goals with us';

  @override
  String get loginSubtitle => 'Log in easily and create a better day';

  @override
  String get kakao => 'KAKAO';

  @override
  String get google => 'GOOGLE';

  @override
  String get apple => 'APPLE';

  @override
  String get discord => 'DISCORD';

  @override
  String continueWith(String provider) {
    return 'Continue with $provider';
  }

  @override
  String get settingsAccountPayment => 'Account & Payment';

  @override
  String get settingsAppSettings => 'App Settings';

  @override
  String get settingsInfoPolicy => 'Info & Policy';

  @override
  String get settingsAccountManagement => 'Account Management';

  @override
  String get litCharge => 'Charge Lit';

  @override
  String get litChargeDesc => 'Charge Lit to use more features';

  @override
  String get language => 'Language';

  @override
  String get colorMode => 'Color Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get usagePolicy => 'Usage Policy';

  @override
  String get licenses => 'Licenses';

  @override
  String get versionInfo => 'Version Info';

  @override
  String get logout => 'Logout';

  @override
  String get colorModeTitle => 'Color Mode';

  @override
  String get colorModeDesc => 'Choose your app\'s color theme';

  @override
  String get systemMode => 'Follow System Settings';

  @override
  String get systemModeDesc =>
      'Automatically changes according to device settings';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get lightModeDesc => 'Fixed to bright theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Fixed to dark theme';

  @override
  String get languageTitle => 'Language Settings';

  @override
  String get languageDesc => 'Choose the language to use in the app';

  @override
  String get languageChanged => 'Language has been changed';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get later => 'Later';

  @override
  String get update => 'Update';

  @override
  String get loading => 'Loading...';

  @override
  String get emptyQuestTitle => 'What goal would you like\nto set and pursue?';

  @override
  String get newGoal => 'New Goal';

  @override
  String get email => 'E-mail';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get regDate => 'Join Date';

  @override
  String get none => 'Unknown';
}

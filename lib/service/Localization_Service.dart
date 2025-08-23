import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class LocalizationService {
  static const List<Locale> supportedLocales = [
    Locale('ko', 'KR'), // 한국어
    Locale('en', 'US'), // 영어
  ];

  static const Locale fallbackLocale = Locale('en', 'US');

  /// 지원하는 언어인지 확인
  static bool isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
    supportedLocale.languageCode == locale.languageCode);
  }

  /// 언어 코드를 Locale로 변환
  static Locale getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return const Locale('ko', 'KR');
      case 'en':
        return const Locale('en', 'US');
      default:
        return fallbackLocale;
    }
  }

  /// Locale을 언어 코드로 변환
  static String getLanguageCodeFromLocale(Locale locale) {
    return locale.languageCode;
  }

  /// 언어 표시명 반환 (네이티브 언어로)
  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      default:
        return 'English';
    }
  }

  /// 국기 이모지 반환
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '🇰🇷';
      case 'en':
        return '🇺🇸';
      default:
        return '🇺🇸';
    }
  }
}

/// BuildContext 확장으로 쉬운 접근
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String get languageCode => Localizations.localeOf(this).languageCode;

  bool get isKorean => languageCode == 'ko';
  bool get isEnglish => languageCode == 'en';
}
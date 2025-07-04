import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DaylitColors {
  // 프라이빗 생성자
  DaylitColors._();

  // ==================== 브랜드 컬러 (테마 독립적) ====================

  /// 브랜드 프라이머리 컬러
  static const Color brandPrimary = Color(0xFF6BB6FF);
  static const Color brandSecondary = Color(0xFF87CEEB);
  static const Color brandAccent = Color(0xFF4A9EFF);

  // ==================== 라이트 테마 ====================

  static const _LightColors light = _LightColors();

  // ==================== 다크 테마 ====================

  static const _DarkColors dark = _DarkColors();

  // ==================== 상태 컬러 (테마 공통) ====================

  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF2563EB);

  // ==================== 현재 테마에 따른 컬러 반환 ====================

  /// 현재 테마의 컬러 반환
  static _ColorScheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? light : dark;
  }

  /// 상태별 컬러 (테마 고려)
  static Color getStatusColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'done':
        return isDark ? successDark : success;
      case 'warning':
      case 'pending':
        return isDark ? warningDark : warning;
      case 'error':
      case 'failed':
        return isDark ? errorDark : error;
      case 'info':
      case 'default':
      default:
        return isDark ? infoDark : info;
    }
  }

  // ==================== TEXT THEME ====================

  /// 라이트 테마 TextTheme
  static TextTheme getLightTextTheme() {
    return TextTheme(
      // Display 스타일 (가장 큰 텍스트)
      displayLarge: TextStyle(
        fontSize: 57.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),
      displayMedium: TextStyle(
        fontSize: 45.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),
      displaySmall: TextStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),

      // Headline 스타일 (제목)
      headlineLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),
      headlineMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),
      headlineSmall: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),

      // Title 스타일 (섹션 제목)
      titleLarge: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),
      titleMedium: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),
      titleSmall: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),

      // Body 스타일 (본문)
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: light.textPrimary,
        fontFamily: 'pre',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: light.textPrimary,
        fontFamily: 'pre',
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: light.textSecondary,
        fontFamily: 'pre',
        height: 1.33,
      ),

      // Label 스타일 (버튼, 라벨)
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: light.textPrimary,
        fontFamily: 'pre',
      ),
      labelSmall: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: light.textSecondary,
        fontFamily: 'pre',
      ),
    );
  }

  /// 다크 테마 TextTheme
  static TextTheme getDarkTextTheme() {
    return TextTheme(
      // Display 스타일 (가장 큰 텍스트)
      displayLarge: TextStyle(
        fontSize: 57.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),
      displayMedium: TextStyle(
        fontSize: 45.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),
      displaySmall: TextStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),

      // Headline 스타일 (제목)
      headlineLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),
      headlineMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),
      headlineSmall: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),

      // Title 스타일 (섹션 제목)
      titleLarge: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),
      titleMedium: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),
      titleSmall: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),

      // Body 스타일 (본문)
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: dark.textPrimary,
        fontFamily: 'pre',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: dark.textPrimary,
        fontFamily: 'pre',
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: dark.textSecondary,
        fontFamily: 'pre',
        height: 1.33,
      ),

      // Label 스타일 (버튼, 라벨)
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: dark.textPrimary,
        fontFamily: 'pre',
      ),
      labelSmall: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: dark.textSecondary,
        fontFamily: 'pre',
      ),
    );
  }

  // ==================== 커스텀 텍스트 스타일 ====================

  /// 버튼 텍스트 스타일
  static TextStyle buttonLarge({bool isDark = false}) => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'pre',
  );

  static TextStyle buttonMedium({bool isDark = false}) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'pre',
  );

  static TextStyle buttonSmall({bool isDark = false}) => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'pre',
  );

  /// 입력 필드 텍스트 스타일
  static TextStyle inputText({bool isDark = false}) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: isDark ? dark.textPrimary : light.textPrimary,
    fontFamily: 'pre',
  );

  static TextStyle inputLabel({bool isDark = false}) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: isDark ? dark.textSecondary : light.textSecondary,
    fontFamily: 'pre',
  );

  static TextStyle inputHint({bool isDark = false}) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: isDark ? dark.textHint : light.textHint,
    fontFamily: 'pre',
  );

  /// 카드 텍스트 스타일
  static TextStyle cardTitle({bool isDark = false}) => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: isDark ? dark.textPrimary : light.textPrimary,
    fontFamily: 'pre',
  );

  static TextStyle cardSubtitle({bool isDark = false}) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: isDark ? dark.textSecondary : light.textSecondary,
    fontFamily: 'pre',
  );

  /// 네비게이션 텍스트 스타일
  static TextStyle navLabel({bool isDark = false, bool isSelected = false}) => TextStyle(
    fontSize: 10.sp,
    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
    color: isSelected
        ? brandPrimary
        : (isDark ? dark.textSecondary : light.textSecondary),
    fontFamily: 'pre',
  );

  /// 그라데이션 텍스트용 베이스 스타일
  static TextStyle gradientBase({required double fontSize, FontWeight? fontWeight}) => TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight ?? FontWeight.w600,
    color: Colors.white, // 그라데이션이 적용되므로 흰색
    fontFamily: 'pre',
  );

  // ==================== Flutter 테마 데이터 생성 ====================

  /// 라이트 테마 데이터
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: brandPrimary,
        onPrimary: light.onPrimary,
        secondary: brandSecondary,
        onSecondary: light.onSecondary,
        surface: light.surface,
        onSurface: light.onSurface,
        background: light.background,
        onBackground: light.onBackground,
        error: error,
        onError: light.onError,
      ),
      scaffoldBackgroundColor: light.background,
      cardColor: light.cardBackground,
      dividerColor: light.divider,
      shadowColor: light.divider,
      fontFamily: 'pre',
      textTheme: getLightTextTheme(), // TextTheme 적용
    );
  }

  /// 다크 테마 데이터
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: brandSecondary,
        onPrimary: dark.onPrimary,
        secondary: brandPrimary,
        onSecondary: dark.onSecondary,
        surface: dark.surface,
        onSurface: dark.onSurface,
        background: dark.background,
        onBackground: dark.onBackground,
        error: errorDark,
        onError: dark.onError,
      ),
      scaffoldBackgroundColor: dark.background,
      cardColor: dark.cardBackground,
      dividerColor: dark.divider,
      shadowColor: dark.divider,
      fontFamily: 'pre',
      textTheme: getDarkTextTheme(), // TextTheme 적용
    );
  }
}

// ==================== 컬러 스킴 추상 클래스 ====================

abstract class _ColorScheme {
  // 배경 관련
  Color get background;
  Color get surface;
  Color get cardBackground;

  // 텍스트 관련
  Color get onPrimary;
  Color get onSecondary;
  Color get onSurface;
  Color get onBackground;
  Color get onError;

  Color get textPrimary;
  Color get textSecondary;
  Color get textHint;

  // UI 요소
  Color get divider;
  Color get border;
  Color get shadow;
  Color get overlay;
  Color get disabled;

  // 그라데이션
  LinearGradient get primaryGradient;
  LinearGradient get backgroundGradient;
}

// ==================== 라이트 테마 구현 ====================

class _LightColors implements _ColorScheme {
  const _LightColors();

  // 배경 관련
  @override
  Color get background => const Color(0xFFF8FAFE);

  @override
  Color get surface => const Color(0xFFFFFFFF);

  @override
  Color get cardBackground => const Color(0xFFFFFFFF);

  // 텍스트 관련
  @override
  Color get onPrimary => const Color(0xFFFFFFFF);

  @override
  Color get onSecondary => const Color(0xFF1F2937);

  @override
  Color get onSurface => const Color(0xFF1F2937);

  @override
  Color get onBackground => const Color(0xFF1F2937);

  @override
  Color get onError => const Color(0xFFFFFFFF);

  @override
  Color get textPrimary => const Color(0xFF1F2937);

  @override
  Color get textSecondary => const Color(0xFF6B7280);

  @override
  Color get textHint => const Color(0xFF9CA3AF);

  // UI 요소
  @override
  Color get divider => const Color(0xFFE5E7EB);

  @override
  Color get border => const Color(0xFFD1D5DB);

  @override
  Color get shadow => DaylitColors.brandPrimary.withValues(alpha: 0.1);

  @override
  Color get overlay => const Color(0xFF000000).withValues(alpha: 0.5);

  @override
  Color get disabled => const Color(0xFF9CA3AF);

  // 그라데이션
  @override
  LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      DaylitColors.brandSecondary,
      DaylitColors.brandPrimary,
      DaylitColors.brandAccent,
    ],
  );

  @override
  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      background,
      const Color(0xFFF1F5F9),
    ],
  );
}

// ==================== 다크 테마 구현 ====================

class _DarkColors implements _ColorScheme {
  const _DarkColors();

  // 배경 관련
  @override
  Color get background => const Color(0xFF0F172A);

  @override
  Color get surface => const Color(0xFF1E293B);

  @override
  Color get cardBackground => const Color(0xFF1E293B);

  // 텍스트 관련
  @override
  Color get onPrimary => const Color(0xFF0F172A);

  @override
  Color get onSecondary => const Color(0xFFE2E8F0);

  @override
  Color get onSurface => const Color(0xFFE2E8F0);

  @override
  Color get onBackground => const Color(0xFFE2E8F0);

  @override
  Color get onError => const Color(0xFFFFFFFF);

  @override
  Color get textPrimary => const Color(0xFFE2E8F0);

  @override
  Color get textSecondary => const Color(0xFF94A3B8);

  @override
  Color get textHint => const Color(0xFF64748B);

  // UI 요소
  @override
  Color get divider => const Color(0xFF334155);

  @override
  Color get border => const Color(0xFF475569);

  @override
  Color get shadow => const Color(0xFF000000).withValues(alpha: 0.3);

  @override
  Color get overlay => const Color(0xFF000000).withValues(alpha: 0.7);

  @override
  Color get disabled => const Color(0xFF64748B);

  // 그라데이션
  @override
  LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      DaylitColors.brandSecondary,
      DaylitColors.brandPrimary,
      DaylitColors.brandAccent,
    ],
  );

  @override
  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      background,
      const Color(0xFF1E293B),
    ],
  );
}

// ==================== EXTENSION FOR EASY ACCESS ====================

/// BuildContext를 통한 간편한 텍스트 스타일 접근
extension DaylitTextThemeExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  // 다크 테마 여부 확인
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
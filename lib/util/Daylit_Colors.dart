import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ==================== 메인 컬러 시스템 (기존 구조 유지) ====================
/// DayLit 앱의 전체 컬러 시스템을 관리하는 클래스
///
/// 이 클래스는 다음을 제공합니다:
/// - 브랜드 컬러 (테마 독립적)
/// - 라이트/다크 테마 컬러
/// - 상태 컬러 (성공, 경고, 에러 등)
/// - 텍스트 스타일 및 테마 데이터
/// - 다양한 그라데이션 (브랜드, 상태별, 비활성)
class DaylitColors {
  // Private 생성자 - 인스턴스 생성 방지
  DaylitColors._();

  // ==================== 브랜드 컬러 (테마 독립적) ====================
  /// 브랜드 메인 컬러 (파란색)
  static const Color brandPrimary = Color(0xFF6BB6FF);

  /// 브랜드 보조 컬러 (하늘색)
  static const Color brandSecondary = Color(0xFF87CEEB);

  /// 브랜드 강조 컬러 (진한 파란색)
  static const Color brandAccent = Color(0xFF4A9EFF);

  // ==================== 상태 컬러 (테마 공통) ====================
  /// 성공 상태 컬러
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);

  /// 경고 상태 컬러
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);

  /// 에러 상태 컬러
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);

  /// 정보 상태 컬러
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF2563EB);

  // ==================== 라이트 테마 컬러 ====================
  static const _LightTheme light = _LightTheme();

  // ==================== 다크 테마 컬러 ====================
  static const _DarkTheme dark = _DarkTheme();

  // ==================== 현재 테마 컬러 반환 (기존과 동일) ====================
  /// 현재 테마에 맞는 컬러 스킴 반환
  ///
  /// @param context BuildContext (테마 모드 확인용)
  /// @returns 현재 테마의 컬러 스킴
  static dynamic of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? light : dark;
  }

  /// 현재 테마에 맞는 비활성 그라데이션 반환
  ///
  /// @param context BuildContext (테마 모드 확인용)
  /// @param soft 부드러운 버전 사용 여부 (기본값: false)
  /// @returns 현재 테마의 비활성 그라데이션
  static LinearGradient getDisabledGradient(BuildContext context, {bool soft = false}) {
    final brightness = Theme.of(context).brightness;
    if (soft) {
      return brightness == Brightness.light ? softDisabledGradient : softDisabledGradientDark;
    } else {
      return brightness == Brightness.light ? disabledGradient : disabledGradientDark;
    }
  }

  /// 상태별 컬러 반환 (테마 고려) - 개선된 버전
  ///
  /// @param status 상태 문자열
  /// @param context BuildContext (null 안전성 강화)
  /// @returns 상태에 맞는 컬러
  static Color getStatusColor(String status, {BuildContext? context}) {
    final isDark = context != null ? Theme.of(context).brightness == Brightness.dark : false;

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

  // ==================== 텍스트 스타일 (기존과 동일하되 개선) ====================
  /// 기본 텍스트 스타일 생성
  ///
  /// @param fontSize 폰트 크기
  /// @param fontWeight 폰트 굵기
  /// @param color 텍스트 컬러
  /// @param height 줄 간격 (추가)
  /// @returns TextStyle 객체
  static TextStyle textStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
      fontFamily: 'pre',
      height: height,
    );
  }

  /// 헤딩 텍스트 스타일
  static TextStyle heading1({Color? color}) => textStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.2,
  );

  static TextStyle heading2({Color? color}) => textStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.3,
  );

  static TextStyle heading3({Color? color}) => textStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
  );

  /// 본문 텍스트 스타일
  static TextStyle bodyLarge({Color? color}) => textStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.5,
  );

  static TextStyle bodyMedium({Color? color}) => textStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.5,
  );

  static TextStyle bodySmall({Color? color}) => textStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.4,
  );

  /// 버튼 텍스트 스타일
  static TextStyle buttonText({Color? color}) => textStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color ?? Colors.white,
    height: 1.2,
  );

  /// 캡션 텍스트 스타일
  static TextStyle caption({Color? color}) => textStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: color,
    height: 1.3,
  );

  // ==================== 그라데이션 ====================
  /// 브랜드 그라데이션
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandSecondary, brandPrimary, brandAccent],
  );

  /// 성공 그라데이션
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  /// 경고 그라데이션
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, warningDark],
  );

  /// 에러 그라데이션
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, errorDark],
  );

  /// 정보 그라데이션
  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [info, infoDark],
  );

  /// 비활성 그라데이션 (라이트 테마용)
  static const LinearGradient disabledGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE5E7EB), // 밝은 회색
      Color(0xFFD1D5DB), // 중간 회색
      Color(0xFFA1A5AB), // 어두운 회색
    ],
  );

  /// 비활성 그라데이션 (다크 테마용)
  static const LinearGradient disabledGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4B5563), // 밝은 다크 회색
      Color(0xFF374151), // 중간 다크 회색
      Color(0xFF1F2937), // 어두운 다크 회색
    ],
  );

  /// 부드러운 비활성 그라데이션 (더 연한 버전)
  static const LinearGradient softDisabledGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF9FAFB), // 매우 밝은 회색
      Color(0xFFF3F4F6), // 밝은 회색
      Color(0xFFE5E7EB), // 중간 회색
    ],
  );

  /// 부드러운 비활성 그라데이션 다크 버전
  static const LinearGradient softDisabledGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF374151), // 밝은 다크 회색
      Color(0xFF1F2937), // 중간 다크 회색
      Color(0xFF111827), // 어두운 다크 회색
    ],
  );

  // ==================== Flutter 테마 데이터 (성능 개선) ====================

  // 테마 캐싱을 위한 정적 변수들
  static ThemeData? _cachedLightTheme;
  static ThemeData? _cachedDarkTheme;

  /// 라이트 테마 데이터 생성 (캐싱 적용)
  static ThemeData getLightTheme() {
    return _cachedLightTheme ??= _createLightTheme();
  }

  /// 다크 테마 데이터 생성 (캐싱 적용)
  static ThemeData getDarkTheme() {
    return _cachedDarkTheme ??= _createDarkTheme();
  }

  /// 라이트 테마 생성 (내부 함수)
  static ThemeData _createLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 컬러 스킴
      colorScheme: ColorScheme.light(
        primary: brandPrimary,
        secondary: brandSecondary,
        surface: light.surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: light.textPrimary,
        onSurface: light.textPrimary,
        onError: Colors.white,
      ),

      // 기본 배경색
      scaffoldBackgroundColor: light.background,

      // 폰트 패밀리
      fontFamily: 'pre',

      // 텍스트 테마
      textTheme: _buildTextTheme(light),

      // 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: light.surface,
        elevation: 0,
        titleTextStyle: heading3(color: light.textPrimary),
        iconTheme: IconThemeData(color: light.textPrimary),
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        color: light.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          textStyle: buttonText(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  /// 다크 테마 생성 (내부 함수)
  static ThemeData _createDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 컬러 스킴
      colorScheme: ColorScheme.dark(
        primary: brandSecondary,
        secondary: brandPrimary,
        surface: dark.surface,
        error: errorDark,
        onPrimary: dark.textPrimary,
        onSecondary: dark.textPrimary,
        onSurface: dark.textPrimary,
        onError: Colors.white,
      ),

      // 기본 배경색
      scaffoldBackgroundColor: dark.background,

      // 폰트 패밀리
      fontFamily: 'pre',

      // 텍스트 테마
      textTheme: _buildTextTheme(dark),

      // 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: dark.surface,
        elevation: 0,
        titleTextStyle: heading3(color: dark.textPrimary),
        iconTheme: IconThemeData(color: dark.textPrimary),
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        color: dark.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          textStyle: buttonText(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  /// 텍스트 테마 생성 (기존과 동일)
  static TextTheme _buildTextTheme(dynamic colorScheme) {
    return TextTheme(
      displayLarge: heading1(color: colorScheme.textPrimary),
      displayMedium: heading2(color: colorScheme.textPrimary),
      displaySmall: heading3(color: colorScheme.textPrimary),
      headlineLarge: heading1(color: colorScheme.textPrimary),
      headlineMedium: heading2(color: colorScheme.textPrimary),
      headlineSmall: heading3(color: colorScheme.textPrimary),
      titleLarge: heading3(color: colorScheme.textPrimary),
      titleMedium: bodyLarge(color: colorScheme.textPrimary),
      titleSmall: bodyMedium(color: colorScheme.textPrimary),
      bodyLarge: bodyLarge(color: colorScheme.textPrimary),
      bodyMedium: bodyMedium(color: colorScheme.textPrimary),
      bodySmall: bodySmall(color: colorScheme.textSecondary),
      labelLarge: buttonText(color: colorScheme.textPrimary),
      labelMedium: bodyMedium(color: colorScheme.textPrimary),
      labelSmall: caption(color: colorScheme.textSecondary),
    );
  }

  /// 테마 캐시 초기화 (메모리 정리용)
  static void clearCache() {
    _cachedLightTheme = null;
    _cachedDarkTheme = null;
  }
}

// ==================== 라이트 테마 컬러 정의 (기존 구조 유지) ====================
/// 라이트 테마에서 사용되는 컬러들
class _LightTheme {
  const _LightTheme();

  // 배경 관련
  Color get background => const Color(0xFFF8FAFE);
  Color get surface => const Color(0xFFFFFFFF);
  Color get cardBackground => const Color(0xFFFFFFFF);

  // 기본 브랜드 색상 (추가)
  Color get primary => DaylitColors.brandPrimary;
  Color get secondary => DaylitColors.brandSecondary;
  Color get accent => DaylitColors.brandAccent;

  // 텍스트 관련
  Color get textPrimary => const Color(0xFF1F2937);
  Color get textSecondary => const Color(0xFF6B7280);
  Color get textHint => const Color(0xFF9CA3AF);

  // UI 요소
  Color get divider => const Color(0xFFE5E7EB);
  Color get border => const Color(0xFFD1D5DB);
  Color get shadow => DaylitColors.brandPrimary.withOpacity(0.1);
  Color get overlay => const Color(0xFF000000).withOpacity(0.5);
  Color get disabled => const Color(0xFF9CA3AF);

  // 그라데이션
  LinearGradient get primaryGradient => DaylitColors.brandGradient;
  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, const Color(0xFFF1F5F9)],
  );
}

// ==================== 다크 테마 컬러 정의 (기존 구조 유지) ====================
/// 다크 테마에서 사용되는 컬러들
class _DarkTheme {
  const _DarkTheme();

  // 배경 관련
  Color get background => const Color(0xFF0F172A);
  Color get surface => const Color(0xFF1E293B);
  Color get cardBackground => const Color(0xFF1E293B);

  // 기본 브랜드 색상 (다크 테마에서는 조금 더 밝게)
  Color get primary => DaylitColors.brandSecondary; // 다크에서는 더 밝은 색상
  Color get secondary => DaylitColors.brandPrimary;
  Color get accent => DaylitColors.brandAccent;

  // 텍스트 관련
  Color get textPrimary => const Color(0xFFE2E8F0);
  Color get textSecondary => const Color(0xFF94A3B8);
  Color get textHint => const Color(0xFF64748B);

  // UI 요소
  Color get divider => const Color(0xFF334155);
  Color get border => const Color(0xFF475569);
  Color get shadow => const Color(0xFF000000).withOpacity(0.3);
  Color get overlay => const Color(0xFF000000).withOpacity(0.7);
  Color get disabled => const Color(0xFF64748B);

  // 그라데이션
  LinearGradient get primaryGradient => DaylitColors.brandGradient;
  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, const Color(0xFF1E293B)],
  );
}

// ==================== 편의 Extension (기존과 동일) ====================
/// BuildContext를 통한 간편한 컬러 접근
extension DaylitColorsExtension on BuildContext {
  /// 현재 테마의 컬러 스킴 반환
  dynamic get colors => DaylitColors.of(this);

  /// 다크 테마 여부 확인
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;

  /// 브랜드 컬러들 빠른 접근
  Color get brandPrimary => DaylitColors.brandPrimary;
  Color get brandSecondary => DaylitColors.brandSecondary;
  Color get brandAccent => DaylitColors.brandAccent;

  /// 상태 컬러들 빠른 접근 (컨텍스트 고려)
  Color get successColor => DaylitColors.getStatusColor('success', context: this);
  Color get warningColor => DaylitColors.getStatusColor('warning', context: this);
  Color get errorColor => DaylitColors.getStatusColor('error', context: this);
  Color get infoColor => DaylitColors.getStatusColor('info', context: this);

  /// 그라데이션들 빠른 접근
  LinearGradient get brandGradient => DaylitColors.brandGradient;
  LinearGradient get successGradient => DaylitColors.successGradient;
  LinearGradient get warningGradient => DaylitColors.warningGradient;
  LinearGradient get errorGradient => DaylitColors.errorGradient;
  LinearGradient get infoGradient => DaylitColors.infoGradient;

  /// 현재 테마에 맞는 비활성 그라데이션 반환
  LinearGradient get disabledGradient => DaylitColors.getDisabledGradient(this);

  /// 현재 테마에 맞는 부드러운 비활성 그라데이션 반환
  LinearGradient get softDisabledGradient => DaylitColors.getDisabledGradient(this, soft: true);
}

// ==================== 컬러 유틸리티 (기존과 동일하되 개선) ====================
/// 컬러 관련 유틸리티 함수들
class ColorUtils {
  ColorUtils._();

  /// 컬러를 Hex 문자열로 변환
  ///
  /// @param color 변환할 컬러
  /// @returns Hex 문자열 (#RRGGBB 형식)
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Hex 문자열을 컬러로 변환 (에러 처리 강화)
  ///
  /// @param hexString Hex 문자열
  /// @returns Color 객체
  /// @throws ArgumentError 잘못된 형식인 경우
  static Color fromHex(String hexString) {
    String hex = hexString.replaceFirst('#', '');

    if (hex.length == 6) {
      hex = 'ff$hex'; // 알파 채널 추가
    }

    if (hex.length != 8) {
      throw ArgumentError('잘못된 Hex 색상 형식: $hexString (올바른 형식: #RRGGBB 또는 RRGGBB)');
    }

    final intValue = int.tryParse(hex, radix: 16);
    if (intValue == null) {
      throw ArgumentError('유효하지 않은 Hex 값: $hexString');
    }

    return Color(intValue);
  }

  /// 컬러 밝기 계산
  ///
  /// @param color 계산할 컬러
  /// @returns 밝기 값 (0.0 ~ 1.0)
  static double getLuminance(Color color) {
    return color.computeLuminance();
  }

  /// 컬러가 밝은지 어두운지 판단
  ///
  /// @param color 판단할 컬러
  /// @returns true: 밝음, false: 어두움
  static bool isLightColor(Color color) {
    return getLuminance(color) > 0.5;
  }

  /// 컬러에 대한 적절한 텍스트 컬러 반환
  ///
  /// @param backgroundColor 배경 컬러
  /// @returns 텍스트 컬러 (검은색 또는 흰색)
  static Color getTextColorForBackground(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black87 : Colors.white;
  }

  /// 컬러 투명도 안전하게 적용
  ///
  /// @param color 원본 컬러
  /// @param opacity 투명도 (0.0 ~ 1.0)
  /// @returns 투명도가 적용된 컬러
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }
}
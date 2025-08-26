import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../util/Daylit_Colors.dart';

/// 향상된 에러 스낵바 유틸리티 클래스
/// 
/// DayLit 앱의 디자인 시스템에 맞춰 제작된 현대적이고 직관적인 에러 스낵바를 제공합니다.
/// 다양한 상태별 알림과 커스터마이징 옵션을 지원합니다.
class EnhancedErrorSnackBar {
  EnhancedErrorSnackBar._();

  /// 에러 스낵바 표시
  /// 
  /// [context] - 빌드 컨텍스트
  /// [message] - 에러 메시지
  /// [duration] - 표시 시간 (기본: 4초)
  /// [includeHaptic] - 햅틱 피드백 포함 여부 (기본: true)
  /// [showIcon] - 아이콘 표시 여부 (기본: true)
  /// [useGradient] - 그라데이션 배경 사용 여부 (기본: false)
  static void showError(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 4),
        bool includeHaptic = true,
        bool showIcon = true,
        bool useGradient = false,
      }) {
    _showCustomSnackBar(
      context,
      message: message,
      type: _SnackBarType.error,
      duration: duration,
      includeHaptic: includeHaptic,
      showIcon: showIcon,
      useGradient: useGradient,
    );
  }

  /// 성공 스낵바 표시
  static void showSuccess(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
        bool includeHaptic = true,
        bool showIcon = true,
        bool useGradient = false,
      }) {
    _showCustomSnackBar(
      context,
      message: message,
      type: _SnackBarType.success,
      duration: duration,
      includeHaptic: includeHaptic,
      showIcon: showIcon,
      useGradient: useGradient,
    );
  }

  /// 경고 스낵바 표시
  static void showWarning(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
        bool includeHaptic = true,
        bool showIcon = true,
        bool useGradient = false,
      }) {
    _showCustomSnackBar(
      context,
      message: message,
      type: _SnackBarType.warning,
      duration: duration,
      includeHaptic: includeHaptic,
      showIcon: showIcon,
      useGradient: useGradient,
    );
  }

  /// 정보 스낵바 표시
  static void showInfo(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
        bool includeHaptic = false,
        bool showIcon = true,
        bool useGradient = false,
      }) {
    _showCustomSnackBar(
      context,
      message: message,
      type: _SnackBarType.info,
      duration: duration,
      includeHaptic: includeHaptic,
      showIcon: showIcon,
      useGradient: useGradient,
    );
  }

  /// 커스텀 스낵바 내부 구현
  static void _showCustomSnackBar(
      BuildContext context, {
        required String message,
        required _SnackBarType type,
        required Duration duration,
        required bool includeHaptic,
        required bool showIcon,
        required bool useGradient,
      }) {
    // 기존 스낵바 제거
    ScaffoldMessenger.of(context).clearSnackBars();

    // 햅틱 피드백
    if (includeHaptic) {
      _triggerHapticFeedback(type);
    }

    // 현재 테마 색상 가져오기
    final colors = DaylitColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 타입별 설정 가져오기
    final config = _getTypeConfig(type, isDark);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _buildSnackBarContent(
          message: message,
          config: config,
          colors: colors,
          showIcon: showIcon,
        ),
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.zero,
        // 슬라이드 애니메이션을 위한 dismissDirection
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  /// 스낵바 콘텐츠 빌드
  static Widget _buildSnackBarContent({
    required String message,
    required _TypeConfig config,
    required dynamic colors,
    required bool showIcon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        gradient: config.useGradient ? config.gradient : null,
        color: config.useGradient ? null : config.backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: config.borderColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: config.shadowColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: Offset(0, 8.h),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: config.shadowColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          if (showIcon) ...[
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: config.iconBackgroundColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                config.icon,
                size: 18.r,
                color: config.iconColor,
              ),
            ),
            SizedBox(width: 12.w),
          ],

          // 메시지
          Expanded(
            child: Text(
              message,
              style: DaylitColors.bodyMedium(color: config.textColor).copyWith(
                fontFamily: 'pre',
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                height: 1.4,
                letterSpacing: -0.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 닫기 버튼 (옵션)
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
                  .hideCurrentSnackBar();
            },
            child: Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: config.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                LucideIcons.x,
                size: 14.r,
                color: config.textColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 햅틱 피드백 트리거
  static void _triggerHapticFeedback(_SnackBarType type) {
    switch (type) {
      case _SnackBarType.error:
        HapticFeedback.heavyImpact();
        break;
      case _SnackBarType.warning:
        HapticFeedback.mediumImpact();
        break;
      case _SnackBarType.success:
        HapticFeedback.lightImpact();
        break;
      case _SnackBarType.info:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// 타입별 설정 반환
  static _TypeConfig _getTypeConfig(_SnackBarType type, bool isDark) {
    switch (type) {
      case _SnackBarType.error:
        return _TypeConfig(
          backgroundColor: isDark ? DaylitColors.errorDark.withValues(alpha: 0.95) : DaylitColors.error.withValues(alpha: 0.95),
          borderColor: isDark ? DaylitColors.errorDark : DaylitColors.error,
          textColor: Colors.white,
          icon: LucideIcons.circleAlert,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          shadowColor: DaylitColors.error,
          gradient: DaylitColors.errorGradient,
          useGradient: false,
        );

      case _SnackBarType.success:
        return _TypeConfig(
          backgroundColor: isDark ? DaylitColors.successDark.withValues(alpha: 0.95) : DaylitColors.success.withValues(alpha: 0.95),
          borderColor: isDark ? DaylitColors.successDark : DaylitColors.success,
          textColor: Colors.white,
          icon: LucideIcons.circleCheck,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          shadowColor: DaylitColors.success,
          gradient: DaylitColors.successGradient,
          useGradient: false,
        );

      case _SnackBarType.warning:
        return _TypeConfig(
          backgroundColor: isDark ? DaylitColors.warningDark.withValues(alpha: 0.95) : DaylitColors.warning.withValues(alpha: 0.95),
          borderColor: isDark ? DaylitColors.warningDark : DaylitColors.warning,
          textColor: Colors.white,
          icon: LucideIcons.triangleAlert,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          shadowColor: DaylitColors.warning,
          gradient: DaylitColors.warningGradient,
          useGradient: false,
        );

      case _SnackBarType.info:
        return _TypeConfig(
          backgroundColor: isDark ? DaylitColors.infoDark.withValues(alpha: 0.95) : DaylitColors.info.withValues(alpha: 0.95),
          borderColor: isDark ? DaylitColors.infoDark : DaylitColors.info,
          textColor: Colors.white,
          icon: LucideIcons.info,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          shadowColor: DaylitColors.info,
          gradient: DaylitColors.infoGradient,
          useGradient: false,
        );
    }
  }
}

/// 스낵바 타입 열거형
enum _SnackBarType {
  error,
  success,
  warning,
  info,
}

/// 타입별 설정 클래스
class _TypeConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color shadowColor;
  final LinearGradient gradient;
  final bool useGradient;

  const _TypeConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.shadowColor,
    required this.gradient,
    required this.useGradient,
  });
}

/// 네비게이션 서비스 (스낵바 닫기용)
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
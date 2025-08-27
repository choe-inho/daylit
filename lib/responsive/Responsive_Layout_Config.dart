import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;

import '../util/Daylit_Device.dart';
import '../util/Daylit_Colors.dart';

/// 페이지 레이아웃 타입
enum PageLayoutType {
  /// 로그인/회원가입 페이지
  auth,

  /// 홈/메인 페이지
  home,

  /// 리스트 페이지 (퀘스트, 루틴 목록 등)
  list,

  /// 퀘스트 만들기
  quest,

  /// 퀘스트 결과
  result,

  ///지갑
  wallet,

  /// 상세 페이지 (루틴 상세, 프로필 등)
  detail,

  /// 설정 페이지
  settings,

  /// 온보딩 페이지
  onboarding,

  /// 커스텀 페이지
  custom,
}

/// 레이아웃 스타일
enum LayoutStyle {
  /// 모바일 레이아웃만 사용
  mobileOnly,

  /// 센터 카드 형태 (태블릿)
  centerCard,

  /// 분할 화면 (태블릿)
  splitScreen,

  /// 전체 화면 (태블릿)
  fullScreen,
}

/// 반응형 레이아웃 설정 클래스
///
/// 각 페이지 타입별로 최적화된 레이아웃 설정을 제공합니다.
/// 커스터마이징이 필요한 경우 copyWith()를 사용하여 일부 값만 변경할 수 있습니다.
class ResponsiveLayoutConfig {
  // ==================== 기본 설정 ====================
  final bool useCard;
  final double cardElevation;
  final double cardBorderRadius;
  final bool useCardGradient;

  // ==================== 분할 화면 설정 ====================
  final int splitScreenLeftFlex;
  final int splitScreenRightFlex;
  final bool useSplitScreenShadow;

  // ==================== 브랜딩 설정 ====================
  final bool showLeftBranding;
  final bool showBrandingPattern;
  final IconData? brandingIcon;
  final double brandingIconSize;
  final Color brandingIconColor;
  final String? brandingTitle;
  final double brandingTitleSize;
  final String? brandingSubtitle;
  final double brandingSubtitleSize;
  final Color brandingTextColor;
  final Color brandingPatternColor;
  final double brandingPatternOpacity;

  const ResponsiveLayoutConfig({
    // 기본 설정
    this.useCard = true,
    this.cardElevation = 8,
    this.cardBorderRadius = 24,
    this.useCardGradient = true,

    // 분할 화면 설정
    this.splitScreenLeftFlex = 5,
    this.splitScreenRightFlex = 4,
    this.useSplitScreenShadow = true,

    // 브랜딩 설정
    this.showLeftBranding = true,
    this.showBrandingPattern = true,
    this.brandingIcon = Icons.wb_sunny_rounded,
    this.brandingIconSize = 64,
    this.brandingIconColor = Colors.white,
    this.brandingTitle,
    this.brandingTitleSize = 36,
    this.brandingSubtitle,
    this.brandingSubtitleSize = 18,
    this.brandingTextColor = Colors.white,
    this.brandingPatternColor = Colors.white,
    this.brandingPatternOpacity = 0.1,
  });

  /// 페이지 타입별 기본 설정 반환
  factory ResponsiveLayoutConfig.forPageType(PageLayoutType pageType) {
    switch (pageType) {
      case PageLayoutType.auth:
        return const ResponsiveLayoutConfig(
          brandingTitle: 'DayLit과 함께\n더 나은 하루를\n만들어보세요',
          brandingSubtitle: 'AI가 도와주는 개인 맞춤 루틴으로\n매일을 더욱 의미있게 만들어보세요.',
        );

      case PageLayoutType.home:
        return const ResponsiveLayoutConfig(
          useCard: false,
          showLeftBranding: false,
          splitScreenLeftFlex: 3,
          splitScreenRightFlex: 7,
        );

      case PageLayoutType.list:
        return const ResponsiveLayoutConfig(
          useCard: false,
          showLeftBranding: false,
          splitScreenLeftFlex: 2,
          splitScreenRightFlex: 8,
        );

      case PageLayoutType.detail:
        return const ResponsiveLayoutConfig(
          cardBorderRadius: 16,
          brandingTitle: '자세한 정보',
          brandingSubtitle: '상세 내용을 확인하고\n관리해보세요.',
        );

      case PageLayoutType.settings:
        return const ResponsiveLayoutConfig(
          useCard: false,
          showBrandingPattern: false,
          brandingTitle: '설정',
          brandingSubtitle: '앱을 개인화하고\n환경을 설정해보세요.',
          brandingIcon: Icons.settings_rounded,
        );

      case PageLayoutType.quest:
        return const ResponsiveLayoutConfig(
          useCard: false,
          showBrandingPattern: false,
          brandingTitle: '퀘스트 생성',
          brandingSubtitle: '목표를 설정하고 퀘스트를 생성하세요.',
        );

      case PageLayoutType.wallet:
        return const ResponsiveLayoutConfig(
          useCard: false,
          showBrandingPattern: false,
          brandingTitle: '지갑',
          brandingSubtitle: '릿을 충전하고 더 많은 목표를 달성해보세요',
        );


      case PageLayoutType.result:
        return const ResponsiveLayoutConfig(
          useCard: false,
          showBrandingPattern: false,
          brandingTitle: '퀘스트 완료',
          brandingSubtitle: '어울리는 매일 퀘스트 목록을 만들었어요',
        );

      case PageLayoutType.onboarding:
        return const ResponsiveLayoutConfig(
          useCard: false,
          brandingTitle: 'DayLit에\n오신 것을 환영합니다',
          brandingSubtitle: '더 나은 하루를 위한 여정이\n지금 시작됩니다.',
          brandingIcon: Icons.celebration_rounded,
        );

      case PageLayoutType.custom:
        return const ResponsiveLayoutConfig();
    }
  }

  /// 현재 디바이스에 최적화된 레이아웃 스타일 반환
  LayoutStyle getOptimalLayoutStyle(BuildContext context) {
    final deviceType = DaylitDevice.getDeviceType(context);
    final screenSize = MediaQuery.of(context).size;

    switch (deviceType) {
      case DeviceType.mobile:
        return LayoutStyle.mobileOnly;

      case DeviceType.tablet:
        final aspectRatio = screenSize.width / screenSize.height;

        if (aspectRatio > 1.3 && showLeftBranding) {
          return LayoutStyle.splitScreen;
        } else if (useCard) {
          return LayoutStyle.centerCard;
        } else {
          return LayoutStyle.fullScreen;
        }
    }
  }

  // ==================== 패딩 및 크기 설정 ====================

  EdgeInsets getMobilePadding() => EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h);

  EdgeInsets getTabletPadding() => EdgeInsets.all(48.w);

  EdgeInsets getCardPadding() => EdgeInsets.all(40.w);

  EdgeInsets getSplitScreenRightPadding() => EdgeInsets.symmetric(horizontal: 48.w, vertical: 60.h);

  EdgeInsets getBrandingPadding() => EdgeInsets.all(60.w);

  double getMaxContentWidth(BuildContext context) {
    final deviceType = DaylitDevice.getDeviceType(context);
    return deviceType == DeviceType.tablet ? 480.w : double.infinity;
  }

  double getSplitScreenContentWidth(BuildContext context) => 400.w;

  // ==================== 스타일 설정 ====================

  Color getCardShadowColor() => DaylitColors.brandPrimary.withValues(alpha: 0.1);

  LinearGradient getBrandingGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        DaylitColors.brandPrimary,
        DaylitColors.brandSecondary,
        DaylitColors.brandAccent,
      ],
    );
  }

  /// 설정 복사 (일부 값 변경)
  ResponsiveLayoutConfig copyWith({
    bool? useCard,
    double? cardElevation,
    double? cardBorderRadius,
    bool? useCardGradient,
    int? splitScreenLeftFlex,
    int? splitScreenRightFlex,
    bool? useSplitScreenShadow,
    bool? showLeftBranding,
    bool? showBrandingPattern,
    IconData? brandingIcon,
    double? brandingIconSize,
    Color? brandingIconColor,
    String? brandingTitle,
    double? brandingTitleSize,
    String? brandingSubtitle,
    double? brandingSubtitleSize,
    Color? brandingTextColor,
    Color? brandingPatternColor,
    double? brandingPatternOpacity,
  }) {
    return ResponsiveLayoutConfig(
      useCard: useCard ?? this.useCard,
      cardElevation: cardElevation ?? this.cardElevation,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      useCardGradient: useCardGradient ?? this.useCardGradient,
      splitScreenLeftFlex: splitScreenLeftFlex ?? this.splitScreenLeftFlex,
      splitScreenRightFlex: splitScreenRightFlex ?? this.splitScreenRightFlex,
      useSplitScreenShadow: useSplitScreenShadow ?? this.useSplitScreenShadow,
      showLeftBranding: showLeftBranding ?? this.showLeftBranding,
      showBrandingPattern: showBrandingPattern ?? this.showBrandingPattern,
      brandingIcon: brandingIcon ?? this.brandingIcon,
      brandingIconSize: brandingIconSize ?? this.brandingIconSize,
      brandingIconColor: brandingIconColor ?? this.brandingIconColor,
      brandingTitle: brandingTitle ?? this.brandingTitle,
      brandingTitleSize: brandingTitleSize ?? this.brandingTitleSize,
      brandingSubtitle: brandingSubtitle ?? this.brandingSubtitle,
      brandingSubtitleSize: brandingSubtitleSize ?? this.brandingSubtitleSize,
      brandingTextColor: brandingTextColor ?? this.brandingTextColor,
      brandingPatternColor: brandingPatternColor ?? this.brandingPatternColor,
      brandingPatternOpacity: brandingPatternOpacity ?? this.brandingPatternOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResponsiveLayoutConfig &&
        other.useCard == useCard &&
        other.cardElevation == cardElevation &&
        other.cardBorderRadius == cardBorderRadius &&
        other.showLeftBranding == showLeftBranding &&
        other.brandingTitle == brandingTitle;
  }

  @override
  int get hashCode {
    return Object.hash(
      useCard,
      cardElevation,
      cardBorderRadius,
      showLeftBranding,
      brandingTitle,
    );
  }

  @override
  String toString() {
    return 'ResponsiveLayoutConfig{useCard: $useCard, showLeftBranding: $showLeftBranding, brandingTitle: $brandingTitle}';
  }
}

// ==================== 사용 예시 주석 ====================
/*
ResponsiveLayoutConfig 사용법:

1. 기본 페이지 타입 설정:
final config = ResponsiveLayoutConfig.forPageType(PageLayoutType.auth);

2. 커스텀 설정:
final customConfig = ResponsiveLayoutConfig.forPageType(PageLayoutType.auth).copyWith(
  brandingTitle: '커스텀 타이틀',
  useCard: false,
  brandingIcon: Icons.star,
);

3. 직접 생성:
final config = ResponsiveLayoutConfig(
  useCard: true,
  cardElevation: 12,
  brandingTitle: '직접 설정',
);

4. 설정 값 확인:
final style = config.getOptimalLayoutStyle(context);
final padding = config.getMobilePadding();
final maxWidth = config.getMaxContentWidth(context);
*/
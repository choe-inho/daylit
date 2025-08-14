import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;

import '../util/Daylit_Device.dart';
import '../util/Daylit_Colors.dart';
import 'Responsive_Layout_Config.dart';
import 'Branding_Pattern_Painter.dart';

/// 전체 앱에서 사용할 수 있는 범용 반응형 레이아웃 시스템
///
/// 다양한 페이지 타입과 디바이스에 최적화된 레이아웃을 제공합니다.
///
/// 사용법:
/// ```dart
/// ResponsiveLayout(
///   pageType: PageLayoutType.auth,
///   mobileLayout: MobileContent(),
///   tabletLayout: TabletContent(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.pageType,
    required this.mobileLayout,
    this.tabletLayout,
    this.layoutStyle,
    this.customConfig,
  });

  /// 페이지 타입
  final PageLayoutType pageType;

  /// 모바일용 레이아웃 위젯
  final Widget mobileLayout;

  /// 태블릿용 레이아웃 위젯 (null이면 모바일 레이아웃 사용)
  final Widget? tabletLayout;

  /// 레이아웃 스타일 (null이면 자동 감지)
  final LayoutStyle? layoutStyle;

  /// 커스텀 설정 (기본 설정 오버라이드)
  final ResponsiveLayoutConfig? customConfig;

  @override
  Widget build(BuildContext context) {
    final config = customConfig ?? ResponsiveLayoutConfig.forPageType(pageType);
    final style = layoutStyle ?? config.getOptimalLayoutStyle(context);

    return ResponsiveBuilder(
      mobile: _buildLayout(context, DeviceType.mobile, style, config),
      tablet: _buildLayout(context, DeviceType.tablet, style, config),
    );
  }

  /// 디바이스별 레이아웃 빌드
  Widget _buildLayout(
      BuildContext context,
      DeviceType deviceType,
      LayoutStyle style,
      ResponsiveLayoutConfig config
      ) {
    switch (deviceType) {
      case DeviceType.mobile:
        return _buildMobileLayout(context, config);

      case DeviceType.tablet:
        switch (style) {
          case LayoutStyle.mobileOnly:
            return _buildMobileLayout(context, config);
          case LayoutStyle.centerCard:
            return _buildCenterCardLayout(context, config);
          case LayoutStyle.splitScreen:
            return _buildSplitScreenLayout(context, config);
          case LayoutStyle.fullScreen:
            return _buildFullScreenLayout(context, config);
        }
    }
  }

  /// 모바일 레이아웃
  Widget _buildMobileLayout(BuildContext context, ResponsiveLayoutConfig config) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: config.getMobilePadding(),
      child: mobileLayout,
    );
  }

  /// 센터 카드 레이아웃 (태블릿)
  Widget _buildCenterCardLayout(BuildContext context, ResponsiveLayoutConfig config) {
    final colors = DaylitColors.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: config.getTabletPadding(),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: config.getMaxContentWidth(context),
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: config.useCard ? Card(
            elevation: config.cardElevation,
            shadowColor: config.getCardShadowColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(config.cardBorderRadius),
            ),
            child: Container(
              padding: config.getCardPadding(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(config.cardBorderRadius),
                gradient: config.useCardGradient ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.surface,
                    colors.surface.withValues(alpha: 0.95),
                  ],
                ) : null,
              ),
              child: tabletLayout ?? mobileLayout,
            ),
          ) : tabletLayout ?? mobileLayout,
        ),
      ),
    );
  }

  /// 분할 화면 레이아웃 (태블릿)
  Widget _buildSplitScreenLayout(BuildContext context, ResponsiveLayoutConfig config) {
    final colors = DaylitColors.of(context);

    return Row(
      children: [
        // 좌측 영역
        Expanded(
          flex: config.splitScreenLeftFlex,
          child: _buildLeftSection(context, config, colors),
        ),

        // 우측 영역
        Expanded(
          flex: config.splitScreenRightFlex,
          child: Container(
            height: double.infinity,
            padding: config.getSplitScreenRightPadding(),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: config.useSplitScreenShadow ? [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(-5, 0),
                ),
              ] : null,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: config.getSplitScreenContentWidth(context),
                ),
                child: tabletLayout ?? mobileLayout,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 전체 화면 레이아웃 (태블릿)
  Widget _buildFullScreenLayout(BuildContext context, ResponsiveLayoutConfig config) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: config.getTabletPadding(),
      child: tabletLayout ?? mobileLayout,
    );
  }

  /// 좌측 섹션 (분할 화면용)
  Widget _buildLeftSection(BuildContext context, ResponsiveLayoutConfig config, dynamic colors) {
    if (!config.showLeftBranding) {
      return Container(color: colors.surface);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: config.getBrandingGradient(),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          if (config.showBrandingPattern)
            _buildBackgroundPattern(config),

          // 브랜딩 컨텐츠
          Padding(
            padding: config.getBrandingPadding(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 로고/아이콘
                if (config.brandingIcon != null)
                  Icon(
                    config.brandingIcon,
                    size: config.brandingIconSize,
                    color: config.brandingIconColor,
                  ),

                if (config.brandingIcon != null)
                  SizedBox(height: 32.h),

                // 메인 텍스트
                if (config.brandingTitle != null)
                  Text(
                    config.brandingTitle!,
                    style: TextStyle(
                      fontSize: config.brandingTitleSize,
                      fontWeight: FontWeight.bold,
                      color: config.brandingTextColor,
                      fontFamily: 'pre',
                      height: 1.3,
                    ),
                  ),

                if (config.brandingTitle != null && config.brandingSubtitle != null)
                  SizedBox(height: 24.h),

                // 서브 텍스트
                if (config.brandingSubtitle != null)
                  Text(
                    config.brandingSubtitle!,
                    style: TextStyle(
                      fontSize: config.brandingSubtitleSize,
                      color: config.brandingTextColor.withValues(alpha: 0.9),
                      fontFamily: 'pre',
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 배경 패턴
  Widget _buildBackgroundPattern(ResponsiveLayoutConfig config) {
    return Positioned.fill(
      child: CustomPaint(
        painter: BrandingPatternPainter(
          patternColor: config.brandingPatternColor,
          patternOpacity: config.brandingPatternOpacity,
        ),
      ),
    );
  }
}

// ==================== 사용 예시 주석 ====================
/*
ResponsiveLayout 사용법:

1. 기본 사용법:
ResponsiveLayout(
  pageType: PageLayoutType.auth,
  mobileLayout: MobileLoginContent(),
  tabletLayout: TabletLoginContent(),
)

2. 레이아웃 스타일 지정:
ResponsiveLayout(
  pageType: PageLayoutType.home,
  mobileLayout: HomeContent(),
  layoutStyle: LayoutStyle.fullScreen,
)

3. 커스텀 설정:
ResponsiveLayout(
  pageType: PageLayoutType.custom,
  mobileLayout: Content(),
  customConfig: ResponsiveLayoutConfig.forPageType(PageLayoutType.auth).copyWith(
    brandingTitle: '커스텀 타이틀',
    useCard: false,
  ),
)

4. 각 페이지에서 사용:
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ResponsiveLayout(
      pageType: PageLayoutType.auth,
      mobileLayout: _buildMobileContent(),
      tabletLayout: _buildTabletContent(),
    ),
  );
}

레이아웃 타입별 특징:
- mobileOnly: 모든 디바이스에서 모바일 레이아웃 사용
- centerCard: 태블릿에서 중앙 카드 형태
- splitScreen: 태블릿에서 좌우 분할 (브랜딩 + 컨텐츠)
- fullScreen: 태블릿에서 전체 화면 사용
*/
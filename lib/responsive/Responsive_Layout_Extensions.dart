import 'package:flutter/material.dart';

import 'Responsive_Layout.dart';
import 'Responsive_Layout_Config.dart';

/// ResponsiveLayout의 편의 생성자들을 제공하는 확장 클래스
///
/// 각 페이지 타입별로 최적화된 간편한 생성자를 제공합니다.
/// 매번 pageType을 지정할 필요 없이 직관적으로 사용할 수 있습니다.
extension ResponsiveLayoutExtensions on ResponsiveLayout {
  /// 로그인/회원가입 페이지용 생성자
  ///
  /// 특징:
  /// - 브랜딩 영역 포함
  /// - 카드 레이아웃 지원
  /// - DayLit 소개 메시지
  static ResponsiveLayout auth({
    required Widget mobileLayout,
    Widget? tabletLayout,
    LayoutStyle? layoutStyle,
    ResponsiveLayoutConfig? customConfig,
  }) {
    return ResponsiveLayout(
      pageType: PageLayoutType.auth,
      mobileLayout: mobileLayout,
      tabletLayout: tabletLayout,
      layoutStyle: layoutStyle,
      customConfig: customConfig,
    );
  }

  /// 홈/메인 페이지용 생성자
  ///
  /// 특징:
  /// - 브랜딩 영역 없음
  /// - 전체 화면 활용
  /// - 3:7 비율 분할 (태블릿)
  static ResponsiveLayout home({
    required Widget mobileLayout,
    Widget? tabletLayout,
    LayoutStyle? layoutStyle,
    ResponsiveLayoutConfig? customConfig,
  }) {
    return ResponsiveLayout(
      pageType: PageLayoutType.home,
      mobileLayout: mobileLayout,
      tabletLayout: tabletLayout,
      layoutStyle: layoutStyle,
      customConfig: customConfig,
    );
  }

  /// 리스트 페이지용 생성자 (퀘스트, 루틴 목록 등)
  ///
  /// 특징:
  /// - 브랜딩 영역 없음
  /// - 2:8 비율 분할 (리스트 최적화)
  /// - 사이드바 + 메인 컨텐츠 구조
  static ResponsiveLayout list({
    required Widget mobileLayout,
    Widget? tabletLayout,
    LayoutStyle? layoutStyle,
    ResponsiveLayoutConfig? customConfig,
  }) {
    return ResponsiveLayout(
      pageType: PageLayoutType.list,
      mobileLayout: mobileLayout,
      tabletLayout: tabletLayout,
      layoutStyle: layoutStyle,
      customConfig: customConfig,
    );
  }

  /// 퀴스트 생성 생성자 (퀘스트 생성 페이지)
  ///
  /// 특징:
  /// - 브랜딩 영역 없음
  /// - 2:8 비율 분할 (리스트 최적화)
  /// - 사이드바 + 메인 컨텐츠 구조
  static ResponsiveLayout quest({
    required Widget mobileLayout,
    Widget? tabletLayout,
    LayoutStyle? layoutStyle,
    ResponsiveLayoutConfig? customConfig,
  }) {
    return ResponsiveLayout(
      pageType: PageLayoutType.quest,
      mobileLayout: mobileLayout,
      tabletLayout: tabletLayout,
      layoutStyle: layoutStyle,
      customConfig: customConfig,
    );
  }


  /// 상세 페이지용 생성자 (루틴 상세, 프로필 등)
  ///
  /// 특징:
  /// - 작은 카드 레이아웃
  /// - 상세 정보 브랜딩
  /// - 컴팩트한 디자인
  static ResponsiveLayout detail({
    required Widget mobileLayout,
    Widget? tabletLayout,
    LayoutStyle? layoutStyle,
    ResponsiveLayoutConfig? customConfig,
  }) {
    return ResponsiveLayout(
      pageType: PageLayoutType.detail,
      mobileLayout: mobileLayout,
      tabletLayout: tabletLayout,
      layoutStyle: layoutStyle,
      customConfig: customConfig,
    );
  }

  /// 설정 페이지용 생성자
  ///
  /// 특징:
  /// - 설정 아이콘
  /// - 패턴 없는 깔끔한 디자인
  /// - 설정 관련 메시지
  static ResponsiveLayout settings({
    required Widget mobileLayout,
    Widget? tabletLayout,
    LayoutStyle? layoutStyle,
    ResponsiveLayoutConfig? customConfig,
  }) {
    return ResponsiveLayout(
      pageType: PageLayoutType.settings,
      mobileLayout: mobileLayout,
      tabletLayout: tabletLayout,
      layoutStyle: layoutStyle,
      customConfig: customConfig,
    );
  }

  /// 온보딩 페이지용 생성자
  ///
  /// 특징:
  /// - 환영 메시지
  /// - 축하 아이콘
  /// - 시작하기 분위기
  static ResponsiveLayout onboarding({
    required Widget mobileLayout,
    Widget? tabletLayout,
    LayoutStyle? layoutStyle,
    ResponsiveLayoutConfig? customConfig,
  }) {
    return ResponsiveLayout(
      pageType: PageLayoutType.onboarding,
      mobileLayout: mobileLayout,
      tabletLayout: tabletLayout,
      layoutStyle: layoutStyle,
      customConfig: customConfig,
    );
  }

  /// 커스텀 페이지용 생성자
  ///
  /// 특징:
  /// - 기본 설정 사용
  /// - 모든 옵션 커스터마이징 가능
  static ResponsiveLayout custom({
    required Widget mobileLayout,
    Widget? tabletLayout,
    LayoutStyle? layoutStyle,
    ResponsiveLayoutConfig? customConfig,
  }) {
    return ResponsiveLayout(
      pageType: PageLayoutType.custom,
      mobileLayout: mobileLayout,
      tabletLayout: tabletLayout,
      layoutStyle: layoutStyle,
      customConfig: customConfig,
    );
  }
}

/// ResponsiveLayoutConfig의 편의 생성자들을 제공하는 확장 클래스
extension ResponsiveLayoutConfigExtensions on ResponsiveLayoutConfig {
  /// 카드 없는 전체 화면 설정
  static ResponsiveLayoutConfig noCard() {
    return const ResponsiveLayoutConfig(
      useCard: false,
      showLeftBranding: false,
    );
  }

  /// 브랜딩 없는 깔끔한 설정
  static ResponsiveLayoutConfig minimal() {
    return const ResponsiveLayoutConfig(
      useCard: false,
      showLeftBranding: false,
      showBrandingPattern: false,
    );
  }

  /// 강조된 브랜딩 설정
  static ResponsiveLayoutConfig emphasized({
    String? title,
    String? subtitle,
    IconData? icon,
  }) {
    return ResponsiveLayoutConfig(
      cardElevation: 12,
      brandingTitle: title ?? 'DayLit',
      brandingSubtitle: subtitle ?? '더 나은 하루를 만들어보세요.',
      brandingIcon: icon ?? Icons.wb_sunny_rounded,
      brandingPatternOpacity: 0.15,
    );
  }

  /// 컴팩트한 설정 (작은 카드)
  static ResponsiveLayoutConfig compact() {
    return const ResponsiveLayoutConfig(
      cardBorderRadius: 12,
      cardElevation: 4,
      splitScreenLeftFlex: 3,
      splitScreenRightFlex: 7,
    );
  }
}

/// 빌더 패턴을 위한 ResponsiveLayoutBuilder 클래스
class ResponsiveLayoutBuilder {
  PageLayoutType? _pageType;
  Widget? _mobileLayout;
  Widget? _tabletLayout;
  LayoutStyle? _layoutStyle;
  ResponsiveLayoutConfig? _customConfig;

  /// 페이지 타입 설정
  ResponsiveLayoutBuilder pageType(PageLayoutType type) {
    _pageType = type;
    return this;
  }

  /// 모바일 레이아웃 설정
  ResponsiveLayoutBuilder mobile(Widget layout) {
    _mobileLayout = layout;
    return this;
  }

  /// 태블릿 레이아웃 설정
  ResponsiveLayoutBuilder tablet(Widget layout) {
    _tabletLayout = layout;
    return this;
  }

  /// 레이아웃 스타일 설정
  ResponsiveLayoutBuilder style(LayoutStyle style) {
    _layoutStyle = style;
    return this;
  }

  /// 커스텀 설정
  ResponsiveLayoutBuilder config(ResponsiveLayoutConfig config) {
    _customConfig = config;
    return this;
  }

  /// ResponsiveLayout 빌드
  ResponsiveLayout build() {
    assert(_pageType != null, 'PageLayoutType must be set');
    assert(_mobileLayout != null, 'Mobile layout must be set');

    return ResponsiveLayout(
      pageType: _pageType!,
      mobileLayout: _mobileLayout!,
      tabletLayout: _tabletLayout,
      layoutStyle: _layoutStyle,
      customConfig: _customConfig,
    );
  }
}

/// ResponsiveLayout 빌더 시작점
ResponsiveLayoutBuilder responsiveLayout() => ResponsiveLayoutBuilder();

// ==================== 사용 예시 주석 ====================
/*
ResponsiveLayout 편의 생성자 사용법:

1. 편의 생성자 사용:
// 로그인 페이지
ResponsiveLayout.auth(
  mobileLayout: MobileLoginContent(),
  tabletLayout: TabletLoginContent(),
)

// 홈 페이지
ResponsiveLayout.home(
  mobileLayout: MobileHomeContent(),
)

// 리스트 페이지
ResponsiveLayout.list(
  mobileLayout: MobileQuestList(),
  tabletLayout: TabletQuestList(),
)

// 설정 페이지
ResponsiveLayout.settings(
  mobileLayout: MobileSettings(),
)

2. 빌더 패턴 사용:
responsiveLayout()
  .pageType(PageLayoutType.auth)
  .mobile(MobileContent())
  .tablet(TabletContent())
  .style(LayoutStyle.centerCard)
  .config(ResponsiveLayoutConfig.emphasized())
  .build()

3. 설정 편의 생성자:
ResponsiveLayout.custom(
  mobileLayout: Content(),
  customConfig: ResponsiveLayoutConfigExtensions.minimal(),
)

4. 각 페이지에서 실제 사용:
// login_page.dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ResponsiveLayout.auth(
      mobileLayout: _buildMobileLogin(),
      tabletLayout: _buildTabletLogin(),
    ),
  );
}

// home_page.dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ResponsiveLayout.home(
      mobileLayout: _buildMobileHome(),
    ),
  );
}

// quest_page.dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ResponsiveLayout.list(
      mobileLayout: _buildMobileQuestList(),
      tabletLayout: _buildTabletQuestList(),
    ),
  );
}

// profile_page.dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ResponsiveLayout.detail(
      mobileLayout: _buildMobileProfile(),
    ),
  );
}

장점:
- 타입 안정성: pageType을 실수로 빼먹을 일 없음
- 직관적 사용법: 페이지 목적이 명확함
- 자동 최적화: 페이지별 최적 설정 자동 적용
- 확장성: 새로운 편의 생성자 쉽게 추가 가능
*/
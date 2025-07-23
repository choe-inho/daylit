import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/auth/Login_Page.dart';
import '../pages/home/Home_Page.dart';
import '../pages/profile/Profile_Page.dart';
import '../pages/quest/Quest_Page.dart';
import '../pages/single/Error_Page.dart';
import '../pages/single/Loading_Page.dart';


class AppRoutes {
  static const loading = '/';
  static const login = '/login';
  static const home = '/home';
  static const quest = '/quest';
  static const profile = '/profile';
}

/// 앱의 전체 라우팅 설정을 관리하는 GoRouter 인스턴스
///
/// 모든 페이지 라우트와 네비게이션 로직을 정의합니다.
/// RouterProvider와 함께 사용하여 상태 관리와 라우팅을 연동합니다.

final GoRouter router = GoRouter(
  // ==================== 기본 설정 ====================

  /// 초기 라우트 (앱 시작 시 표시될 페이지)
  initialLocation: AppRoutes.loading,

  /// 디버그 로그 활성화 (개발 모드에서만)
  debugLogDiagnostics: true,

  /// 에러 페이지 빌더
  errorBuilder: (context, state) => ErrorPage(error: state.error),

  // ==================== 라우트 정의 ====================

  routes: [
    // 로딩 페이지 (스플래시)
    GoRoute(
      path: AppRoutes.loading,
      name: 'loading',
      builder: (context, state) => const LoadingPage(),
    ),

    // 로그인 페이지
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),

    // 홈 페이지 (메인)
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

    // 퀘스트 페이지
    GoRoute(
      path: AppRoutes.quest,
      name: 'quest',
      builder: (context, state) => const QuestPage(),
    ),

    // 프로필 페이지
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],

  // ==================== 네비게이션 가드 ====================

  /// 라우트 변경 전 호출되는 리다이렉트 함수
  redirect: (context, state) {
    final currentPath = state.matchedLocation;

    // 로그인 상태 확인 등의 로직을 여기에 추가
    // 예: 비로그인 상태에서 보호된 페이지 접근 시 로그인 페이지로 리다이렉트

    _logNavigation('Navigating to: $currentPath');

    // null 반환 시 정상 진행
    return null;
  },
);

// ==================== 헬퍼 함수들 ====================
/// 네비게이션 로깅
void _logNavigation(String message) {
  debugPrint('🧭 [AppRouter] $message');
}

// ==================== 라우터 확장 기능들 ====================

/// GoRouter 확장 메서드들
extension AppRouterExtension on GoRouter {
  /// 현재 라우트 경로 반환
  String get currentPath {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : RouteMatchList(matches: [lastMatch], uri: Uri.parse(''), pathParameters: {});
    return matchList.uri.path;
  }

  /// 특정 라우트가 현재 활성화되어 있는지 확인
  bool isCurrentRoute(String path) {
    return currentPath == path;
  }
}

// ==================== 사용 예시 ====================
/*
// main.dart에서 사용
MaterialApp.router(
  routerConfig: router,
  // 다른 설정들...
);

// 페이지에서 네비게이션 사용
context.go(AppRoutes.home);           // 직접 이동
context.push(AppRoutes.profile);      // 스택에 추가
context.pop();                        // 뒤로가기
context.replace(AppRoutes.login);     // 현재 페이지 교체

// Named 라우트 사용
context.goNamed('home');
context.pushNamed('profile');

// 파라미터와 함께 사용
context.go('/profile', extra: {'userId': 123});
*/
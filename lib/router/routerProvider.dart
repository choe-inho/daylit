import 'package:daylit/screen/friend/friends.dart';
import 'package:daylit/screen/home/home.dart';
import 'package:daylit/screen/login/login.dart';
import 'package:daylit/screen/mission/mission.dart';
import 'package:daylit/screen/profile/profile.dart';
import 'package:daylit/screen/routine/routine.dart';
import 'package:daylit/screen/search/search.dart';
import 'package:daylit/util/daylitInitialize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controller/auth/authProvider.dart';
import '../screen/flexable/mainScaffold.dart';

// ==================== 라우트 경로들 ====================
class AppRoutes {
  static const loading = '/';
  static const login = '/login';
  static const mission = '/mission';
  static const home = '/home';
  static const routine = '/routine';
  static const profile = '/profile';
}

// ==================== 네비게이션 상태 모델 ====================
class NavigationState {
  final List<String> historyStack;
  final DateTime? lastBackPress;
  final int maxHistorySize;

  const NavigationState({
    this.historyStack = const [],
    this.lastBackPress,
    this.maxHistorySize = 10,
  });

  NavigationState copyWith({
    List<String>? historyStack,
    DateTime? lastBackPress,
    int? maxHistorySize,
  }) {
    return NavigationState(
      historyStack: historyStack ?? this.historyStack,
      lastBackPress: lastBackPress,
      maxHistorySize: maxHistorySize ?? this.maxHistorySize,
    );
  }

  bool get canGoBack => historyStack.length > 1;
}

// ==================== 네비게이션 관리자 ====================
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState()) {
    _addToHistory(AppRoutes.login);
  }

  final Duration _backPressTimeout = const Duration(seconds: 2);

  // 히스토리에 경로 추가
  void _addToHistory(String path) {
    // 같은 경로 연속 방문 방지
    if (state.historyStack.isNotEmpty && state.historyStack.last == path) {
      return;
    }

    final newHistory = List<String>.from(state.historyStack)..add(path);

    // 최대 개수 초과 시 가장 오래된 것 제거
    if (newHistory.length > state.maxHistorySize) {
      newHistory.removeAt(0);
    }

    state = state.copyWith(historyStack: newHistory);
    _printHistory(); // 디버그용
  }

  // 커스텀 네비게이션 (히스토리 저장)
  void navigateTo(String path, GoRouter router) {
    if (path == AppRoutes.home) {
      // 홈이라면 한번 클리어
      clearHistory();
    }
    _addToHistory(path);
    router.go(path);
  }

  // 히스토리 기반 뒤로가기 (더블 백 프레스 처리 포함)
  bool goBackInHistory(BuildContext context, GoRouter router) {
    final currentPath = router.state.uri.toString();

    // 인증 페이지에서는 앱 종료 처리
    if (currentPath == AppRoutes.login) {
      return _handleDoubleBackPress(context);
    }

    if (state.canGoBack) {
      // 히스토리가 있으면 이전 페이지로
      final newHistory = List<String>.from(state.historyStack)..removeLast();
      final previousPath = newHistory.last;

      state = state.copyWith(historyStack: newHistory);
      router.go(previousPath);
      _printHistory();
      return true; // 뒤로가기 처리됨
    } else {
      // 히스토리가 없으면 더블 백 프레스 체크
      return _handleDoubleBackPress(context);
    }
  }

  // 더블 백 프레스 처리
  bool _handleDoubleBackPress(BuildContext context) {
    final now = DateTime.now();

    if (state.lastBackPress == null ||
        now.difference(state.lastBackPress!) > _backPressTimeout) {
      // 첫 번째 뒤로가기 또는 시간 초과
      state = state.copyWith(lastBackPress: now);
      _showExitToast(context);
      return false; // 앱 종료 안함
    } else {
      // 두 번째 뒤로가기 (시간 내)
      _exitApp();
      return true; // 앱 종료
    }
  }

  // 종료 안내 토스트
  void _showExitToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('한 번 더 누르면 앱이 종료됩니다'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 앱 종료
  void _exitApp() {
    SystemNavigator.pop();
  }

  // 히스토리 초기화
  void clearHistory() {
    state = state.copyWith(historyStack: []);
  }

  // 디버그용 히스토리 출력
  void _printHistory() {
    print('📱 Navigation History: ${state.historyStack.join(' → ')}');
    print('🔙 Can go back: ${state.canGoBack}');
  }
}

// ==================== Router Provider ====================
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isOnAuthPage = state.uri.toString() == AppRoutes.login;

      // 로그인이 안된 상태에서 인증 페이지가 아닌 곳으로 가려고 하면 로그인 페이지로 리다이렉트
      if (!isLoggedIn && !isOnAuthPage) {
        return AppRoutes.login;
      }

      // 로그인이 된 상태에서 인증 페이지로 가려고 하면 홈으로 리다이렉트
      if (isLoggedIn && isOnAuthPage) {
        return AppRoutes.home;
      }

      return null; // 리다이렉트 없음
    },
    routes: [
      // 로딩 페이지
      GoRoute(
        path: AppRoutes.loading,
        builder: (context, state) => const DaylitInitialize(),
      ),

      // 인증 관련 페이지들
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Login(),
      ),
      /*GoRoute(
        path: AppRoutes.mission,
        builder: (context, state) => const Mission(),
      ),*/

      // 메인 앱 페이지들 (MainScaffold 포함)
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const Home(),
          ),
          GoRoute(
            path: AppRoutes.routine,
            builder: (context, state) => const Routine(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const Profile(),
          ),
        ],
      ),
    ],
  );
});

// ==================== 네비게이션 헬퍼 Provider ====================
final navigationHelperProvider = Provider<NavigationHelper>((ref) {
  final router = ref.read(routerProvider);
  final navigationNotifier = ref.read(navigationProvider.notifier);

  return NavigationHelper(router, navigationNotifier);
});

class NavigationHelper {
  final GoRouter router;
  final NavigationNotifier navigationNotifier;

  NavigationHelper(this.router, this.navigationNotifier);

  // 네비게이션 헬퍼 메서드들
  void goHome() => navigationNotifier.navigateTo(AppRoutes.home, router);
  void goRoutine() => navigationNotifier.navigateTo(AppRoutes.routine, router);
  void goProfile() => navigationNotifier.navigateTo(AppRoutes.profile, router);
  void goLogin() => navigationNotifier.navigateTo(AppRoutes.login, router);
  void goMission() => navigationNotifier.navigateTo(AppRoutes.mission, router);

  // 일반적인 네비게이션
  void navigateTo(String path) => navigationNotifier.navigateTo(path, router);

  // 뒤로가기 처리
  bool handleBackPress(BuildContext context) {
    return navigationNotifier.goBackInHistory(context, router);
  }
}

// ==================== 편의 Extension ====================
extension BuildContextRouter on BuildContext {
  NavigationHelper get routerHelper =>
      ProviderScope.containerOf(this).read(navigationHelperProvider);

  // 뒤로가기 처리
  bool handleBackPress() => routerHelper.handleBackPress(this);
}

// ==================== BackPress Handler Widget ====================
class BackPressHandler extends ConsumerWidget {
  final Widget child;

  const BackPressHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationHelper = ref.read(navigationHelperProvider);

    return PopScope(
      canPop: false, // 기본 뒤로가기 비활성화
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          navigationHelper.handleBackPress(context);
        }
      },
      child: child,
    );
  }
}
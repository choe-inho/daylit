import 'package:daylit/screen/friend/friends.dart';
import 'package:daylit/screen/home/home.dart';
import 'package:daylit/screen/login/login.dart';
import 'package:daylit/screen/profile/profile.dart';
import 'package:daylit/screen/routine/routine.dart';
import 'package:daylit/screen/search/search.dart';
import 'package:daylit/util/daylitInitialize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../screen/flexable/mainScaffold.dart';
import '../screen/register/mission.dart';

// 회원가입 페이지 임포트 (새로 생성해야 함)
// import 'package:daylit/screen/register/register.dart';

// 라우트 경로들
class AppRoutes {
  static const loading = '/';
  static const login = '/login';
  static const mission = '/mission';
  static const home = '/home';
  static const routine = '/routine';
  static const friends = '/friends';
  static const profile = '/profile';
  static const search = '/search';
}

// 라우터 매니저
class RouterManager {
  static final RouterManager _instance = RouterManager._();
  static RouterManager get instance => _instance;
  RouterManager._();

  late final GoRouter router;

  // 히스토리 스택 관리
  final List<String> _historyStack = [];
  final int _maxHistorySize = 10; // 최대 히스토리 개수

  // 더블 백 프레스 관리
  DateTime? _lastBackPress;
  final Duration _backPressTimeout = const Duration(seconds: 2);

  // 로그인 상태 관리 (실제 앱에서는 상태 관리 라이브러리 사용)
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  List<String> get historyStack => List.unmodifiable(_historyStack);
  bool get canGoBack => _historyStack.length > 1;

  void initialize() {
    router = GoRouter(
      initialLocation: AppRoutes.login, // 로그인 페이지로 시작
      redirect: (context, state) {
        final isOnAuthPage = state.uri.toString() == AppRoutes.login;

        // 로그인이 안된 상태에서 인증 페이지가 아닌 곳으로 가려고 하면 로그인 페이지로 리다이렉트
        if (!_isLoggedIn && !isOnAuthPage) {
          return AppRoutes.login;
        }

        // 로그인이 된 상태에서 인증 페이지로 가려고 하면 홈으로 리다이렉트
        if (_isLoggedIn && isOnAuthPage) {
          return AppRoutes.home;
        }

        return null; // 리다이렉트 없음
      },
      routes: [
        // 로딩 페이지 (필요시 사용)
        GoRoute(
          path: AppRoutes.loading,
          builder: (context, state) => const DaylitInitialize(),
        ),

        // 인증 관련 페이지들 (MainScaffold 없이 독립적으로)
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const Login(),
        ),
        // 미션 세팅 페이지
        GoRoute(
          path: AppRoutes.mission,
          builder: (context, state) => const Register(), // 회원가입 페이지
        ),

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
              path: AppRoutes.friends,
              builder: (context, state) => const Friends(),
            ),
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) => const Search(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const Profile(),
            ),
          ],
        ),
      ],
    );

    // 초기 경로 저장
    _addToHistory(AppRoutes.login);
  }

  // 로그인 상태 업데이트
  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    if (value) {
      // 로그인 성공 시 히스토리 클리어하고 홈으로
      _historyStack.clear();
      _addToHistory(AppRoutes.home);
    } else {
      // 로그아웃 시 히스토리 클리어하고 로그인으로
      _historyStack.clear();
      _addToHistory(AppRoutes.login);
    }
  }

  // 로그아웃 처리
  void logout() {
    setLoggedIn(false);
    router.go(AppRoutes.login);
  }

  // 히스토리에 경로 추가
  void _addToHistory(String path) {
    // 같은 경로 연속 방문 방지
    if (_historyStack.isNotEmpty && _historyStack.last == path) {
      return;
    }

    _historyStack.add(path);

    // 최대 개수 초과 시 가장 오래된 것 제거
    if (_historyStack.length > _maxHistorySize) {
      _historyStack.removeAt(0);
    }

    _printHistory(); // 디버그용
  }

  // 커스텀 네비게이션 (히스토리 저장)
  void navigateTo(String path) {
    if(path != '/login'){
      _addToHistory(path);
    }
    router.go(path);
  }

  // 히스토리 기반 뒤로가기 (더블 백 프레스 처리 포함)
  bool goBackInHistory(BuildContext context) {
    final currentPath = router.state.uri.toString();

    // 인증 페이지에서는 앱 종료 처리
    if (currentPath == AppRoutes.login) {
      return _handleDoubleBackPress(context);
    }

    if (canGoBack) {
      // 히스토리가 있으면 이전 페이지로
      _historyStack.removeLast();
      final previousPath = _historyStack.last;
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

    if (_lastBackPress == null || now.difference(_lastBackPress!) > _backPressTimeout) {
      // 첫 번째 뒤로가기 또는 시간 초과
      _lastBackPress = now;
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
    _historyStack.clear();
    _addToHistory(router.state.uri.toString());
  }

  // 네비게이션 헬퍼들 (히스토리 저장)
  void goHome() => navigateTo(AppRoutes.home);
  void goRoutine() => navigateTo(AppRoutes.routine);
  void goFriends() => navigateTo(AppRoutes.friends);
  void goProfile() => navigateTo(AppRoutes.profile);
  void goSearch() => navigateTo(AppRoutes.search);
  void goLogin() => navigateTo(AppRoutes.login);
  void goMission() => navigateTo(AppRoutes.mission);

  // 디버그용 히스토리 출력
  void _printHistory() {
    print('📱 Navigation History: ${_historyStack.join(' → ')}');
    print('🔙 Can go back: $canGoBack');
    print('🔐 Is logged in: $_isLoggedIn');
  }
}

// 간단한 확장
extension BuildContextRouter on BuildContext {
  RouterManager get routerManager => RouterManager.instance;

  // 뒤로가기 처리 (더블 백 프레스 포함)
  bool handleBackPress() {
    return routerManager.goBackInHistory(this);
  }
}

// 백 프레스 처리를 위한 래퍼 위젯
class BackPressHandler extends StatelessWidget {
  final Widget child;

  const BackPressHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 기본 뒤로가기 비활성화
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.handleBackPress();
        }
      },
      child: child,
    );
  }
}

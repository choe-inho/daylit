import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../routes/Navigation_State.dart';
import '../routes/App_Routes.dart';

class RouterProvider extends ChangeNotifier {
  // ==================== 상태 변수들 ====================

  // 뒤로가기 관련
  final Duration _backPressTimeout = const Duration(seconds: 2);
  bool _canExit = false;
  Timer? _exitTimer;

  // 네비게이션 상태
  NavigationState _state = const NavigationState();
  NavigationState get state => _state;

  // 현재 경로
  String _currentPath = AppRoutes.loading;
  String get currentPath => _currentPath;

  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ==================== 네비게이션 메서드들 ====================

  /// 특정 경로로 이동 (GoRouter.go 사용)
  void navigateTo(BuildContext context, String path, {Object? extra}) {
    _setLoading(true);

    try {
      // 실제 GoRouter 네비게이션 수행
      context.go(path, extra: extra);

      // 히스토리 및 상태 업데이트
      _addToHistory(path);
      _currentPath = path;

      _logNavigation('Navigated to: $path');
    } catch (e) {
      _logError('Navigation failed to $path: $e');
    } finally {
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 페이지를 스택에 추가 (GoRouter.push 사용)
  void pushTo(BuildContext context, String path, {Object? extra}) {
    _setLoading(true);

    try {
      // 스택에 페이지 추가
      context.push(path, extra: extra);

      // 히스토리 및 상태 업데이트
      _addToHistory(path);
      _currentPath = path;

      _logNavigation('Pushed to: $path');
    } catch (e) {
      _logError('Push failed to $path: $e');
    } finally {
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 현재 페이지를 교체 (GoRouter.pushReplacement 사용)
  void replaceTo(BuildContext context, String path, {Object? extra}) {
    _setLoading(true);

    try {
      // 현재 페이지 교체
      context.pushReplacement(path, extra: extra);

      // 히스토리에서 현재 페이지 제거 후 새 페이지 추가
      if (_state.historyStack.isNotEmpty) {
        final newHistory = List<String>.from(_state.historyStack);
        newHistory.removeLast(); // 현재 페이지 제거
        newHistory.add(path); // 새 페이지 추가
        _state = _state.copyWith(historyStack: newHistory);
      } else {
        _addToHistory(path);
      }

      _currentPath = path;
      _logNavigation('Replaced to: $path');
    } catch (e) {
      _logError('Replace failed to $path: $e');
    } finally {
      _setLoading(false);
    }

    notifyListeners();
  }

  /// 이전 경로로 이동 (뒤로가기)
  void goBack(BuildContext context) {
    if (_state.canGoBack) {
      try {
        // GoRouter의 뒤로가기 사용
        context.pop();

        // 히스토리 업데이트
        final newHistory = List<String>.from(_state.historyStack);
        newHistory.removeLast(); // 현재 페이지 제거

        if (newHistory.isNotEmpty) {
          _currentPath = newHistory.last;
          _state = _state.copyWith(historyStack: newHistory);
          _logNavigation('Went back to: $_currentPath');
        }
      } catch (e) {
        _logError('Go back failed: $e');
      }

      notifyListeners();
    }
  }

  /// 홈으로 이동 (히스토리 초기화)
  void navigateToHome(BuildContext context) {
    _clearHistory();
    navigateTo(context, AppRoutes.home);
  }

  /// 로그인 페이지로 이동 (히스토리 초기화)
  void navigateToLogin(BuildContext context) {
    _clearHistory();
    navigateTo(context, AppRoutes.login);
  }

  // ==================== Named 라우트 네비게이션 ====================

  /// Named 라우트로 이동
  void navigateToNamed(BuildContext context, String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters, Object? extra}) {
    _setLoading(true);

    try {
      context.goNamed(
        name,
        pathParameters: pathParameters ?? {},
        queryParameters: queryParameters ?? {},
        extra: extra,
      );

      // Named 라우트의 경우 실제 경로를 추적하기 어려우므로 name을 사용
      final routePath = '/named/$name'; // 임시 경로
      _addToHistory(routePath);
      _currentPath = routePath;

      _logNavigation('Navigated to named: $name');
    } catch (e) {
      _logError('Named navigation failed to $name: $e');
    } finally {
      _setLoading(false);
    }

    notifyListeners();
  }

  /// Named 라우트를 스택에 추가
  void pushToNamed(BuildContext context, String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters, Object? extra}) {
    _setLoading(true);

    try {
      context.pushNamed(
        name,
        pathParameters: pathParameters ?? {},
        queryParameters: queryParameters ?? {},
        extra: extra,
      );

      final routePath = '/named/$name';
      _addToHistory(routePath);
      _currentPath = routePath;

      _logNavigation('Pushed to named: $name');
    } catch (e) {
      _logError('Named push failed to $name: $e');
    } finally {
      _setLoading(false);
    }

    notifyListeners();
  }

  // ==================== 뒤로가기 처리 ====================

  /// 시스템 뒤로가기 버튼 처리
  bool handleBackPress(BuildContext context) {
    // 로딩 중이면 뒤로가기 무시
    if (_isLoading) {
      return false;
    }

    // 히스토리가 있으면 이전 페이지로
    if (_state.canGoBack) {
      goBack(context);
      return false; // 시스템 뒤로가기 차단
    }

    // 루트 페이지에서 뒤로가기 시 앱 종료 처리
    return _handleAppExit();
  }

  /// 앱 종료 처리 (더블 탭)
  bool _handleAppExit() {
    if (_canExit && _exitTimer != null) {
      // 두 번째 뒤로가기 - 앱 종료
      _exitApp();
      return true;
    } else {
      // 첫 번째 뒤로가기 - 경고 표시
      _showExitWarning();
      _canExit = true;
      _exitTimer?.cancel();
      _exitTimer = Timer(_backPressTimeout, () {
        _canExit = false;
        _exitTimer = null;
      });
      return false;
    }
  }

  /// 앱 종료 실행
  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  /// 종료 경고 표시
  void _showExitWarning() {
    debugPrint('🚪 [RouterProvider] Press back again to exit');
  }

  // ==================== 히스토리 관리 ====================

  /// 히스토리에 경로 추가
  void _addToHistory(String path) {
    // 같은 경로 연속 방문 방지
    if (_state.historyStack.isNotEmpty && _state.historyStack.last == path) {
      return;
    }

    final newHistory = List<String>.from(_state.historyStack)..add(path);

    // 최대 개수 초과 시 가장 오래된 것 제거
    if (newHistory.length > _state.maxHistorySize) {
      newHistory.removeAt(0);
    }

    _state = _state.copyWith(historyStack: newHistory);
    _printHistory();
  }

  /// 히스토리 초기화
  void _clearHistory() {
    _state = _state.copyWith(historyStack: []);
  }

  /// 히스토리 출력 (디버그용)
  void _printHistory() {
    debugPrint('📍 [RouterProvider] Navigation History: ${_state.historyStack}');
  }

  // ==================== 로딩 상태 관리 ====================

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 로딩 시작
  void startLoading() {
    _setLoading(true);
  }

  /// 로딩 종료
  void stopLoading() {
    _setLoading(false);
  }

  // ==================== 특정 페이지 체크 ====================

  /// 현재 로그인 페이지인지 확인
  bool get isLoginPage => _currentPath == AppRoutes.login;

  /// 현재 홈 페이지인지 확인
  bool get isHomePage => _currentPath == AppRoutes.home;

  /// 현재 로딩 페이지인지 확인
  bool get isLoadingPage => _currentPath == AppRoutes.loading;

  // ==================== 유틸리티 메서드들 ====================

  /// 특정 경로가 히스토리에 있는지 확인
  bool hasInHistory(String path) {
    return _state.historyStack.contains(path);
  }

  /// 히스토리 깊이 반환
  int get historyDepth => _state.historyStack.length;

  /// 이전 경로 반환 (없으면 null)
  String? get previousPath {
    if (_state.historyStack.length >= 2) {
      return _state.historyStack[_state.historyStack.length - 2];
    }
    return null;
  }

  /// 첫 번째 방문 페이지인지 확인
  bool get isFirstPage => _state.historyStack.length <= 1;

  // ==================== 페이지별 네비게이션 헬퍼들 ====================

  /// 퀘스트 페이지로 이동
  void navigateToQuest(BuildContext context) {
    navigateTo(context, AppRoutes.quest);
  }

  /// 프로필 페이지로 이동
  void navigateToProfile(BuildContext context) {
    navigateTo(context, AppRoutes.profile);
  }

  // ==================== 로깅 메서드들 ====================

  /// 네비게이션 로깅
  void _logNavigation(String message) {
    debugPrint('🧭 [RouterProvider] $message');
  }

  /// 에러 로깅
  void _logError(String message) {
    debugPrint('❌ [RouterProvider] $message');
  }

  // ==================== 정리 ====================

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }
}
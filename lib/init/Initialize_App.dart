import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import '../provider/Router_Provider.dart';
import '../provider/User_Provider.dart';
import '../util/Daylit_Device.dart';

/// 앱 초기화를 담당하는 클래스
///
/// 앱 시작 시 필요한 모든 초기화 작업을 수행합니다:
/// - 사용자 데이터 로딩
/// - 디바이스 정보 확인
/// - 로그인 상태 체크
/// - 스플래시 화면 제거
/// - 적절한 페이지로 라우팅
class InitializeApp extends StatefulWidget {
  const InitializeApp({super.key});

  @override
  State<InitializeApp> createState() => _InitializeAppState();
}

class _InitializeAppState extends State<InitializeApp> {
  // ==================== 초기화 상태 관리 ====================
  bool _isInitializing = true;
  String _currentStep = '앱을 시작하는 중...';
  double _progress = 0.0;

  // 초기화 단계들 (getter로 변경)
  List<InitStep> get _initSteps => [
    InitStep('시스템 체크', _checkSystem),
    InitStep('디바이스 정보 확인', _checkDevice),
    InitStep('사용자 데이터 로딩', _loadUserData),
    InitStep('설정 불러오기', _loadSettings),
    InitStep('로그인 상태 확인', _checkLoginStatus),
    InitStep('초기화 완료', _finishInitialization),
  ];

  @override
  void initState() {
    super.initState();
    _logInfo('앱 초기화 시작');

    // 초기화 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialization();
    });
  }

  // ==================== 초기화 프로세스 ====================

  /// 초기화 프로세스 시작
  Future<void> _startInitialization() async {
    try {
      // 각 초기화 단계를 순차적으로 실행
      for (int i = 0; i < _initSteps.length; i++) {
        final step = _initSteps[i];

        setState(() {
          _currentStep = step.name;
          _progress = (i + 1) / _initSteps.length;
        });

        _logInfo('실행 중: ${step.name}');

        // 각 단계 실행
        await step.function();

        // UI 업데이트를 위한 최소 대기 시간
        await Future.delayed(const Duration(milliseconds: 300));
      }

      _logInfo('모든 초기화 완료');

    } catch (e) {
      _logError('초기화 실패: $e');
      await _handleInitializationError(e);
    }
  }

  // ==================== 초기화 단계별 함수들 ====================

  /// 시스템 체크
  static Future<void> _checkSystem() async {
    // 시스템 UI 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 화면 방향 설정 (세로 모드 고정)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 디바이스 정보 확인
  Future<void> _checkDevice() async {
    if (!mounted) return;

    final deviceType = DaylitDevice.getDeviceType(context);
    final designSize = DaylitDevice.getDesignSize(context);

    _logInfo('디바이스 타입: $deviceType');
    _logInfo('디자인 크기: ${designSize.width}x${designSize.height}');

    // 디바이스별 추가 설정이 필요한 경우 여기에 추가
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 사용자 데이터 로딩
  Future<void> _loadUserData() async {
    if (!mounted) return;

    try {
      final userProvider = context.read<UserProvider>();

      // TODO: 실제 사용자 데이터 로딩 로직 구현
      // 예: SharedPreferences, SecureStorage에서 사용자 정보 불러오기
      // final userData = await _loadUserFromStorage();
      // userProvider.setUser(userData);

      _logInfo('사용자 데이터 로딩 완료');
      await Future.delayed(const Duration(milliseconds: 800));

    } catch (e) {
      _logError('사용자 데이터 로딩 실패: $e');
      // 에러가 발생해도 계속 진행 (새 사용자일 수 있음)
    }
  }

  /// 설정 불러오기
  Future<void> _loadSettings() async {
    try {
      // TODO: 앱 설정 불러오기
      // 예: 테마 설정, 알림 설정, 언어 설정 등
      // final settings = await _loadAppSettings();

      _logInfo('설정 불러오기 완료');
      await Future.delayed(const Duration(milliseconds: 500));

    } catch (e) {
      _logError('설정 불러오기 실패: $e');
      // 기본 설정으로 진행
    }
  }

  /// 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    try {
      // TODO: 로그인 상태 확인 로직 구현
      // 예: 토큰 유효성 검사, 자동 로그인 등
      // final isLoggedIn = await _verifyLoginStatus();

      _logInfo('로그인 상태 확인 완료');
      await Future.delayed(const Duration(milliseconds: 500));

    } catch (e) {
      _logError('로그인 상태 확인 실패: $e');
      // 로그인 페이지로 이동하도록 설정
    }
  }

  /// 초기화 완료 및 라우팅
  Future<void> _finishInitialization() async {
    if (!mounted) return;

    try {
      // 스플래시 화면 제거
      FlutterNativeSplash.remove();
      _logInfo('스플래시 화면 제거 완료');

      // 초기화 상태 업데이트
      setState(() {
        _isInitializing = false;
      });

      // 약간의 딜레이 후 적절한 페이지로 이동
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        await _navigateToAppropriateScreen();
      }

    } catch (e) {
      _logError('초기화 완료 처리 실패: $e');
      await _handleInitializationError(e);
    }
  }

  // ==================== 라우팅 로직 ====================

  /// 적절한 화면으로 이동
  Future<void> _navigateToAppropriateScreen() async {
    if (!mounted) return;

    final router = context.read<RouterProvider>();

    try {
      // TODO: 실제 로그인 상태 확인 로직 구현
      final isLoggedIn = await _checkIfUserIsLoggedIn();

      if (isLoggedIn) {
        // 로그인된 사용자 - 홈 페이지로 이동
        _logInfo('로그인된 사용자: 홈 페이지로 이동');
        router.navigateToHome(context);
      } else {
        // 비로그인 사용자 - 로그인 페이지로 이동
        _logInfo('비로그인 사용자: 로그인 페이지로 이동');
        router.navigateToLogin(context);
      }

    } catch (e) {
      _logError('라우팅 실패: $e');
      // 기본적으로 로그인 페이지로 이동
      router.navigateToLogin(context);
    }
  }

  /// 사용자 로그인 상태 확인
  Future<bool> _checkIfUserIsLoggedIn() async {
    try {
      // TODO: 실제 로그인 상태 확인 로직 구현
      // 예시:
      // - SharedPreferences에서 토큰 확인
      // - 토큰 유효성 서버 검증
      // - 사용자 정보 존재 여부 확인

      // 현재는 임시로 false 반환 (로그인 페이지로 이동)
      return false;

    } catch (e) {
      _logError('로그인 상태 확인 중 오류: $e');
      return false;
    }
  }

  // ==================== 에러 처리 ====================

  /// 초기화 에러 처리
  Future<void> _handleInitializationError(dynamic error) async {
    _logError('초기화 에러 처리: $error');

    // 스플래시 화면 제거 (에러 상황에서도)
    FlutterNativeSplash.remove();

    // 에러 상황에서는 기본적으로 로그인 페이지로 이동
    if (mounted) {
      final router = context.read<RouterProvider>();
      router.navigateToLogin(context);
    }
  }

  // ==================== UI 빌드 ====================

  @override
  Widget build(BuildContext context) {
    // 초기화 중에는 투명한 위젯 반환 (스플래시가 보이도록)
    if (_isInitializing) {
      return _buildInitializingWidget();
    }

    // 초기화 완료 후에는 빈 위젯 (라우팅이 곧 일어날 것)
    return const SizedBox.shrink();
  }

  /// 초기화 중 위젯 (스플래시 화면 뒤에 숨겨짐)
  Widget _buildInitializingWidget() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: const SizedBox.shrink(),
      ),
    );
  }

  // ==================== 로깅 메서드들 ====================

  /// 정보 로깅
  void _logInfo(String message) {
    debugPrint('🚀 [InitializeApp] $message');
  }

  /// 에러 로깅
  void _logError(String message) {
    debugPrint('❌ [InitializeApp] $message');
  }
}

// ==================== 초기화 단계 모델 ====================

/// 초기화 단계를 나타내는 클래스
class InitStep {
  final String name;
  final Future<void> Function() function;

  const InitStep(this.name, this.function);
}

// ==================== 사용 예시 주석 ====================
/*
앱 시작 플로우:
1. main() → DayLitDriver → DayLitApp
2. InitializeApp이 첫 번째 라우트로 설정됨
3. InitializeApp에서 모든 초기화 작업 수행
4. 완료 후 로그인 상태에 따라 적절한 페이지로 이동

주요 초기화 작업:
- 시스템 UI 설정
- 디바이스 정보 확인
- 사용자 데이터 로딩
- 앱 설정 불러오기
- 로그인 상태 확인
- 스플래시 화면 제거
- 적절한 페이지로 라우팅

확장 포인트:
- _loadUserData(): 실제 사용자 데이터 로딩 로직 추가
- _loadSettings(): 앱 설정 로딩 로직 추가
- _checkIfUserIsLoggedIn(): 로그인 상태 확인 로직 추가
- _navigateToAppropriateScreen(): 라우팅 로직 커스터마이징
*/
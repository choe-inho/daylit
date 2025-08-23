import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../handler/Dialog_Handler.dart';
import '../handler/dialog/Update_Sheet.dart';
import '../provider/User_Provider.dart';
import '../provider/Router_Provider.dart';
import '../util/Daylit_Device.dart';

class AppState extends ChangeNotifier {
  final darkModeKey = 'daylit.darkmode.key';
  final languageKey = 'daylit.language.key';

  // ==================== 앱 전역 상태 ====================
  bool _isInitialized = false;
  String _colorMode = 'system';
  String _language = 'ko';
  bool _isOffline = false;
  bool _isInitializing = true;
  bool _isDarkMode = false; // 실제 다크 모드 여부
  String _version = '0.0.0';


  // ==================== Getters ====================
  bool get isInitialized => _isInitialized;
  String get colorMode => _colorMode;
  String get language => _language;
  bool get isOffline => _isOffline;
  bool get isInitializing => _isInitializing;
  bool get isDarkMode => _isDarkMode; // 실제 다크 모드 상태
  String get version => _version;

  // ==================== 초기화 상태 관리 ====================
  String _currentStep = '앱을 시작하는 중...';

  String get currentStep => _currentStep;

  /// 앱 초기화 (의존성들을 주입받음)
  Future<void> initializeApp({
    required BuildContext context,
    required UserProvider userProvider,
    required RouterProvider routerProvider,
  }) async {
    try {
      await _startInitialization(
        context: context,
        userProvider: userProvider,
        routerProvider: routerProvider,
      );
    } catch (e) {
      _logError('앱 초기화 실패: $e');
      await _handleInitializationError(routerProvider);
    }
  }

  /// 초기화 프로세스 시작
  Future<void> _startInitialization({
    required BuildContext context,
    required UserProvider userProvider,
    required RouterProvider routerProvider,
  }) async {
    final initSteps = [
      InitStep('앱 색상모드 체크', () => _checkColorMode(context)),
      InitStep('인터넷 연결 확인', () => _checkOnline()),
      InitStep('시스템 UI 설정', () => _setupSystemUI()),
      InitStep('디바이스 정보 확인', () => _checkDevice(context)),
      InitStep('언어 정보 확인', ()=> _checkLanguage()),
      InitStep('버전 정보 확인', () => _checkVersion()),
      InitStep('사용자 데이터 로딩', () => _loadUserData(userProvider)),
      InitStep('로그인 상태 확인', () => _checkLoginStatus()),
      InitStep('초기화 완료', () => _finishInitialization(context, routerProvider)),
    ];

    try {
      for (int i = 0; i < initSteps.length; i++) {
        final step = initSteps[i];
        _currentStep = step.name;
        _logInfo('실행 중: ${step.name}');
        await step.function();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _logInfo('모든 초기화 완료');
    } catch (e) {
      _logError('초기화 실패: $e');
      await _handleInitializationError(routerProvider);
    }
  }

  // AppState.dart에 추가할 함수들

  /// 인터넷 연결 확인
  Future<void> _checkOnline() async {
    try {
      // TODO: 실제 인터넷 연결 확인 로직
      final result = await InternetAddress.lookup('google.com');
      _isOffline = result.isEmpty;

      _isOffline = false; // 임시로 온라인으로 설정
      _logInfo('네트워크 상태: ${_isOffline ? "오프라인" : "온라인"}');

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _isOffline = true;
      _logError('인터넷 연결 확인 실패: $e');
    }
  }

  Future<void> _checkLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(languageKey);

      if (savedLanguage == null) {
        // 새로운 방법: PlatformDispatcher 사용
        final systemLocale = ui.PlatformDispatcher.instance.locale.languageCode;
        _language = _getSupportedLanguage(systemLocale);

        _logInfo('시스템 언어 감지: $systemLocale → $_language');
      } else {
        _language = savedLanguage;
        _logInfo('저장된 언어 설정: $_language');
      }

      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _language = 'ko'; // 기본값으로 설정
      _logError('언어 정보 확인 실패: $e');
    }
  }


  String _getSupportedLanguage(String languageCode) {
    const supportedLanguages = ['ko', 'en'];

    // 지원하는 언어인지 확인
    if (supportedLanguages.contains(languageCode)) {
      return languageCode;
    }

    // 지원하지 않는 언어인 경우 기본값 반환
    // 한국/일본/중국어권은 한국어, 나머지는 영어
    switch (languageCode) {
      case 'ja': // 일본어
      case 'zh': // 중국어
        return 'ko';
      default:
        return 'en';
    }
  }

  /// 언어 변경 (기존 함수 개선)
  Future<void> changeLanguage(String newLanguage) async {
    // 지원하는 언어인지 확인
    final validLanguage = _getSupportedLanguage(newLanguage);
    _language = validLanguage;

    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, validLanguage);

    notifyListeners();
    _logInfo('언어 변경: $validLanguage');
  }

  /// 언어 표시명 반환
  String getLanguageDisplayName(String? languageCode) {
    switch (languageCode ?? _language) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      default:
        return 'English';
    }
  }

  /// 현재 언어 표시명
  String get currentLanguageDisplayName => getLanguageDisplayName(_language);

  /// 버전 정보 확인
  Future<void> _checkVersion() async {
    try {
      // 현재 앱 버전 가져오기
      final packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;

      _logInfo('현재 앱 버전: $_version');

      // TODO: 버전 업데이트 체크
      await _checkForUpdates();

      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      _version = '0.0.0';
      _logError('버전 정보 확인 실패: $e');
    }
  }

  /// 업데이트 체크 (형태만)
  Future<void> _checkForUpdates() async {
    try {
      // TODO: 실제 업데이트 체크 로직 구현
      // 1. 서버 API 호출하여 최신 버전 확인
      // 2. 현재 버전과 비교
      // 3. 업데이트 필요 시 다이얼로그 표시

      // 임시 업데이트 체크 로직
      final needsUpdate = await _simulateUpdateCheck();

      if (needsUpdate) {
        _logInfo('업데이트가 필요합니다');
        // 업데이트 다이얼로그 표시는 초기화 완료 후에 호출
      }
    } catch (e) {
      _logError('업데이트 체크 실패: $e');
    }
  }

  /// 업데이트 체크 시뮬레이션 (임시)
  Future<bool> _simulateUpdateCheck() async {
    // TODO: 실제 서버 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500));
    return false; // 임시로 업데이트 불필요로 설정
  }

  /// 업데이트 다이얼로그 표시 (초기화 완료 후 호출)
  Future<void> showUpdateDialogIfNeeded(BuildContext context) async {
    final needsUpdate = await _simulateUpdateCheck();

    if (needsUpdate && context.mounted) {
      // TODO: 실제 업데이트 정보 가져오기
      final updateInfo = UpdateInfo(
        currentVersion: _version,
        latestVersion: '1.1.0',
        isForceUpdate: false,
        updateMessage: '새로운 기능이 추가되었습니다!',
        changelog: [
          '성능 개선',
          '버그 수정',
          '새로운 UI 추가'
        ],
      );

      await DialogHandler.showUpdateSheet(
        context: context,
        updateInfo: updateInfo,
      );
    }
  }

  /// 컬러 모드 체크 및 실제 다크 모드 여부 판단
  Future<void> _checkColorMode(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(darkModeKey);

    // 저장된 설정이 없으면 시스템 모드로 설정
    _colorMode = savedMode ?? 'system';

    // 실제 다크 모드 여부 판단
    _isDarkMode = _calculateDarkMode(context);

    _logInfo('컬러 모드: $_colorMode, 실제 다크 모드: $_isDarkMode');
  }

  /// 실제 다크 모드 여부 계산
  bool _calculateDarkMode(BuildContext context) {
    switch (_colorMode) {
      case 'dark':
        return true;
      case 'light':
        return false;
      case 'system':
      default:
      // 시스템 설정에 따라 판단
        final platformBrightness = MediaQuery.of(context).platformBrightness;
        return platformBrightness == Brightness.dark;
    }
  }

 // AppState.dart의 _setupSystemUI() 메서드 수정
  Future<void> _setupSystemUI() async {
    // 상태바 설정은 DayLitApp의 AnnotatedRegion에서 처리하므로 제거
    // 화면 방향 설정만 유지
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 기타 시스템 설정들 (필요한 경우)
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge, // 가장자리까지 확장
    );

    _logInfo('시스템 UI 설정 완료: ${_isDarkMode ? "다크 모드" : "라이트 모드"}');
  }

  /// 컬러 모드 변경 (설정에서 호출)
  Future<void> changeColorMode(String newMode, BuildContext context) async {
    _colorMode = newMode;
    _isDarkMode = _calculateDarkMode(context);

    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(darkModeKey, newMode);

    // 시스템 UI 다시 설정
    await _setupSystemUI();

    notifyListeners();
    _logInfo('컬러 모드 변경: $newMode → 실제 다크 모드: $_isDarkMode');
  }

  /// 시스템 다크 모드 변경 감지 (앱이 실행 중일 때)
  void updateSystemBrightness(BuildContext context) {
    if (_colorMode == 'system') {
      final newDarkMode = _calculateDarkMode(context);
      if (_isDarkMode != newDarkMode) {
        _isDarkMode = newDarkMode;
        _setupSystemUI();
        notifyListeners();
        _logInfo('시스템 밝기 변경 감지: $_isDarkMode');
      }
    }
  }

  /// 디바이스 정보 확인
  Future<void> _checkDevice(BuildContext context) async {
    final deviceType = DaylitDevice.getDeviceType(context);
    final designSize = DaylitDevice.getDesignSize(context);

    _logInfo('디바이스 타입: $deviceType');
    _logInfo('디자인 크기: ${designSize.width}x${designSize.height}');

    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 사용자 데이터 로딩
  Future<void> _loadUserData(UserProvider userProvider) async {
    try {
      // userProvider를 직접 사용
      // await userProvider.loadUserFromStorage();

      _logInfo('사용자 데이터 로딩 완료');
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      _logError('사용자 데이터 로딩 실패: $e');
    }
  }


  /// 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    try {
      // TODO: 로그인 상태 확인
      _logInfo('로그인 상태 확인 완료');
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _logError('로그인 상태 확인 실패: $e');
    }
  }

  /// 초기화 완료 및 라우팅
  Future<void> _finishInitialization(
      BuildContext context,
      RouterProvider routerProvider,
      ) async {
    try {
      FlutterNativeSplash.remove();
      _logInfo('스플래시 화면 제거 완료');

      _isInitializing = false;
      _isInitialized = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));
      await _navigateToAppropriateScreen(context, routerProvider);
    } catch (e) {
      _logError('초기화 완료 처리 실패: $e');
      await _handleInitializationError(routerProvider);
    }
  }

  /// 적절한 화면으로 이동
  Future<void> _navigateToAppropriateScreen(
      BuildContext context,
      RouterProvider routerProvider,
      ) async {
    try {
      final isLoggedIn = await _checkIfUserIsLoggedIn();

      if (isLoggedIn) {
        _logInfo('로그인된 사용자: 홈 페이지로 이동');
        routerProvider.navigateToHome(context);
      } else {
        _logInfo('비로그인 사용자: 로그인 페이지로 이동');
        routerProvider.navigateToLogin(context);
      }
    } catch (e) {
      _logError('라우팅 실패: $e');
      routerProvider.navigateToLogin(context);
    }
  }

  /// 사용자 로그인 상태 확인
  Future<bool> _checkIfUserIsLoggedIn() async {
    try {
      // TODO: 실제 로그인 상태 확인 로직
      return false;
    } catch (e) {
      _logError('로그인 상태 확인 중 오류: $e');
      return false;
    }
  }

  /// 초기화 에러 처리
  Future<void> _handleInitializationError(RouterProvider routerProvider) async {
    _logError('초기화 에러 처리');
    FlutterNativeSplash.remove();

    _isInitializing = false;
    notifyListeners();
  }

  /// 정보 로깅
  void _logInfo(String message) {
    debugPrint('🚀 [AppState] $message');
  }

  /// 에러 로깅
  void _logError(String message) {
    debugPrint('❌ [AppState] $message');
  }
}

/// 초기화 단계를 나타내는 클래스
class InitStep {
  final String name;
  final Future<void> Function() function;
  const InitStep(this.name, this.function);
}
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ⭐ Supabase 관련 import 추가
import '../config/Subapase_Config.dart';
import '../main.dart';
import '../service/Supabase_Service.dart';

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
  bool _isDarkMode = false;
  String _version = '0.0.0';

  // ⭐ Supabase 관련 상태 추가
  bool _isSupabaseInitialized = false;
  String? _supabaseError;

  // ==================== Getters ====================
  bool get isInitialized => _isInitialized;
  String get colorMode => _colorMode;
  String get language => _language;
  bool get isOffline => _isOffline;
  bool get isInitializing => _isInitializing;
  bool get isDarkMode => _isDarkMode;
  String get version => _version;

  // ⭐ Supabase 관련 getters 추가
  bool get isSupabaseInitialized => _isSupabaseInitialized;
  String? get supabaseError => _supabaseError;
  bool get isSupabaseConnected => SupabaseService.instance.isConnected;

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
      InitStep('언어 정보 확인', () => _checkLanguage()),
      InitStep('버전 정보 확인', () => _checkVersion()),

      // ⭐ Supabase 초기화 단계 추가
      InitStep('Supabase 연결 확인', () => _initializeSupabase()),

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

  // ==================== ⭐ Supabase 초기화 ====================

  /// Supabase 서비스 초기화
  Future<void> _initializeSupabase() async {
    try {
      _logInfo('Supabase 초기화 시작...');

      // 환경 변수 초기화 확인 (main.dart에서 이미 호출되었지만 재확인)
      if (!SupabaseConfig.isInitialized) {
        _logInfo('환경 변수 재로드 시도...');
        await SupabaseConfig.initialize();
      }

      // 설정 상태 로그 출력
      SupabaseConfig.logConfigStatus();

      if (!SupabaseConfig.isConfigured) {
        throw StateError('Supabase 설정이 완료되지 않았습니다. .env 파일을 확인해주세요.');
      }

      // SupabaseService 초기화
      final success = await SupabaseService.instance.initialize(
        supabaseUrl: SupabaseConfig.supabaseUrl,
        supabaseKey: SupabaseConfig.supabaseAnonKey,
        enableRealtime: true,
        storageRetryAttempts: SupabaseConfig.maxRetryAttempts,
      );

      if (success) {
        _isSupabaseInitialized = true;
        _supabaseError = null;
        _logInfo('✅ Supabase 초기화 성공');

        // 연결 상태 확인
        final isConnected = await SupabaseService.instance.checkConnection();
        _logInfo('🌐 Supabase 연결 상태: ${isConnected ? "연결됨" : "연결 실패"}');

        // 헬스 체크 로그 출력 (디버그 모드에서만)
        if (kDebugMode) {
          SupabaseService.instance.logHealthStatus();
        }

      } else {
        _isSupabaseInitialized = false;
        _supabaseError = SupabaseService.instance.lastError;
        _logError('❌ Supabase 초기화 실패: ${_supabaseError}');

        // 오프라인 모드로 계속 진행할지 결정
        if (SupabaseConfig.enableOfflineMode) {
          _logInfo('⚠️ 오프라인 모드로 계속 진행');
        } else {
          throw StateError('Supabase 연결 실패: ${_supabaseError}');
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

    } catch (error) {
      _isSupabaseInitialized = false;
      _supabaseError = error.toString();
      _logError('❌ Supabase 초기화 중 오류: $error');

      // 오프라인 모드 지원 여부에 따라 처리
      if (!SupabaseConfig.enableOfflineMode) {
        rethrow; // 오프라인 모드가 비활성화되어 있으면 에러 전파
      }
    }
  }

  // ==================== 기존 초기화 메서드들 ====================

  /// 인터넷 연결 확인
  Future<void> _checkOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOffline = result.isEmpty;
      _logInfo('네트워크 상태: ${_isOffline ? "오프라인" : "온라인"}');
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _isOffline = true;
      _logError('인터넷 연결 확인 실패: $e');
    }
  }

  /// 시스템 UI 설정
  Future<void> _setupSystemUI() async {
    try {
      // 상태바 및 네비게이션 바 스타일 설정
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: _isDarkMode ? Brightness.dark : Brightness.light, // iOS용
          systemNavigationBarColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
          systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        ),
      );

      // 화면 방향 설정
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // 가장자리까지 확장 모드 설정
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );

      _logInfo('시스템 UI 설정 완료: ${_isDarkMode ? "다크 모드" : "라이트 모드"}');
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      _logError('시스템 UI 설정 실패: $e');
    }
  }

  /// 디바이스 정보 확인
  Future<void> _checkDevice(BuildContext context) async {
    try {
      final deviceInfo = DaylitDevice.getDeviceType(context);
      _logInfo('디바이스 타입: ${deviceInfo.name}');
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _logError('디바이스 정보 확인 실패: $e');
    }
  }

  /// 언어 정보 확인
  Future<void> _checkLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(languageKey);

      if (savedLanguage == null) {
        final systemLocale = ui.PlatformDispatcher.instance.locale.languageCode;
        _language = _getSupportedLanguage(systemLocale);
        _logInfo('시스템 언어 감지: $systemLocale → $_language');
      } else {
        _language = savedLanguage;
        _logInfo('저장된 언어 설정: $_language');
      }

      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _language = 'ko';
      _logError('언어 정보 확인 실패: $e');
    }
  }

  String _getSupportedLanguage(String languageCode) {
    const supportedLanguages = ['ko', 'en'];

    if (supportedLanguages.contains(languageCode)) {
      return languageCode;
    }

    switch (languageCode) {
      case 'ja':
      case 'zh':
        return 'ko';
      default:
        return 'en';
    }
  }

  /// 버전 정보 확인
  Future<void> _checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
      _logInfo('현재 앱 버전: $_version');

      await _checkForUpdates();
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      _version = '0.0.0';
      _logError('버전 정보 확인 실패: $e');
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      // TODO: 실제 업데이트 체크 로직 구현
      final needsUpdate = await _simulateUpdateCheck();
      if (needsUpdate) {
        _logInfo('업데이트가 필요합니다');
      }
    } catch (e) {
      _logError('업데이트 체크 실패: $e');
    }
  }

  Future<bool> _simulateUpdateCheck() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  /// 컬러 모드 체크
  Future<void> _checkColorMode(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(darkModeKey);

    _colorMode = savedMode ?? 'system';

    // 실제 다크 모드 여부 판단
    if (_colorMode == 'system') {
      final brightness = MediaQuery.of(context).platformBrightness;
      _isDarkMode = brightness == Brightness.dark;
    } else {
      _isDarkMode = _colorMode == 'dark';
    }

    _logInfo('컬러 모드: $_colorMode (실제: ${_isDarkMode ? "다크" : "라이트"})');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 사용자 데이터 로딩
  Future<void> _loadUserData(UserProvider userProvider) async {
    try {
      // ⭐ Supabase 인증 상태 확인 후 사용자 데이터 로딩
      if (_isSupabaseInitialized && SupabaseService.instance.isLoggedIn) {
        // Supabase에서 사용자 정보 로드
        await userProvider.loadUserFromSupabase();
        _logInfo('Supabase에서 사용자 데이터 로딩 완료');
      } else {
        // 로컬 저장소에서 사용자 정보 로드 (오프라인 모드)
        // await userProvider.loadUserFromStorage();
        _logInfo('로컬에서 사용자 데이터 로딩 완료');
      }

      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      _logError('사용자 데이터 로딩 실패: $e');
    }
  }

  /// 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    try {
      if (_isSupabaseInitialized) {
        // Supabase 인증 상태 확인
        final isLoggedIn = SupabaseService.instance.isLoggedIn;
        final userEmail = SupabaseService.instance.userEmail;

        if (isLoggedIn && userEmail != null) {
          _logInfo('로그인된 사용자: $userEmail');
        } else {
          _logInfo('비로그인 상태');
        }
      } else {
        // TODO: 오프라인 모드에서의 로그인 상태 확인
        _logInfo('오프라인 모드: 로컬 로그인 상태 확인');
      }

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
      // ⭐ Supabase 인증 상태 우선 확인
      if (_isSupabaseInitialized) {
        return SupabaseService.instance.isLoggedIn;
      }

      // 오프라인 모드에서는 로컬 확인
      // TODO: 로컬 로그인 상태 확인 로직
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

  // ==================== ⭐ Supabase 관련 헬퍼 메서드 ====================

  /// Supabase 재연결 시도
  Future<bool> reconnectSupabase() async {
    try {
      _logInfo('Supabase 재연결 시도...');

      if (!SupabaseService.instance.isInitialized) {
        // 재초기화
        await _initializeSupabase();
      } else {
        // 연결 상태만 재확인
        await SupabaseService.instance.checkConnection();
      }

      notifyListeners();
      return _isSupabaseInitialized;
    } catch (e) {
      _logError('Supabase 재연결 실패: $e');
      return false;
    }
  }

  /// Supabase 상태 정보 반환
  Map<String, dynamic> getSupabaseStatus() {
    return {
      'initialized': _isSupabaseInitialized,
      'connected': isSupabaseConnected,
      'error': _supabaseError,
      'offlineMode': !_isSupabaseInitialized && SupabaseConfig.enableOfflineMode,
      'healthStatus': _isSupabaseInitialized
          ? SupabaseService.instance.getHealthStatus()
          : null,
    };
  }

  // ==================== 기존 메서드들 ====================

  /// 언어 변경
  Future<void> changeLanguage(String newLanguage) async {
    final validLanguage = _getSupportedLanguage(newLanguage);
    _language = validLanguage;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, validLanguage);

    notifyListeners();
    _logInfo('언어 변경: $validLanguage');
  }

  /// 언어 표시명 반환
  String getLanguageDisplayName(String? languageCode) {
    switch (languageCode ?? _language) {
      case 'ko': return '한국어';
      case 'en': return 'English';
      default: return 'English';
    }
  }

  String get currentLanguageDisplayName => getLanguageDisplayName(_language);

  /// 컬러 모드 변경 (ColorMode_Sheet에서 호출)
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
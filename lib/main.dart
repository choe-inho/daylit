import 'package:daylit/provider/App_State.dart';
import 'package:daylit/provider/Quest_Create_Provider.dart';
import 'package:daylit/provider/Quest_Provider.dart';
import 'package:daylit/provider/Router_Provider.dart';
import 'package:daylit/provider/User_Provider.dart';
import 'package:daylit/provider/Wallet_Provider.dart';
import 'package:daylit/routes/App_Routes.dart';
import 'package:daylit/service/Localization_Service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:daylit/util/Daylit_Device.dart';
import 'package:provider/provider.dart';
import 'config/Subapase_Config.dart';
import 'handler/Backpress_Handler.dart';
import 'l10n/app_localizations.dart';

// ==================== 앱 시작점 ====================
/// 앱의 메인 엔트리포인트
///
/// Flutter 앱이 시작될 때 가장 먼저 호출되는 함수입니다.
/// 앱 초기화 작업과 ProviderScope 설정을 담당합니다.
void main() async {
  // Flutter 엔진 초기화 보장
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 스플래시 화면 유지 (InitializeApp에서 제거할 때까지)
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ⭐ Supabase 설정 초기 검증 (앱 시작 전 확인)
  _validateSupabaseConfig();

  // 글로벌 에러 핸들러 초기화 (필요시)
  GlobalErrorHandler.initialize();

  // 앱 실행
  runApp(const DayLitDriver());
}

// ==================== ⭐ Supabase 설정 검증 ====================
/// 앱 시작 전 Supabase 설정 검증
void _validateSupabaseConfig() {
  try {
    // 설정 상태 로그 출력
    SupabaseConfig.logConfigStatus();

    if (!SupabaseConfig.isConfigured) {
      debugPrint('⚠️ [Main] Supabase 설정이 완료되지 않았습니다.');
      debugPrint('💡 [Main] 앱은 오프라인 모드로 실행됩니다.');
      debugPrint('🔧 [Main] SupabaseConfig 클래스에서 YOUR_*를 실제 값으로 변경하세요.');
    } else {
      debugPrint('✅ [Main] Supabase 설정 검증 완료');
    }
  } catch (e) {
    debugPrint('❌ [Main] Supabase 설정 검증 실패: $e');
  }
}

// ==================== 앱 드라이버 ====================
/// 앱의 최상위 드라이버 클래스
///
/// 디바이스 타입 감지와 ScreenUtil 초기화를 담당합니다.
/// 실제 앱 로직이 시작되기 전 필요한 설정들을 처리합니다.
class DayLitDriver extends StatelessWidget {
  const DayLitDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 디버그 배너 제거
      debugShowCheckedModeBanner: false,

      // 임시 홈 화면 (ScreenUtil 초기화용)
      home: Builder(
        builder: (context) {
          // 디바이스 타입에 따른 디자인 크기 결정
          final designSize = DaylitDevice.getDesignSize(context);
          _logInfo('Device design size determined: ${designSize.width}x${designSize.height}');

          // ScreenUtil 초기화 및 반응형 UI 설정
          return MultiProvider(
              providers: [
                // ⭐ Provider 순서 최적화 (의존성 순서대로)

                // 1. 앱 전역 상태 (가장 먼저 초기화)
                ChangeNotifierProvider(create: (_) => AppState()),

                // 2. 라우터 상태 관리
                ChangeNotifierProvider(create: (_) => RouterProvider()),

                // 3. ⭐ 사용자 상태 관리 (Supabase 연동)
                ChangeNotifierProvider(
                  create: (_) {
                    final provider = UserProvider();
                    // UserProvider 초기화는 AppState에서 Supabase 초기화 후에 실행
                    return provider;
                  },
                ),

                // 4. 기능별 Provider들
                ChangeNotifierProvider(create: (_) => QuestProvider()),
                ChangeNotifierProvider(create: (_) => QuestCreateProvider()),
                ChangeNotifierProvider(create: (_) => WalletProvider()),
              ],
              builder: (context, child) {
                return ScreenUtilInit(
                  designSize: designSize,
                  minTextAdapt: true,
                  splitScreenMode: true,
                  builder: (context, child) {
                    // 뒤로가기 처리와 함께 실제 앱 실행
                    return BackPressHandler(
                      child: const DayLitApp(),
                    );
                  },
                );
              }
          );
        },
      ),
    );
  }

  /// 정보 로깅
  void _logInfo(String message) {
    debugPrint('🚀 [DayLitDriver] $message');
  }
}

// ==================== 메인 앱 ====================
/// DayLit 메인 애플리케이션
///
/// MaterialApp.router를 사용한 라우팅 시스템과
/// 다국어, 테마 시스템을 제공합니다.
/// ⭐ Supabase 연동된 상태 관리 포함
class DayLitApp extends StatelessWidget {
  const DayLitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, UserProvider>(
      builder: (context, appState, userProvider, child) {
        // ⭐ AppState 초기화 완료 후 UserProvider 초기화
        if (appState.isSupabaseInitialized && !userProvider.isLoggedIn) {
          // UserProvider 초기화 (한 번만 실행)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.initialize();
          });
        }

        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // ⭐ 다국어 지원
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.getLocaleFromLanguageCode(appState.language),

          // ⭐ 테마 모드 설정 (다크모드 지원)
          themeMode: appState.colorMode == 'system'
              ? ThemeMode.system
              : appState.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          // ⭐ 테마 설정
          theme: DaylitColors.getLightTheme(),
          darkTheme: DaylitColors.getDarkTheme(),

          // ⭐ 라우팅 설정
          routerConfig: router,

          // ⭐ 글로벌 빌더 (상태바, 시스템 UI 설정)
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: appState.isDarkMode
                  ? const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark, // iOS용
                systemNavigationBarColor: Color(0xFF121212),
                systemNavigationBarIconBrightness: Brightness.light,
              )
                  : const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light, // iOS용
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

// ==================== 전역 에러 처리 ====================
/// 전역 에러 핸들러 (필요시 사용)
///
/// Flutter 앱에서 발생하는 모든 에러를 캐치하고 처리합니다.
/// ⭐ Supabase 에러도 함께 처리
class GlobalErrorHandler {
  /// 에러 핸들러 초기화
  static void initialize() {
    // Flutter 프레임워크 에러 처리
    FlutterError.onError = (FlutterErrorDetails details) {
      _logError('Flutter Error', details.exception, details.stack);

      // 개발 모드에서는 기본 에러 처리
      if (kDebugMode) {
        FlutterError.presentError(details);
      }

      // 프로덕션에서는 에러 리포팅 서비스로 전송
      _reportError(details.exception, details.stack);
    };

    // 비동기 에러 처리
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      _reportError(error, stack);
      return true;
    };
  }

  /// 에러 리포팅 (구현 필요)
  static void _reportError(dynamic error, StackTrace? stack) {
    // TODO: Firebase Crashlytics, Sentry 등 에러 리포팅 서비스 연동
    // ⭐ Supabase 에러도 함께 리포팅

    // Supabase 관련 에러인지 확인
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('supabase') ||
        errorString.contains('postgres') ||
        errorString.contains('authentication')) {
      print('🔴 [Supabase Error] $error');
    }

    print('🚨 [ErrorReporting] Error reported: $error');
  }

  /// 에러 로깅
  static void _logError(String type, dynamic error, StackTrace? stack) {
    print('🚨 [GlobalErrorHandler] $type: $error');
    if (stack != null) {
      print('Stack trace: $stack');
    }
  }
}

// ==================== 앱 상수 ====================
/// 앱 전체에서 사용되는 상수들
/// ⭐ Supabase 관련 상수 추가
class AppConstants {
  // Private 생성자
  AppConstants._();

  // ==================== 앱 정보 ====================
  /// 앱 이름
  static const String appName = 'DayLit';

  /// 앱 버전
  static const String appVersion = '1.0.0';

  /// 빌드 번호
  static const String buildNumber = '1';

  // ==================== 디자인 상수 ====================
  /// 기본 패딩
  static const double defaultPadding = 16.0;

  /// 기본 마진
  static const double defaultMargin = 16.0;

  /// 기본 보더 반지름
  static const double defaultBorderRadius = 12.0;

  // ==================== 애니메이션 상수 ====================
  /// 기본 애니메이션 지속 시간
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  /// 빠른 애니메이션 지속 시간
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  /// 느린 애니메이션 지속 시간
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // ==================== 네트워크 상수 ====================
  /// API 타임아웃 시간
  static const Duration apiTimeout = Duration(seconds: 30);

  /// 연결 타임아웃 시간
  static const Duration connectTimeout = Duration(seconds: 10);

  // ==================== ⭐ Supabase 관련 상수 ====================
  /// Supabase 연결 재시도 간격
  static const Duration supabaseRetryInterval = Duration(seconds: 5);

  /// Supabase 연결 최대 재시도 횟수
  static const int supabaseMaxRetries = 3;

  /// 오프라인 모드 지원 여부
  static const bool enableOfflineMode = true;

  // ==================== 기능 제한 상수 ====================
  /// 무료 사용자 최대 루틴 개수
  static const int freeUserMaxRoutines = 3;

  /// 무료 사용자 월 AI 사용 횟수
  static const int freeUserMonthlyAILimit = 3;

  /// 프리미엄 사용자 최대 루틴 개수 (-1은 무제한)
  static const int premiumUserMaxRoutines = -1;
}

// ==================== 개발 모드 체크 ====================
/// 디버그 모드 여부 확인
bool get kDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

// ==================== ⭐ 개발자 도구 ====================
/// 개발자를 위한 디버그 정보 출력 (디버그 모드에서만)
class DeveloperTools {
  static void printSupabaseStatus() {
    if (!kDebugMode) return;

    print('\n🔧 [DeveloperTools] Supabase 상태 정보:');

    if (!SupabaseConfig.isInitialized) {
      print('  ❌ 초기화되지 않음');
      print('  💡 SupabaseConfig.initialize()를 호출하세요');
      return;
    }

    final configInfo = SupabaseConfig.getConfigInfo();

    print('  - 초기화됨: ${configInfo['initialized']}');
    print('  - 설정 완료: ${configInfo['configured']}');
    print('  - 환경: ${configInfo['environment']}');
    print('  - Deep Link: ${configInfo['deepLinkUrl']}');
    print('  - 오프라인 모드: ${configInfo['offlineMode']}');
    print('  - Realtime: ${configInfo['realtime']}');
    print('  - 디버그 로깅: ${configInfo['debugLogging']}');

    if (SupabaseConfig.isConfigured) {
      final url = SupabaseConfig.supabaseUrl;
      final key = SupabaseConfig.supabaseAnonKey;
      print('  - URL: ${url.length > 50 ? '${url.substring(0, 50)}...' : url}');
      print('  - Key: ${key.length > 20 ? '${key.substring(0, 20)}...' : key}');
    }

    if (configInfo['initializationError'] != null) {
      print('  ❌ 에러: ${configInfo['initializationError']}');
    }

    print('');
  }

  static void printProviderStatus(BuildContext context) {
    if (!kDebugMode) return;

    try {
      final appState = context.read<AppState>();
      final userProvider = context.read<UserProvider>();

      print('\n📊 [DeveloperTools] Provider 상태:');
      print('  AppState:');
      print('    - 초기화됨: ${appState.isInitialized}');
      print('    - Supabase 초기화됨: ${appState.isSupabaseInitialized}');
      print('    - 언어: ${appState.language}');
      print('    - 다크모드: ${appState.isDarkMode}');

      print('  UserProvider:');
      print('    - 로그인됨: ${userProvider.isLoggedIn}');
      print('    - 로딩 중: ${userProvider.isLoading}');
      print('    - 사용자: ${userProvider.userEmail ?? "없음"}');
      print('');
    } catch (e) {
      print('❌ [DeveloperTools] Provider 상태 확인 실패: $e');
    }
  }
}
import 'package:daylit/provider/App_State.dart';
import 'package:daylit/provider/Quest_Create_Provider.dart';
import 'package:daylit/provider/Quest_Provider.dart';
import 'package:daylit/provider/Router_Provider.dart';
import 'package:daylit/provider/User_Provider.dart';
import 'package:daylit/provider/Wallet_Provider.dart';
import 'package:daylit/routes/App_Routes.dart';
import 'package:daylit/service/Localization_Service.dart';
import 'package:daylit/service/Cache_Service.dart'; // 🚀 캐시 서비스 추가
import 'package:daylit/model/quest/Quest_Model.dart'; // 🚀 Hive 어댑터용
import 'package:daylit/model/quest/Quest_Record_Model.dart'; // 🚀 QuestRecordModel 어댑터용
import 'package:daylit/util/Routine_Utils.dart'; // 🚀 RoutineStatus, RecordStatus 어댑터용
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:daylit/util/Daylit_Device.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 🚀 Hive 추가
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

  // 🚀 전역 에러 핸들러 초기화 (캐시 에러도 포함)
  GlobalErrorHandler.initialize();

  try {
    // 🚀 앱 초기화 단계 실행
    await _initializeApp();

    debugPrint('✅ [Main] 앱 초기화 완료 - DayLit 시작');

    // 앱 실행
    runApp(const DayLitDriver());
  } catch (e, stackTrace) {
    debugPrint('❌ [Main] 앱 초기화 실패: $e');
    GlobalErrorHandler._reportError(e, stackTrace);

    // 초기화 실패 시 기본 앱 실행 (오프라인 모드)
    runApp(const _ErrorFallbackApp());
  }
}

// ==================== 🚀 앱 초기화 시스템 ====================
/// 앱 초기화 단계별 실행
Future<void> _initializeApp() async {
  try {
    debugPrint('🚀 [Main] DayLit 앱 초기화 시작...');

    final steps = [
      InitStep('Supabase 설정 검증', _validateSupabaseConfig),
      InitStep('캐시 서비스 초기화', _initializeCacheService), // 🚀 캐시 추가
      InitStep('앱 기본 설정', _initializeBasicSettings),
    ];

    // 단계별 실행
    for (final step in steps) {
      debugPrint('⏳ [Main] ${step.name} 중...');
      await step.function();
      debugPrint('✅ [Main] ${step.name} 완료');
    }

    debugPrint('🎉 [Main] 모든 초기화 단계 완료');

  } catch (e) {
    debugPrint('❌ [Main] 초기화 실패: $e');
    rethrow;
  }
}

/// 초기화 단계 정의
class InitStep {
  final String name;
  final Future<void> Function() function;
  const InitStep(this.name, this.function);
}

// ==================== 🚀 캐시 서비스 초기화 ====================
/// 캐시 서비스 초기화
Future<void> _initializeCacheService() async {
  try {
    debugPrint('🚀 [Cache] Hive 및 캐시 서비스 초기화 시작');

    // 1. Hive 어댑터 등록
    await _registerHiveAdapters();

    // 2. 캐시 서비스 초기화
    final success = await CacheService.instance.initialize();

    if (success) {
      debugPrint('✅ [Cache] 캐시 서비스 초기화 완료');

      // 🎯 개발 모드에서 캐시 통계 출력
      if (kDebugMode) {
        final stats = CacheService.instance.getStats();
        debugPrint('📊 [Cache] 초기 상태: ${stats['totalKeys']}개 키, 온라인: ${stats['isOnline']}');
      }
    } else {
      debugPrint('⚠️ [Cache] 캐시 서비스 초기화 실패 - 일반 모드로 동작');
    }
  } catch (e) {
    debugPrint('❌ [Cache] 캐시 서비스 초기화 오류: $e');
    // 캐시 실패해도 앱은 동작하도록 함
  }
}

/// Hive 어댑터 등록
Future<void> _registerHiveAdapters() async {
  try {
    // QuestModel 어댑터 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(QuestModelAdapter());
      debugPrint('🔧 [Cache] QuestModel 어댑터 등록 완료');
    }

    // RoutineStatus 어댑터 등록
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RoutineStatusAdapter());
      debugPrint('🔧 [Cache] RoutineStatus 어댑터 등록 완료');
    }

    // 추후 추가될 다른 모델들의 어댑터 등록
    // UserModel, WalletModel 등...

    debugPrint('✅ [Cache] 모든 Hive 어댑터 등록 완료');
  } catch (e) {
    debugPrint('❌ [Cache] Hive 어댑터 등록 실패: $e');
    throw Exception('Hive 어댑터 등록에 실패했습니다: ${e.toString()}');
  }
}

// ==================== 기본 초기화 단계들 ====================
/// Supabase 설정 검증
Future<void> _validateSupabaseConfig() async {
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
    throw Exception('Supabase 설정 검증 실패: $e');
  }
}

/// 앱 기본 설정 초기화
Future<void> _initializeBasicSettings() async {
  try {
    // 시스템 UI 기본 설정
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    // 화면 방향 고정 (세로 모드)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    debugPrint('✅ [Main] 기본 설정 초기화 완료');
  } catch (e) {
    debugPrint('⚠️ [Main] 기본 설정 초기화 실패 (무시됨): $e');
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
                // 🚀 Provider 순서 최적화 (의존성 순서대로)

                // 1. 앱 전역 상태 (가장 먼저 초기화)
                ChangeNotifierProvider(create: (_) => AppState()),

                // 2. 라우터 상태 관리
                ChangeNotifierProvider(create: (_) => RouterProvider()),

                // 3. 🚀 사용자 상태 관리 (Supabase 연동)
                ChangeNotifierProvider(
                  create: (_) {
                    final provider = UserProvider();
                    // UserProvider 초기화는 AppState에서 Supabase 초기화 후에 실행
                    return provider;
                  },
                ),

                // 4. 🚀 기능별 Provider들 (캐시 기능 통합)
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
/// 🚀 Supabase 연동된 상태 관리 + 캐시 시스템 포함
class DayLitApp extends StatefulWidget {
  const DayLitApp({super.key});

  @override
  State<DayLitApp> createState() => _DayLitAppState();
}

class _DayLitAppState extends State<DayLitApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 앱 생명주기 관찰자 제거
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      // 🚀 백그라운드 진입 시 캐시 정리
        _onAppPaused();
        break;
      case AppLifecycleState.resumed:
      // 🚀 포그라운드 복구 시 캐시 갱신
        _onAppResumed();
        break;
      case AppLifecycleState.detached:
      // 🚀 앱 종료 시 리소스 정리
        _onAppDetached();
        break;
      default:
        break;
    }
  }

  /// 앱이 백그라운드로 전환될 때
  void _onAppPaused() {
    debugPrint('⏸️ [App] 백그라운드 전환 - 캐시 정리 중...');

    try {
      // 만료된 캐시 정리 (비동기로 실행)
      CacheService.instance.cleanExpiredCache(); // 🚀 public 메서드로 호출
    } catch (e) {
      debugPrint('⚠️ [App] 캐시 정리 실패: $e');
    }
  }

  /// 앱이 포그라운드로 복구될 때
  void _onAppResumed() {
    debugPrint('▶️ [App] 포그라운드 복구 - 데이터 갱신 중...');

    try {
      // Provider들의 데이터 새로고침 (선택적)
      final questProvider = context.read<QuestProvider>();
      questProvider.refresh();
    } catch (e) {
      debugPrint('⚠️ [App] 데이터 갱신 실패: $e');
    }
  }

  /// 앱이 종료될 때
  void _onAppDetached() {
    debugPrint('👋 [App] 앱 종료 - 리소스 정리 중...');

    try {
      // 캐시 서비스 정리
      CacheService.instance.dispose();
    } catch (e) {
      debugPrint('⚠️ [App] 리소스 정리 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, UserProvider>(
      builder: (context, appState, userProvider, child) {
        // 🚀 AppState 초기화 완료 후 UserProvider 초기화
        if (appState.isSupabaseInitialized && !userProvider.isLoggedIn) {
          // UserProvider 초기화 (한 번만 실행)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.initialize();
          });
        }

        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // 🚀 다국어 지원
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.getLocaleFromLanguageCode(appState.language),

          // 🚀 테마 모드 설정 (다크모드 지원)
          themeMode: appState.colorMode == 'system'
              ? ThemeMode.system
              : appState.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          // 🚀 테마 설정
          theme: DaylitColors.getLightTheme(),
          darkTheme: DaylitColors.getDarkTheme(),

          // 🚀 라우팅 설정
          routerConfig: router,

          // 🚀 글로벌 빌더 (상태바, 시스템 UI 설정)
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
/// 전역 에러 핸들러 (캐시 에러 포함)
///
/// Flutter 앱에서 발생하는 모든 에러를 캐치하고 처리합니다.
/// 🚀 Supabase + 캐시 에러도 함께 처리
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
    // 🚀 Supabase + 캐시 에러도 함께 리포팅

    final errorString = error.toString().toLowerCase();

    // Supabase 관련 에러 분류
    if (errorString.contains('supabase') ||
        errorString.contains('postgres') ||
        errorString.contains('authentication') ||
        errorString.contains('realtimesubscribeexception')) {
      debugPrint('🔴 [Supabase Error] $error');
    }

    // 캐시 관련 에러 분류
    else if (errorString.contains('hive') ||
        errorString.contains('cache') ||
        errorString.contains('storage')) {
      debugPrint('🟡 [Cache Error] $error');
    }

    // 일반 에러
    else {
      debugPrint('🚨 [General Error] $error');
    }

    debugPrint('🚨 [ErrorReporting] Error reported: $error');
  }

  /// 에러 로깅
  static void _logError(String type, dynamic error, StackTrace? stack) {
    debugPrint('🚨 [GlobalErrorHandler] $type: $error');
    if (stack != null && kDebugMode) {
      debugPrint('Stack trace: $stack');
    }
  }
}

// ==================== 🚀 에러 폴백 앱 ====================
/// 초기화 실패 시 표시되는 기본 앱
class _ErrorFallbackApp extends StatelessWidget {
  const _ErrorFallbackApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayLit - 오프라인 모드',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  'DayLit',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '앱 초기화에 실패했습니다',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  '네트워크 연결을 확인하고 앱을 다시 시작해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // 앱 재시작을 위한 처리 (구현 필요)
                    SystemNavigator.pop();
                  },
                  child: const Text('앱 종료'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 앱 상수 ====================
/// 앱 전체에서 사용되는 상수들
/// 🚀 Supabase + 캐시 관련 상수 추가
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

  // ==================== 🚀 Supabase 관련 상수 ====================
  /// Supabase 연결 재시도 간격
  static const Duration supabaseRetryInterval = Duration(seconds: 5);

  /// Supabase 연결 최대 재시도 횟수
  static const int supabaseMaxRetries = 3;

  /// 오프라인 모드 지원 여부
  static const bool enableOfflineMode = true;

  // ==================== 🚀 캐시 관련 상수 ====================
  /// 캐시 최대 크기 (50MB)
  static const int maxCacheSize = 50 * 1024 * 1024;

  /// 캐시 최대 키 개수
  static const int maxCacheKeys = 1000;

  /// 캐시 자동 정리 간격 (1시간)
  static const Duration cacheCleanupInterval = Duration(hours: 1);

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

// ==================== 🚀 개발자 도구 (캐시 기능 추가) ====================
/// 개발자를 위한 디버그 정보 출력 (디버그 모드에서만)
class DeveloperTools {
  static void printSupabaseStatus() {
    if (!kDebugMode) return;

    debugPrint('\n🔧 [DeveloperTools] Supabase 상태 정보:');

    if (!SupabaseConfig.isInitialized) {
      debugPrint('  ❌ 초기화되지 않음');
      debugPrint('  💡 SupabaseConfig.initialize()를 호출하세요');
      return;
    }

    final configInfo = SupabaseConfig.getConfigInfo();

    debugPrint('  - 초기화됨: ${configInfo['initialized']}');
    debugPrint('  - 설정 완료: ${configInfo['configured']}');
    debugPrint('  - 환경: ${configInfo['environment']}');
    debugPrint('  - Deep Link: ${configInfo['deepLinkUrl']}');
    debugPrint('  - 오프라인 모드: ${configInfo['offlineMode']}');
    debugPrint('  - Realtime: ${configInfo['realtime']}');
    debugPrint('  - 디버그 로깅: ${configInfo['debugLogging']}');

    if (SupabaseConfig.isConfigured) {
      final url = SupabaseConfig.supabaseUrl;
      final key = SupabaseConfig.supabaseAnonKey;
      debugPrint('  - URL: ${url.length > 50 ? '${url.substring(0, 50)}...' : url}');
      debugPrint('  - Key: ${key.length > 20 ? '${key.substring(0, 20)}...' : key}');
    }

    if (configInfo['initializationError'] != null) {
      debugPrint('  ❌ 에러: ${configInfo['initializationError']}');
    }

    debugPrint('');
  }

  /// 🚀 캐시 상태 출력
  static void printCacheStatus() {
    if (!kDebugMode) return;

    debugPrint('\n💾 [DeveloperTools] 캐시 상태 정보:');

    try {
      final stats = CacheService.instance.getStats();

      debugPrint('  - 초기화됨: ${stats['isInitialized']}');
      debugPrint('  - 온라인: ${stats['isOnline']}');
      debugPrint('  - 전체 키: ${stats['totalKeys']}개');
      debugPrint('  - 총 크기: ${stats['totalSize']} bytes');
      debugPrint('  - 만료된 키: ${stats['expiredCount']}개');
      debugPrint('  - 히트율: ${(stats['hitRate'] as double).toStringAsFixed(2)}%');

    } catch (e) {
      debugPrint('  ❌ 캐시 상태 확인 실패: $e');
    }

    debugPrint('');
  }

  static void printProviderStatus(BuildContext context) {
    if (!kDebugMode) return;

    try {
      final appState = context.read<AppState>();
      final userProvider = context.read<UserProvider>();
      final questProvider = context.read<QuestProvider>(); // 🚀 추가

      debugPrint('\n📊 [DeveloperTools] Provider 상태:');
      debugPrint('  AppState:');
      debugPrint('    - 초기화됨: ${appState.isInitialized}');
      debugPrint('    - Supabase 초기화됨: ${appState.isSupabaseInitialized}');
      debugPrint('    - 언어: ${appState.language}');
      debugPrint('    - 다크모드: ${appState.isDarkMode}');

      debugPrint('  UserProvider:');
      debugPrint('    - 로그인됨: ${userProvider.isLoggedIn}');
      debugPrint('    - 로딩 중: ${userProvider.isLoading}');
      debugPrint('    - 사용자: ${userProvider.userEmail ?? "없음"}');

      // 🚀 QuestProvider 상태 추가
      debugPrint('  QuestProvider:');
      debugPrint('    - 퀘스트 수: ${questProvider.quests.length}개');
      debugPrint('    - 활성 퀘스트: ${questProvider.activeQuests.length}개');
      debugPrint('    - 로딩 중: ${questProvider.isLoading}');
      debugPrint('    - 실시간 연결: ${questProvider.isRealtimeActive}');
      debugPrint('    - 에러: ${questProvider.error ?? "없음"}');

      debugPrint('');
    } catch (e) {
      debugPrint('❌ [DeveloperTools] Provider 상태 확인 실패: $e');
    }
  }

  /// 🚀 전체 시스템 상태 요약
  static void printSystemStatus(BuildContext context) {
    if (!kDebugMode) return;

    debugPrint('\n🔍 [DeveloperTools] 전체 시스템 상태:');
    printSupabaseStatus();
    printCacheStatus();
    printProviderStatus(context);

    debugPrint('💡 [DeveloperTools] 시스템 상태 확인 완료\n');
  }

  /// 🚀 캐시 강제 클리어 (디버깅용)
  static Future<void> clearAllCache() async {
    if (!kDebugMode) return;

    try {
      await CacheService.instance.clearAll();
      debugPrint('🗑️ [DeveloperTools] 전체 캐시 클리어 완료');
    } catch (e) {
      debugPrint('❌ [DeveloperTools] 캐시 클리어 실패: $e');
    }
  }
}
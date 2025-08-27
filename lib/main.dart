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

  // 글로벌 에러 핸들러 초기화 (필요시)
  GlobalErrorHandler.initialize();

  // 앱 실행
  runApp(const DayLitDriver());
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
                // 앱 상태 관리
                ChangeNotifierProvider(create: (_)=> AppState()),

                // 라우터 상태 관리
                ChangeNotifierProvider(create: (_) => RouterProvider()),

                // 사용자 상태 관리
                ChangeNotifierProvider(create: (_) => UserProvider()),

                // 사용자 퀘스트 관리
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
                      child: DayLitApp(),
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
// main.dart의 DayLitApp만 이렇게 수정하세요
class DayLitApp extends StatelessWidget {
  const DayLitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp.router(
          title: 'DayLit',
          debugShowCheckedModeBanner: false,

          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.getLocaleFromLanguageCode(appState.language),

          // 테마 모드 설정
          themeMode: appState.colorMode == 'system'
              ? ThemeMode.system
              : appState.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          theme: DaylitColors.getLightTheme(),
          darkTheme: DaylitColors.getDarkTheme(),
          routerConfig: router,

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
import 'package:daylit/provider/Router_Provider.dart';
import 'package:daylit/routes/App_Routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:daylit/util/Daylit_Device.dart';
import 'package:provider/provider.dart';

import 'handler/Backpress_Handler.dart';

// ==================== 앱 시작점 ====================
/// 앱의 메인 엔트리포인트
///
/// Flutter 앱이 시작될 때 가장 먼저 호출되는 함수입니다.
/// 앱 초기화 작업과 ProviderScope 설정을 담당합니다.
void main() async {
  // Flutter 엔진 초기화 보장
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 스플래시 화면 유지 (앱 로딩 완료까지)
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 앱 실행
  runApp(
    // Riverpod을 사용한 상태 관리를 위해 ProviderScope로 앱 전체를 감싸기
    const DayLitDriver()
  );
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
              ChangeNotifierProvider(create: (_)=> RouterProvider())
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
    print('🚀 [DayLitDriver] $message');
  }
}

// ==================== 메인 앱 ====================
class DayLitApp extends StatelessWidget {
  const DayLitApp({super.key});

  @override
  Widget build(BuildContext context) {
    _logInfo('Building main app with router');

    return MaterialApp.router(
      // ==================== 앱 기본 설정 ====================
      title: 'DayLit',
      debugShowCheckedModeBanner: false,

      // ==================== 테마 설정 ====================
      // 라이트 테마 설정
      theme: DaylitColors.getLightTheme(),

      // 다크 테마 설정
      darkTheme: DaylitColors.getDarkTheme(),

      // 시스템 테마 모드 따라가기
      themeMode: ThemeMode.system,

      // ==================== 라우터 설정 ====================
      routerConfig: router,


      // ==================== 기타 설정 ====================
      // 머티리얼 앱 설정
      builder: (context, child) {
        // 전역 에러 처리나 추가 래퍼가 필요한 경우 여기에 추가
        return _buildAppWrapper(context, child);
      },
    );
  }

  /// 앱 래퍼 빌드
  ///
  /// 전역적으로 적용해야 할 위젯들을 래핑합니다.
  /// 예: 에러 바운더리, 로딩 오버레이, 네트워크 상태 등
  Widget _buildAppWrapper(BuildContext context, Widget? child) {
    if (child == null) {
      return const SizedBox.shrink();
    }

    return MediaQuery(
      // 시스템 폰트 크기 배율 고정 (접근성 고려시 제거 가능)
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: child,
    );
  }

  /// 정보 로깅
  void _logInfo(String message) {
    print('📱 [DayLitApp] $message');
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

// ==================== 사용 예시 주석 ====================
/*
앱 구조:
1. main() - 앱 시작점
2. DayLitDriver - 디바이스 감지 및 ScreenUtil 초기화
3. DayLitApp - 실제 앱 로직, 라우터 및 테마 설정
4. BackPressHandler - 뒤로가기 동작 커스터마이징
5. 각종 Provider들 - 상태 관리

사용법:
- 새로운 전역 설정이 필요한 경우 DayLitApp의 builder에 추가
- 앱 상수가 필요한 경우 AppConstants에 정의
- 에러 처리가 필요한 경우 GlobalErrorHandler 사용
- 로깅이 필요한 경우 각 클래스의 _logInfo, _logError 메서드 참조
*/
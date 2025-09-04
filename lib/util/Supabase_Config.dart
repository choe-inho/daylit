import 'package:flutter/foundation.dart';

/// Supabase 설정 관리 클래스
///
/// DayLit 앱의 Supabase 연결 정보를 관리합니다.
/// 개발/프로덕션 환경에 따라 다른 설정을 사용합니다.
class SupabaseConfig {
  SupabaseConfig._();

  // ==================== 환경별 설정 ====================

  /// 개발 환경 Supabase URL
  static const String _devSupabaseUrl = 'YOUR_DEV_SUPABASE_URL';

  /// 개발 환경 Supabase Anon Key
  static const String _devSupabaseAnonKey = 'YOUR_DEV_SUPABASE_ANON_KEY';

  /// 프로덕션 환경 Supabase URL
  static const String _prodSupabaseUrl = 'YOUR_PROD_SUPABASE_URL';

  /// 프로덕션 환경 Supabase Anon Key
  static const String _prodSupabaseAnonKey = 'YOUR_PROD_SUPABASE_ANON_KEY';

  // ==================== 현재 환경 설정 ====================

  /// 현재 사용할 Supabase URL
  static String get supabaseUrl {
    return kDebugMode ? _devSupabaseUrl : _prodSupabaseUrl;
  }

  /// 현재 사용할 Supabase Anon Key
  static String get supabaseAnonKey {
    return kDebugMode ? _devSupabaseAnonKey : _prodSupabaseAnonKey;
  }

  /// 현재 환경 이름
  static String get environmentName {
    return kDebugMode ? 'development' : 'production';
  }

  // ==================== Deep Link 설정 ====================

  /// 앱 스킴 (Deep Link용)
  static const String appScheme = 'io.daylit.app';

  /// 로그인 콜백 호스트
  static const String loginCallbackHost = 'login-callback';

  /// 전체 Deep Link URL
  static String get deepLinkUrl => '$appScheme://$loginCallbackHost/';

  // ==================== 설정 검증 ====================

  /// 설정이 유효한지 확인
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('YOUR_') &&
        !supabaseAnonKey.contains('YOUR_');
  }

  /// 설정 정보 반환 (디버깅용)
  static Map<String, dynamic> getConfigInfo() {
    return {
      'environment': environmentName,
      'configured': isConfigured,
      'hasUrl': supabaseUrl.isNotEmpty,
      'hasKey': supabaseAnonKey.isNotEmpty,
      'deepLinkUrl': deepLinkUrl,
    };
  }

  /// 설정 상태 로그 출력
  static void logConfigStatus() {
    final info = getConfigInfo();
    final emoji = isConfigured ? '✅' : '❌';

    print('$emoji [SupabaseConfig] 환경: ${info['environment']}');
    print('📊 [SupabaseConfig] 설정 상태:');
    info.forEach((key, value) {
      print('  $key: $value');
    });

    if (!isConfigured) {
      print('⚠️ [SupabaseConfig] Supabase URL과 Key를 설정해주세요!');
      print('💡 [SupabaseConfig] SupabaseConfig 클래스에서 YOUR_*을 실제 값으로 변경하세요.');
    }
  }

  // ==================== 추가 설정 ====================

  /// 최대 재시도 횟수
  static const int maxRetryAttempts = 3;

  /// 연결 타임아웃
  static const Duration connectTimeout = Duration(seconds: 10);

  /// 읽기 타임아웃
  static const Duration readTimeout = Duration(seconds: 30);

  /// 업로드 타임아웃
  static const Duration uploadTimeout = Duration(minutes: 5);
}

/// 환경별 설정을 위한 확장 클래스 (필요시 사용)
extension SupabaseConfigExtensions on SupabaseConfig {
  /// 테스트 환경 여부
  static bool get isTestEnvironment =>
      const bool.fromEnvironment('TESTING', defaultValue: false);

  /// 로컬 환경 여부 (에뮬레이터 등)
  static bool get isLocalEnvironment =>
      const bool.fromEnvironment('LOCAL', defaultValue: false);

  /// 디버그 로깅 활성화 여부
  static bool get enableDebugLogging => kDebugMode || isTestEnvironment;

  /// Realtime 기능 사용 여부
  static bool get enableRealtime => true; // 기본값: 활성화

  /// 오프라인 모드 지원 여부
  static bool get enableOfflineMode => true; // 기본값: 활성화
}

// ==================== 사용 예시 주석 ====================
/*
// 사용법:

1. Supabase 프로젝트 생성 후 URL과 Key 설정:
   - SupabaseConfig 클래스의 YOUR_*를 실제 값으로 변경

2. Deep Link 설정:
   - Android: android/app/src/main/AndroidManifest.xml
   - iOS: ios/Runner/Info.plist

3. 설정 확인:
   SupabaseConfig.logConfigStatus(); // 설정 상태 확인

4. 사용:
   final url = SupabaseConfig.supabaseUrl;
   final key = SupabaseConfig.supabaseAnonKey;
*/
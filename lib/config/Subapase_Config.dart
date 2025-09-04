import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase 설정 관리 클래스 (환경 변수 버전)
///
/// DayLit 앱의 Supabase 연결 정보를 .env 파일에서 관리합니다.
/// 개발/프로덕션 환경에 따라 다른 설정을 자동으로 사용합니다.
///
/// 🔐 보안: API 키와 URL이 코드에 하드코딩되지 않음
/// ⚙️ 유연성: 환경별로 다른 설정 파일 사용 가능
class SupabaseConfig {
  SupabaseConfig._();

  // ==================== 초기화 상태 ====================
  static bool _isInitialized = false;
  static String? _initializationError;

  /// 초기화 상태 확인
  static bool get isInitialized => _isInitialized;

  /// 초기화 에러 메시지
  static String? get initializationError => _initializationError;

  // ==================== 환경 변수 초기화 ====================

  /// 환경 변수 로드 및 초기화
  ///
  /// 앱 시작 시 반드시 호출해야 합니다.
  /// main() 함수나 앱 초기화 과정에서 실행하세요.
  static Future<bool> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ [SupabaseConfig] 이미 초기화됨');
      return true;
    }

    try {
      debugPrint('🔧 [SupabaseConfig] 환경 변수 로드 시작...');

      // 환경별 .env 파일 로드
      final envFile = _getEnvironmentFile();
      debugPrint('📄 [SupabaseConfig] 로드할 파일: $envFile');

      await dotenv.load(fileName: envFile);

      // 필수 환경 변수 검증
      _validateRequiredVariables();

      _isInitialized = true;
      _initializationError = null;

      debugPrint('✅ [SupabaseConfig] 환경 변수 로드 완료');
      return true;

    } catch (error) {
      _isInitialized = false;
      _initializationError = error.toString();

      debugPrint('❌ [SupabaseConfig] 환경 변수 로드 실패: $error');
      debugPrint('💡 [SupabaseConfig] .env 파일이 존재하고 올바르게 설정되어 있는지 확인하세요.');

      return false;
    }
  }

  /// 환경에 따른 .env 파일 경로 결정
  static String _getEnvironmentFile() {
    // 1. 개발자가 직접 지정한 환경 파일 확인
    const customEnvFile = String.fromEnvironment('ENV_FILE');
    if (customEnvFile.isNotEmpty) {
      return customEnvFile;
    }

    // 2. 빌드 모드에 따른 자동 선택
    if (kDebugMode) {
      return '.env';  // 개발 환경
    } else if (kProfileMode) {
      return '.env.staging';  // 스테이징 환경 (선택사항)
    } else {
      return '.env.production';  // 프로덕션 환경 (선택사항)
    }
  }

  /// 필수 환경 변수 검증
  static void _validateRequiredVariables() {
    final requiredVars = [
      'DEV_SUPABASE_URL',
      'DEV_SUPABASE_ANON_KEY',
    ];

    final missingVars = <String>[];

    for (final varName in requiredVars) {
      final value = dotenv.env[varName];
      if (value == null || value.isEmpty || value.startsWith('your-')) {
        missingVars.add(varName);
      }
    }

    if (missingVars.isNotEmpty) {
      throw StateError(
          '필수 환경 변수가 설정되지 않았습니다: ${missingVars.join(', ')}\n'
              '.env 파일에서 해당 값들을 설정해주세요.'
      );
    }
  }

  // ==================== 현재 환경 설정 ====================

  /// 현재 사용할 Supabase URL
  static String get supabaseUrl {
    _ensureInitialized();

    if (kDebugMode) {
      return dotenv.env['DEV_SUPABASE_URL']!;
    } else {
      // 프로덕션 설정이 없으면 개발 설정 사용
      return dotenv.env['PROD_SUPABASE_URL'] ?? dotenv.env['DEV_SUPABASE_URL']!;
    }
  }

  /// 현재 사용할 Supabase Anon Key
  static String get supabaseAnonKey {
    _ensureInitialized();

    if (kDebugMode) {
      return dotenv.env['DEV_SUPABASE_ANON_KEY']!;
    } else {
      // 프로덕션 설정이 없으면 개발 설정 사용
      return dotenv.env['PROD_SUPABASE_ANON_KEY'] ?? dotenv.env['DEV_SUPABASE_ANON_KEY']!;
    }
  }

  /// 현재 환경 이름
  static String get environmentName {
    if (kDebugMode) return 'development';
    if (kProfileMode) return 'staging';
    return 'production';
  }

  /// 초기화 확인
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'SupabaseConfig가 초기화되지 않았습니다. '
              'SupabaseConfig.initialize()를 먼저 호출하세요.'
      );
    }
  }

  // ==================== Deep Link 설정 ====================

  /// 앱 스킴 (Deep Link용)
  static String get appScheme {
    _ensureInitialized();
    return dotenv.env['APP_SCHEME'] ?? 'io.daylit.app';
  }

  /// 로그인 콜백 호스트
  static String get loginCallbackHost {
    _ensureInitialized();
    return dotenv.env['LOGIN_CALLBACK_HOST'] ?? 'login-callback';
  }

  /// 전체 Deep Link URL
  static String get deepLinkUrl => '$appScheme://$loginCallbackHost/';

  // ==================== 추가 설정 ====================

  /// 최대 재시도 횟수
  static int get maxRetryAttempts {
    _ensureInitialized();
    final value = dotenv.env['MAX_RETRY_ATTEMPTS'];
    return int.tryParse(value ?? '3') ?? 3;
  }

  /// 연결 타임아웃
  static Duration get connectTimeout {
    _ensureInitialized();
    final seconds = int.tryParse(dotenv.env['CONNECT_TIMEOUT_SECONDS'] ?? '10') ?? 10;
    return Duration(seconds: seconds);
  }

  /// 읽기 타임아웃
  static Duration get readTimeout {
    _ensureInitialized();
    final seconds = int.tryParse(dotenv.env['READ_TIMEOUT_SECONDS'] ?? '30') ?? 30;
    return Duration(seconds: seconds);
  }

  /// 업로드 타임아웃
  static Duration get uploadTimeout {
    _ensureInitialized();
    return const Duration(minutes: 5); // 기본값: 5분
  }

  /// 오프라인 모드 활성화 여부
  static bool get enableOfflineMode {
    _ensureInitialized();
    final value = dotenv.env['ENABLE_OFFLINE_MODE']?.toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Realtime 기능 사용 여부
  static bool get enableRealtime {
    _ensureInitialized();
    final value = dotenv.env['ENABLE_REALTIME']?.toLowerCase();
    return value != 'false' && value != '0' && value != 'no'; // 기본값: true
  }

  /// 디버그 로깅 활성화 여부
  static bool get enableDebugLogging {
    _ensureInitialized();
    final envValue = dotenv.env['ENABLE_DEBUG_LOGGING']?.toLowerCase();
    final fromEnv = envValue == 'true' || envValue == '1' || envValue == 'yes';
    return kDebugMode || fromEnv; // 개발 모드이거나 환경 변수에서 활성화
  }

  // ==================== 설정 검증 ====================

  /// 설정이 유효한지 확인
  static bool get isConfigured {
    if (!_isInitialized) return false;

    try {
      final url = supabaseUrl;
      final key = supabaseAnonKey;

      return url.isNotEmpty &&
          key.isNotEmpty &&
          url.startsWith('https://') &&
          !url.contains('your-') &&
          !key.contains('your-');
    } catch (e) {
      return false;
    }
  }

  /// 설정 정보 반환 (디버깅용)
  static Map<String, dynamic> getConfigInfo() {
    return {
      'initialized': _isInitialized,
      'environment': environmentName,
      'configured': isConfigured,
      'hasUrl': _isInitialized ? supabaseUrl.isNotEmpty : false,
      'hasKey': _isInitialized ? supabaseAnonKey.isNotEmpty : false,
      'deepLinkUrl': _isInitialized ? deepLinkUrl : 'Not initialized',
      'offlineMode': _isInitialized ? enableOfflineMode : false,
      'realtime': _isInitialized ? enableRealtime : false,
      'debugLogging': _isInitialized ? enableDebugLogging : false,
      'initializationError': _initializationError,
    };
  }

  /// 설정 상태 로그 출력
  static void logConfigStatus() {
    final info = getConfigInfo();
    final emoji = isConfigured ? '✅' : '❌';

    print('$emoji [SupabaseConfig] 환경: ${info['environment']}');
    print('📊 [SupabaseConfig] 설정 상태:');
    info.forEach((key, value) {
      // 민감한 정보는 마스킹
      if (key == 'hasKey' || key == 'hasUrl') {
        print('  $key: $value');
      } else {
        print('  $key: $value');
      }
    });

    if (!isConfigured) {
      if (!_isInitialized) {
        print('⚠️ [SupabaseConfig] 아직 초기화되지 않음');
        print('💡 [SupabaseConfig] SupabaseConfig.initialize()를 호출하세요');
      } else {
        print('⚠️ [SupabaseConfig] .env 파일의 Supabase 설정을 확인해주세요!');
        print('💡 [SupabaseConfig] URL과 Key가 올바르게 설정되어 있는지 확인하세요.');
      }
    }
  }

  // ==================== 환경별 설정 ====================

  /// 개발 환경 설정 정보
  static Map<String, String> get developmentConfig {
    _ensureInitialized();
    return {
      'url': dotenv.env['DEV_SUPABASE_URL'] ?? '',
      'key': dotenv.env['DEV_SUPABASE_ANON_KEY'] ?? '',
    };
  }

  /// 프로덕션 환경 설정 정보
  static Map<String, String> get productionConfig {
    _ensureInitialized();
    return {
      'url': dotenv.env['PROD_SUPABASE_URL'] ?? '',
      'key': dotenv.env['PROD_SUPABASE_ANON_KEY'] ?? '',
    };
  }

  /// 현재 환경 설정 정보
  static Map<String, String> get currentConfig {
    return {
      'url': supabaseUrl,
      'key': supabaseAnonKey,
      'environment': environmentName,
    };
  }
}

/// 환경별 설정을 위한 확장 클래스
extension SupabaseConfigExtensions on SupabaseConfig {
  /// 테스트 환경 여부
  static bool get isTestEnvironment =>
      const bool.fromEnvironment('TESTING', defaultValue: false);

  /// 로컬 환경 여부 (에뮬레이터 등)
  static bool get isLocalEnvironment =>
      const bool.fromEnvironment('LOCAL', defaultValue: false);
}

// ==================== 사용 예시 주석 ====================
/*
// 사용법:

1. .env 파일 생성 및 설정:
   - 프로젝트 루트에 .env 파일 생성
   - Supabase URL과 Key 설정

2. pubspec.yaml 설정:
   flutter:
     assets:
       - .env

3. 앱 시작 시 초기화:
   await SupabaseConfig.initialize();

4. 설정 사용:
   final url = SupabaseConfig.supabaseUrl;
   final key = SupabaseConfig.supabaseAnonKey;

5. 설정 확인:
   SupabaseConfig.logConfigStatus();
*/
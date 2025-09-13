import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

/// Supabase 서비스 관리 클래스 (로깅 에러 수정)
///
/// DayLit 앱의 모든 Supabase 관련 기능을 중앙 관리합니다.
/// 2025년 최신 Supabase Flutter SDK v2 사용
///
/// 주요 기능:
/// - Supabase 초기화 및 연결 관리
/// - 인증 상태 모니터링
/// - 에러 처리 및 로깅 (수정된 로깅 시스템)
/// - 연결 상태 확인
/// - 개발/프로덕션 환경 분리
class SupabaseService {
  // ==================== 싱글톤 패턴 ====================
  static SupabaseService? _instance;
  SupabaseService._internal();

  /// 싱글톤 인스턴스 반환
  static SupabaseService get instance {
    _instance ??= SupabaseService._internal();
    return _instance!;
  }

  // ==================== 상태 관리 ====================
  bool _isInitialized = false;
  bool _isConnected = false;
  String? _lastError;

  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized;

  /// 연결 상태 확인
  bool get isConnected => _isConnected;

  /// 마지막 에러 메시지
  String? get lastError => _lastError;

  // ==================== Supabase 클라이언트 접근 ====================
  /// Supabase 클라이언트 인스턴스
  ///
  /// 초기화 후에만 사용 가능합니다.
  /// 사용 전 반드시 [isInitialized] 확인 필요
  SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError('SupabaseService가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
    return Supabase.instance.client;
  }

  /// 인증 클라이언트 접근
  GoTrueClient get auth => client.auth;

  /// 데이터베이스 클라이언트 접근
  SupabaseQueryBuilder from(String table) => client.from(table);

  /// 스토리지 클라이언트 접근
  SupabaseStorageClient get storage => client.storage;

  /// Realtime 클라이언트 접근
  RealtimeClient get realtime => client.realtime;

  // ==================== 로깅 설정 (수정된 버전) ====================
  late final Logger _logger;
  bool _debugLoggingEnabled = false;

  /// 로거 초기화 - hierarchicalLoggingEnabled 에러 해결
  void _initializeLogger() {
    _logger = Logger('supabase.daylit');

    // 디버그 모드에서만 로깅 활성화
    _debugLoggingEnabled = kDebugMode;

    // hierarchicalLoggingEnabled 설정 (선택사항)
    if (_debugLoggingEnabled) {
      hierarchicalLoggingEnabled = true;

      // 이제 개별 Logger level 설정 가능
      _logger.level = Level.ALL;

      // 콘솔 로그 출력 리스너 등록
      _logger.onRecord.listen((record) {
        final emoji = _getLogEmoji(record.level);
        debugPrint('$emoji [${record.loggerName}] ${record.level.name}: ${record.message}');

        if (record.error != null) {
          debugPrint('  Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          debugPrint('  StackTrace: ${record.stackTrace}');
        }
      });
    }
  }

  /// 로그 레벨별 이모지 반환
  String _getLogEmoji(Level level) {
    switch (level.name) {
      case 'SEVERE': return '🔴';
      case 'WARNING': return '🟡';
      case 'INFO': return '🔵';
      case 'FINE': return '🟢';
      case 'FINER': return '🟣';
      case 'FINEST': return '⚪';
      default: return '📝';
    }
  }

  /// 안전한 로그 출력 (에러 방지)
  void _logInfo(String message) {
    if (_debugLoggingEnabled) {
      _logger.info(message);
    } else {
      debugPrint('🔵 [Supabase] $message');
    }
  }

  void _logWarning(String message) {
    if (_debugLoggingEnabled) {
      _logger.warning(message);
    } else {
      debugPrint('🟡 [Supabase] $message');
    }
  }

  void _logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (_debugLoggingEnabled) {
      _logger.severe(message, error, stackTrace);
    } else {
      debugPrint('🔴 [Supabase] $message');
      if (error != null) debugPrint('  Error: $error');
    }
  }

  void _logFine(String message) {
    if (_debugLoggingEnabled) {
      _logger.fine(message);
    } else if (kDebugMode) {
      debugPrint('🟢 [Supabase] $message');
    }
  }

  // ==================== 초기화 ====================
  /// Supabase 서비스 초기화
  ///
  /// [supabaseUrl]: Supabase 프로젝트 URL
  /// [supabaseKey]: Supabase anon/public 키
  /// [enableLogging]: 로깅 활성화 여부 (기본값: 개발모드에서만)
  /// [enableRealtime]: Realtime 기능 활성화 여부 (기본값: true)
  /// [storageRetryAttempts]: 스토리지 재시도 횟수 (기본값: 3)
  ///
  /// Returns: 초기화 성공 여부
  Future<bool> initialize({
    required String supabaseUrl,
    required String supabaseKey,
    bool? enableLogging,
    bool enableRealtime = true,
    int storageRetryAttempts = 3,
  }) async {
    try {
      // 로거 초기화 (에러 방지)
      _initializeLogger();
      _logInfo('🚀 Supabase 서비스 초기화 시작');

      // 이미 초기화된 경우 건너뛰기
      if (_isInitialized) {
        _logInfo('✅ Supabase는 이미 초기화되었습니다');
        return true;
      }

      // URL과 키 유효성 검사
      if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
        throw ArgumentError('Supabase URL과 키는 필수입니다');
      }

      _logInfo('📡 Supabase 연결 설정 중...');

      // Supabase 초기화 설정
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          detectSessionInUri: true,
          autoRefreshToken: true,
        ),
        realtimeClientOptions: RealtimeClientOptions(
          logLevel: kDebugMode ? RealtimeLogLevel.info : RealtimeLogLevel.error,
          timeout: const Duration(seconds: 30),
          eventsPerSecond: 10
        ),
        storageOptions: StorageClientOptions(
          retryAttempts: storageRetryAttempts,
        ),
        postgrestOptions: const PostgrestClientOptions(
          schema: 'public',
        ),
        debug: enableLogging ?? kDebugMode,
      );

      _logInfo('🔌 Supabase 초기화 완료, 연결 상태 확인 중...');

      // 연결 상태 확인
      await _checkConnection();

      _isInitialized = true;
      _lastError = null;

      _logInfo('✅ Supabase 서비스 초기화 완료');
      _logInfo('🌐 연결 상태: ${_isConnected ? "연결됨" : "연결 안됨"}');

      // 인증 상태 변화 리스너 등록
      _setupAuthStateListener();

      return true;

    } catch (error, stackTrace) {
      _lastError = error.toString();
      _logError('❌ Supabase 초기화 실패', error, stackTrace);
      return false;
    }
  }

  // ==================== 연결 관리 ====================
  /// Supabase 연결 상태 확인
  Future<bool> _checkConnection() async {
    try {
      _logFine('🔍 Supabase 연결 상태 확인 중...');

      // 간단한 health check 쿼리
      final response = await client
          .from('user_profiles') // 실제 테이블로 변경
          .select('count')
          .limit(1);

      _isConnected = true;
      _logFine('✅ Supabase 연결 확인 성공');
      return true;
    } catch (error) {
      // 테이블이 없거나 권한이 없는 경우도 연결은 된 것으로 간주
      if (error.toString().contains('permission') ||
          error.toString().contains('does not exist') ||
          error.toString().contains('relation') ||
          error.toString().contains('table')) {
        _isConnected = true;
        _logFine('✅ Supabase 연결됨 (테이블 접근 권한 제한)');
        return true;
      }

      _isConnected = false;
      _logWarning('⚠️ Supabase 연결 확인 실패: $error');
      return false;
    }
  }

  /// 연결 상태 재확인 (공개 메서드)
  Future<bool> checkConnection() async {
    if (!_isInitialized) {
      _logWarning('⚠️ Supabase가 초기화되지 않음');
      return false;
    }

    return await _checkConnection();
  }

  // ==================== 인증 상태 관리 ====================
  /// 인증 상태 변화 리스너 설정
  void _setupAuthStateListener() {
    _logInfo('🔐 인증 상태 리스너 등록 중...');

    auth.onAuthStateChange.listen((AuthState data) {
      final event = data.event;
      final session = data.session;

      _logInfo('🔐 인증 상태 변화: $event');

      switch (event) {
        case AuthChangeEvent.initialSession:
          _logInfo('🔄 초기 세션 복원');
          break;
        case AuthChangeEvent.signedIn:
          _logInfo('✅ 사용자 로그인: ${session?.user.email}');
          break;
        case AuthChangeEvent.signedOut:
          _logInfo('👋 사용자 로그아웃');
          break;
        case AuthChangeEvent.tokenRefreshed:
          _logFine('🔄 토큰 갱신됨');
          break;
        case AuthChangeEvent.userUpdated:
          _logInfo('👤 사용자 정보 업데이트됨');
          break;
        case AuthChangeEvent.passwordRecovery:
          _logInfo('🔑 비밀번호 복구');
          break;
        case AuthChangeEvent.mfaChallengeVerified:
          _logInfo('🛡️ MFA 인증 완료');
          break;
        default:
          _logWarning('⚠️ 알 수 없는 인증 이벤트: $event');
          break;
      }
    }, onError: (error) {
      _logError('❌ 인증 상태 리스너 에러', error);
    });
  }

  // ==================== 헬스 체크 ====================
  /// 서비스 상태 정보 반환
  Map<String, dynamic> getHealthStatus() {
    return {
      'initialized': _isInitialized,
      'connected': _isConnected,
      'hasActiveSession': _isInitialized ? auth.currentSession != null : false,
      'currentUser': _isInitialized ? auth.currentUser?.email : null,
      'lastError': _lastError,
      'debugLogging': _debugLoggingEnabled,
      'timestamp': DateTime.now().toIso8601String(),
      'sdkVersion': '2.x', // Supabase Flutter SDK v2
    };
  }

  /// 서비스 상태를 로그로 출력
  void logHealthStatus() {
    final status = getHealthStatus();
    _logInfo('📊 Supabase 서비스 상태:');
    status.forEach((key, value) {
      _logInfo('  $key: $value');
    });
  }

  // ==================== 정리 ====================
  /// 서비스 정리 (앱 종료 시 호출)
  Future<void> dispose() async {
    try {
      _logInfo('🧹 Supabase 서비스 정리 시작');

      // 필요한 정리 작업 수행
      // (현재 Supabase Flutter SDK는 자동으로 정리됨)

      _isInitialized = false;
      _isConnected = false;
      _lastError = null;

      _logInfo('✅ Supabase 서비스 정리 완료');
    } catch (error) {
      _logError('❌ Supabase 서비스 정리 실패', error);
    }
  }

  // ==================== 유틸리티 메서드들 ====================

  /// 현재 사용자 정보 안전하게 가져오기
  User? getCurrentUser() {
    try {
      return _isInitialized ? auth.currentUser : null;
    } catch (error) {
      _logError('현재 사용자 정보 가져오기 실패', error);
      return null;
    }
  }

  /// 현재 세션 안전하게 가져오기
  Session? getCurrentSession() {
    try {
      return _isInitialized ? auth.currentSession : null;
    } catch (error) {
      _logError('현재 세션 정보 가져오기 실패', error);
      return null;
    }
  }

  /// 로그아웃 (안전한 방법)
  Future<void> signOut() async {
    try {
      if (!_isInitialized) {
        _logWarning('Supabase가 초기화되지 않음 - 로그아웃 불가');
        return;
      }

      _logInfo('🚪 로그아웃 시작');
      await auth.signOut();
      _logInfo('✅ 로그아웃 완료');
    } catch (error) {
      _logError('❌ 로그아웃 실패', error);
      rethrow;
    }
  }
}

// ==================== 편의 확장 메서드 ====================
/// SupabaseService 편의 확장
extension SupabaseServiceExtension on SupabaseService {
  /// 현재 사용자가 로그인 상태인지 확인
  bool get isLoggedIn {
    try {
      return isInitialized && auth.currentUser != null;
    } catch (error) {
      debugPrint('❌ 로그인 상태 확인 실패: $error');
      return false;
    }
  }

  /// 현재 사용자 정보 (안전)
  User? get currentUser => getCurrentUser();

  /// 현재 세션 (안전)
  Session? get currentSession => getCurrentSession();

  /// 사용자 ID (로그인된 경우에만)
  String? get userId => currentUser?.id;

  /// 사용자 이메일 (로그인된 경우에만)
  String? get userEmail => currentUser?.email;
}
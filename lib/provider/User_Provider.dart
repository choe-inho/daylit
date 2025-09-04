import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ⭐ 기존 프로젝트의 UserModel import
import '../model/User_Model.dart';
import '../util/Daylit_Social.dart';
import '../service/Supabase_Service.dart';

/// 사용자 상태 관리 Provider (기존 UserModel과 Supabase 연동)
///
/// DayLit 앱의 사용자 인증 및 프로필 관리를 담당합니다.
/// 기존 UserModel 구조를 유지하면서 Supabase Auth와 통합합니다.
class UserProvider extends ChangeNotifier {

  // ==================== 기존 프로젝트 호환 ====================
  /// 기존 프로젝트의 UserModel (메인 사용자 정보)
  UserModel? daylitUser;

  // ==================== Supabase 연동 상태 ====================
  User? _supabaseUser;          // Supabase Auth User
  Session? _currentSession;     // 현재 세션
  bool _isLoading = false;      // 로딩 상태
  String? _errorMessage;        // 에러 메시지

  // ==================== Getters ====================

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 에러 메시지
  String? get errorMessage => _errorMessage;

  /// 로그인 상태 (기존 프로젝트 호환)
  bool get isLoggedIn => daylitUser != null && daylitUser!.isLoggedIn;

  /// Supabase 사용자
  User? get supabaseUser => _supabaseUser;

  /// 현재 세션
  Session? get currentSession => _currentSession;

  /// 사용자 ID (Supabase uid)
  String? get userId => _supabaseUser?.id;

  /// 사용자 이메일
  String get userEmail => daylitUser?.email ?? _supabaseUser?.email ?? '';

  /// 사용자 닉네임 (기존 UserModel의 id 필드)
  String get userNickname => daylitUser?.id ?? '';

  /// 사용자 레벨
  int get userLevel => daylitUser?.level ?? 1;

  /// 소셜 로그인 타입
  Social get socialType => daylitUser?.socialType ?? Social.google;

  /// 프로필 이미지 URL
  String? get profileImageUrl => daylitUser?.profileUrl ?? _supabaseUser?.userMetadata?['avatar_url'];

  /// 사용자 성별
  String? get userGender => daylitUser?.gender;

  /// 가입 후 경과 일수
  int get daysSinceJoined => daylitUser?.daysSinceJoined ?? 0;

  /// 마지막 로그인 후 경과 일수
  int get daysSinceLastLogin => daylitUser?.daysSinceLastLogin ?? -1;

  // ==================== 초기화 ====================

  /// UserProvider 초기화
  void initialize() {
    _logInfo('UserProvider 초기화');

    // Supabase 인증 상태 변화 리스너 설정
    _setupAuthStateListener();

    // 현재 세션 확인
    _checkCurrentSession();
  }

  /// 인증 상태 변화 리스너 설정
  void _setupAuthStateListener() {
    if (!SupabaseService.instance.isInitialized) {
      _logWarning('Supabase가 초기화되지 않음 - 인증 리스너 설정 불가');
      return;
    }

    SupabaseService.instance.auth.onAuthStateChange.listen((AuthState data) async {
      final event = data.event;
      final session = data.session;

      _logInfo('인증 상태 변화: $event');

      switch (event) {
        case AuthChangeEvent.initialSession:
          await _handleInitialSession(session);
          break;
        case AuthChangeEvent.signedIn:
          await _handleSignedIn(session);
          break;
        case AuthChangeEvent.signedOut:
          await _handleSignedOut();
          break;
        case AuthChangeEvent.tokenRefreshed:
          await _handleTokenRefreshed(session);
          break;
        case AuthChangeEvent.userUpdated:
          await _handleUserUpdated(session);
          break;
        case AuthChangeEvent.passwordRecovery:
          _logInfo('비밀번호 복구 진행 중');
          break;
        case AuthChangeEvent.mfaChallengeVerified:
          _logInfo('MFA 인증 완료');
          break;
        default:
          _logWarning('알 수 없는 인증 이벤트: $event');
          break;
      }
    }, onError: (error) {
      _logError('인증 상태 리스너 에러: $error');
      _setError('인증 상태 모니터링 중 오류가 발생했습니다.');
    });
  }

  /// 현재 세션 확인
  ///
  /// 참고: Supabase v2에서는 initialSession 이벤트가 자동으로 발생하므로
  /// 이 메서드는 보조적인 역할을 합니다.
  void _checkCurrentSession() {
    try {
      if (!SupabaseService.instance.isInitialized) return;

      final session = SupabaseService.instance.currentSession;
      final user = SupabaseService.instance.currentUser;

      if (session != null && user != null) {
        // initialSession 이벤트에서 처리되지 않은 경우를 위한 백업 로직
        _currentSession = session;
        _supabaseUser = user;

        _logInfo('기존 세션 확인됨 (백업 로직): ${user.email}');

        // DayLit 사용자 정보 로드
        _loadDaylitUserProfile();
      } else {
        _logInfo('기존 세션 없음');
      }
    } catch (e) {
      _logError('세션 확인 실패: $e');
    }
  }

  // ==================== 인증 이벤트 핸들러 ====================

  /// 초기 세션 처리 (앱 시작 시 기존 세션 복원)
  Future<void> _handleInitialSession(Session? session) async {
    if (session?.user != null) {
      _currentSession = session;
      _supabaseUser = session!.user;
      _errorMessage = null;

      _logInfo('초기 세션 복원: ${_supabaseUser!.email}');

      // DayLit 사용자 정보 로드
      await _loadDaylitUserProfile();

      notifyListeners();
    } else {
      _logInfo('초기 세션 없음');
    }
  }

  /// 로그인 완료 처리
  Future<void> _handleSignedIn(Session? session) async {
    if (session?.user != null) {
      _currentSession = session;
      _supabaseUser = session!.user;
      _errorMessage = null;

      _logInfo('로그인 성공: ${_supabaseUser!.email}');

      // DayLit 사용자 정보 로드
      await _loadDaylitUserProfile();

      notifyListeners();
    }
  }

  /// 로그아웃 처리
  Future<void> _handleSignedOut() async {
    _currentSession = null;
    _supabaseUser = null;
    daylitUser = null;  // ⭐ 기존 UserModel 초기화
    _errorMessage = null;

    _logInfo('로그아웃 완료');
    notifyListeners();
  }

  /// 토큰 갱신 처리
  Future<void> _handleTokenRefreshed(Session? session) async {
    if (session != null) {
      _currentSession = session;
      _logInfo('토큰 갱신됨');
      notifyListeners();
    }
  }

  /// 사용자 정보 업데이트 처리
  Future<void> _handleUserUpdated(Session? session) async {
    if (session?.user != null) {
      _supabaseUser = session!.user;
      _logInfo('사용자 정보 업데이트됨');

      // DayLit 사용자 정보 다시 로드
      await _loadDaylitUserProfile();
      notifyListeners();
    }
  }

  // ==================== DayLit 사용자 프로필 관리 ====================

  /// DayLit 사용자 프로필 로드
  Future<void> _loadDaylitUserProfile() async {
    try {
      if (_supabaseUser == null) return;

      // user_profiles 테이블에서 DayLit 사용자 정보 조회
      final response = await SupabaseService.instance
          .from('user_profiles')
          .select()
          .eq('uid', _supabaseUser!.id)
          .maybeSingle();

      if (response != null) {
        // 기존 UserModel 생성
        daylitUser = UserModel.fromJson(response);
        _logInfo('DayLit 사용자 프로필 로드 성공: ${daylitUser!.id}');
      } else {
        // 프로필이 없으면 기본 프로필 생성
        await _createDefaultDaylitProfile();
      }

      notifyListeners();
    } catch (e) {
      _logError('DayLit 사용자 프로필 로드 실패: $e');
      // 프로필 로드 실패 시 기본값 사용
      daylitUser = _createFallbackUserModel();
      notifyListeners();
    }
  }

  /// 기본 DayLit 프로필 생성
  Future<void> _createDefaultDaylitProfile() async {
    try {
      final defaultProfile = _getDefaultProfileData();

      await SupabaseService.instance
          .from('user_profiles')
          .insert(defaultProfile);

      daylitUser = UserModel.fromJson(defaultProfile);
      _logInfo('기본 DayLit 프로필 생성 완료: ${daylitUser!.id}');
    } catch (e) {
      _logError('기본 DayLit 프로필 생성 실패: $e');
      daylitUser = _createFallbackUserModel();
    }
  }

  /// 기본 프로필 데이터 생성
  Map<String, dynamic> _getDefaultProfileData() {
    final now = DateTime.now();
    final email = _supabaseUser!.email!;
    final nickname = email.split('@').first;

    return {
      'uid': _supabaseUser!.id,
      'id': nickname,  // 이메일에서 닉네임 추출
      'socialType': _detectSocialTypeFromProvider(), // Provider에서 소셜 타입 감지
      'email': email,
      'lastLogin': now.toIso8601String(),
      'gender': null,
      'level': 1,
      'createAt': now.toIso8601String(),
      'profileUrl': _supabaseUser!.userMetadata?['avatar_url'],
    };
  }

  /// 소셜 로그인 타입 감지 (Provider 기반)
  String _detectSocialTypeFromProvider() {
    final providers = _supabaseUser?.appMetadata?['providers'] as List<dynamic>?;

    if (providers != null && providers.isNotEmpty) {
      final provider = providers.first.toString().toLowerCase();
      switch (provider) {
        case 'google': return 'google';
        case 'apple': return 'apple';
        case 'discord': return 'discord';
        default: return 'google'; // 기본값
      }
    }

    // OAuth Provider 정보에서 감지
    final identities = _supabaseUser?.identities;
    if (identities != null && identities.isNotEmpty) {
      final provider = identities.first.provider?.toLowerCase() ?? '';
      switch (provider) {
        case 'google': return 'google';
        case 'apple': return 'apple';
        case 'discord': return 'discord';
        default: return 'google';
      }
    }

    return 'google'; // 기본값
  }

  /// 폴백용 UserModel 생성 (Supabase 연결 실패 시)
  UserModel _createFallbackUserModel() {
    final now = DateTime.now();
    return UserModel(
      uid: _supabaseUser?.id ?? '',
      id: _supabaseUser?.email?.split('@').first ?? 'user',
      socialType: Social.google,
      email: _supabaseUser?.email ?? '',
      lastLogin: now,
      gender: null,
      level: 1,
      createAt: now,
      profileUrl: _supabaseUser?.userMetadata?['avatar_url'],
    );
  }

  // ==================== 인증 메서드 ====================

  /// 이메일/비밀번호 회원가입
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? nickname,
    String? gender,
  }) async {
    return await _executeWithLoading(() async {
      final response = await SupabaseService.instance.auth.signUp(
        email: email,
        password: password,
        data: {
          'nickname': nickname,
          'gender': gender,
        },
      );

      if (response.user != null) {
        _logInfo('회원가입 성공: $email');
        return true;
      } else {
        throw Exception('회원가입에 실패했습니다.');
      }
    });
  }

  /// 이메일/비밀번호 로그인
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _executeWithLoading(() async {
      final response = await SupabaseService.instance.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _logInfo('로그인 성공: $email');
        return true;
      } else {
        throw Exception('로그인에 실패했습니다.');
      }
    });
  }

  /// 매직링크 로그인
  Future<bool> signInWithMagicLink({required String email}) async {
    return await _executeWithLoading(() async {
      await SupabaseService.instance.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.daylit.app://login-callback/',
      );

      _logInfo('매직링크 전송: $email');
      return true;
    });
  }

  /// 구글 로그인
  Future<bool> signInWithGoogle() async {
    return await _executeWithLoading(() async {
      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.daylit.app://login-callback/',
      );

      if (response) {
        _logInfo('구글 로그인 시작됨');
        return true;
      } else {
        throw Exception('구글 로그인에 실패했습니다.');
      }
    });
  }

  /// 애플 로그인
  Future<bool> signInWithApple() async {
    return await _executeWithLoading(() async {
      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.daylit.app://login-callback/',
      );

      if (response) {
        _logInfo('애플 로그인 시작됨');
        return true;
      } else {
        throw Exception('애플 로그인에 실패했습니다.');
      }
    });
  }

  /// 로그아웃
  Future<bool> signOut() async {
    return await _executeWithLoading(() async {
      await SupabaseService.instance.auth.signOut();
      _logInfo('로그아웃 요청됨');
      return true;
    });
  }

  /// 비밀번호 재설정 이메일 발송
  Future<bool> resetPassword({required String email}) async {
    return await _executeWithLoading(() async {
      await SupabaseService.instance.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.daylit.app://password-reset/',
      );

      _logInfo('비밀번호 재설정 이메일 발송: $email');
      return true;
    });
  }

  /// 비밀번호 변경
  Future<bool> updatePassword({required String newPassword}) async {
    return await _executeWithLoading(() async {
      final response = await SupabaseService.instance.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        _logInfo('비밀번호 변경 성공');
        return true;
      } else {
        throw Exception('비밀번호 변경에 실패했습니다.');
      }
    });
  }

  // ==================== 프로필 업데이트 ====================

  /// DayLit 사용자 프로필 업데이트
  Future<bool> updateDaylitProfile({
    String? nickname,
    String? gender,
    String? profileUrl,
  }) async {
    return await _executeWithLoading(() async {
      if (daylitUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final updateData = <String, dynamic>{
        'lastLogin': DateTime.now().toIso8601String(),
      };

      if (nickname != null) updateData['id'] = nickname;
      if (gender != null) updateData['gender'] = gender;
      if (profileUrl != null) updateData['profileUrl'] = profileUrl;

      await SupabaseService.instance
          .from('user_profiles')
          .update(updateData)
          .eq('uid', daylitUser!.uid);

      // 로컬 모델 업데이트
      daylitUser = daylitUser!.copyWith(
        id: nickname,
        gender: gender,
        profileUrl: profileUrl,
        lastLogin: DateTime.now(),
      );

      _logInfo('DayLit 프로필 업데이트 성공');
      return true;
    });
  }

  // ==================== 기존 프로젝트 호환 메서드 ====================

  /// Supabase에서 사용자 데이터 로드 (App_State에서 호출)
  Future<void> loadUserFromSupabase() async {
    if (isLoggedIn) {
      await _loadDaylitUserProfile();
    }
  }

  /// 로컬 저장소에서 사용자 정보 로드 (기존 프로젝트 호환)
  Future<void> loadUserFromStorage() async {
    // TODO: 기존 프로젝트의 로컬 저장소 로직과 연동
    _logInfo('로컬 저장소에서 사용자 정보 로드 (구현 필요)');
  }

  // ==================== 헬퍼 메서드 ====================

  /// 로딩 상태와 함께 비동기 작업 실행
  Future<bool> _executeWithLoading(Future<bool> Function() operation) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await operation();
      return result;
    } catch (e) {
      _logError('작업 실행 실패: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 메시지 설정
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 에러 메시지 클리어
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== 로깅 ====================

  void _logInfo(String message) {
    debugPrint('👤 [UserProvider] $message');
  }

  void _logWarning(String message) {
    debugPrint('⚠️ [UserProvider] $message');
  }

  void _logError(String message) {
    debugPrint('❌ [UserProvider] $message');
  }

  // ==================== 정리 ====================

  @override
  void dispose() {
    _logInfo('UserProvider 정리');
    super.dispose();
  }
}

// ==================== 확장 메서드 ====================

/// UserProvider 편의 확장 (기존 UserModel 호환)
extension UserProviderExtensions on UserProvider {
  /// 사용자 닉네임 설정 여부
  bool get hasNickname => daylitUser?.hasNickname ?? false;

  /// 성별 설정 여부
  bool get hasGender => daylitUser?.hasGender ?? false;

  /// 프로필 완성도 (0-100)
  int get profileCompleteness {
    if (daylitUser == null) return 0;

    int completedFields = 0;
    int totalFields = 4;

    if (daylitUser!.id != null && daylitUser!.id!.isNotEmpty) completedFields++;
    if (daylitUser!.email.isNotEmpty) completedFields++;
    if (daylitUser!.gender != null) completedFields++;
    if (daylitUser!.profileUrl != null) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  /// 레벨업 가능 여부 (예시 로직)
  bool get canLevelUp => daylitUser != null && daysSinceJoined >= (userLevel * 7);
}
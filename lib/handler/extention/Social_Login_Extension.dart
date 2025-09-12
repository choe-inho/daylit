import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/User_Model.dart';
import '../../provider/User_Provider.dart';
import '../../service/Supabase_Service.dart';
import '../../util/Daylit_Social.dart';

/// 수정된 소셜 로그인 확장 (2024-2025 최신 방법)
///
/// ✅ 실제 AuthState 이벤트까지 기다리는 올바른 방식
/// ✅ OAuth 시작 ≠ 로그인 성공을 구분
/// ✅ 타임아웃 처리로 무한 대기 방지
/// ✅ camelCase 필드명 사용으로 UserProvider와 호환
/// ✅ 중복 프로필 생성 방지
extension SocialLoginExtension on UserProvider {

  // ==================== 소셜 로그인 메인 메서드 ====================

  /// 소셜 로그인 실행 (수정된 버전)
  ///
  /// [socialType]: 로그인할 소셜 플랫폼 타입
  /// [context]: BuildContext (리다이렉트용)
  /// [timeout]: 로그인 대기 시간 (기본 2분)
  ///
  /// Returns: 실제 로그인 성공 여부 (AuthState 이벤트 기준)
  Future<bool> signInWithSocial({
    required Social socialType,
    BuildContext? context,
    Duration timeout = const Duration(minutes: 2),
  }) async {
    try {
      switch (socialType) {
        case Social.google:
          return await _signInWithGoogleFixed(timeout);
        case Social.apple:
          return await _signInWithAppleFixed(timeout);
        case Social.discord:
          return await _signInWithDiscordFixed(timeout);
        case Social.kakao:
          return await _signInWithKakaoFixed(timeout);
      }
    } catch (error) {
      _logError('소셜 로그인 실패: $error');
      rethrow;
    }
  }

  // ==================== 수정된 개별 소셜 로그인 구현 ====================

  /// 🔧 수정된 카카오 소셜 로그인 (실제 로그인 완료까지 대기)
  Future<bool> _signInWithKakaoFixed(Duration timeout) async {
    _logInfo('🚀 카카오 로그인 시작 (실제 완료까지 대기)');

    final Completer<bool> loginCompleter = Completer<bool>();
    StreamSubscription<AuthState>? authSubscription;
    Timer? timeoutTimer;

    try {
      final initialUser = SupabaseService.instance.auth.currentUser;

      authSubscription = SupabaseService.instance.auth.onAuthStateChange.listen(
            (AuthState data) async {
          final event = data.event;
          final session = data.session;
          final user = session?.user;

          _logInfo('🔐 Kakao Auth Event 수신: $event');

          if (event == AuthChangeEvent.signedIn &&
              session != null &&
              user != null &&
              user.id != initialUser?.id) {

            _logInfo('🎉 카카오 로그인 성공: ${user.email}');

            // 프로필 동기화를 비동기로 실행 (로그인 완료를 막지 않음)
            _syncProfileSafely();

            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(true);
            }
          }
          else if (event == AuthChangeEvent.signedOut && initialUser == null) {
            _logError('❌ 카카오 로그인 실패');
            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(false);
            }
          }
        },
        onError: (error) {
          _logError('카카오 Auth 리스너 에러: $error');
          if (!loginCompleter.isCompleted) {
            loginCompleter.completeError(error);
          }
        },
      );

      timeoutTimer = Timer(timeout, () {
        _logError('⏰ 카카오 로그인 타임아웃');
        if (!loginCompleter.isCompleted) {
          loginCompleter.complete(false);
        }
      });

      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: _getRedirectUrl(),
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw Exception('카카오 OAuth 플로우 시작 실패');
      }

      _logInfo('✅ 카카오 OAuth 요청 성공, 인증 완료 대기 중...');

      return await loginCompleter.future;

    } catch (error) {
      _logError('카카오 로그인 실패: $error');
      if (!loginCompleter.isCompleted) {
        loginCompleter.complete(false);
      }
      throw Exception('카카오 로그인 중 오류가 발생했습니다: ${error.toString()}');
    } finally {
      authSubscription?.cancel();
      timeoutTimer?.cancel();
    }
  }

  /// 🔧 수정된 구글 소셜 로그인
  Future<bool> _signInWithGoogleFixed(Duration timeout) async {
    _logInfo('🚀 구글 로그인 시작 (실제 완료까지 대기)');

    final Completer<bool> loginCompleter = Completer<bool>();
    StreamSubscription<AuthState>? authSubscription;
    Timer? timeoutTimer;

    try {
      final initialUser = SupabaseService.instance.auth.currentUser;

      authSubscription = SupabaseService.instance.auth.onAuthStateChange.listen(
            (AuthState data) async {
          final event = data.event;
          final session = data.session;
          final user = session?.user;

          _logInfo('🔐 Google Auth Event 수신: $event');

          if (event == AuthChangeEvent.signedIn &&
              session != null &&
              user != null &&
              user.id != initialUser?.id) {

            _logInfo('🎉 구글 로그인 성공: ${user.email}');

            _syncProfileSafely();

            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(true);
            }
          }
          else if (event == AuthChangeEvent.signedOut && initialUser == null) {
            _logError('❌ 구글 로그인 실패');
            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(false);
            }
          }
        },
        onError: (error) {
          _logError('구글 Auth 리스너 에러: $error');
          if (!loginCompleter.isCompleted) {
            loginCompleter.completeError(error);
          }
        },
      );

      timeoutTimer = Timer(timeout, () {
        _logError('⏰ 구글 로그인 타임아웃');
        if (!loginCompleter.isCompleted) {
          loginCompleter.complete(false);
        }
      });

      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _getRedirectUrl(),
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw Exception('구글 OAuth 플로우 시작 실패');
      }

      _logInfo('✅ 구글 OAuth 요청 성공, 인증 완료 대기 중...');

      return await loginCompleter.future;

    } catch (error) {
      _logError('구글 로그인 실패: $error');
      if (!loginCompleter.isCompleted) {
        loginCompleter.complete(false);
      }
      throw Exception('구글 로그인 중 오류가 발생했습니다: ${error.toString()}');
    } finally {
      authSubscription?.cancel();
      timeoutTimer?.cancel();
    }
  }

  /// 🔧 수정된 애플 소셜 로그인
  Future<bool> _signInWithAppleFixed(Duration timeout) async {
    _logInfo('🚀 애플 로그인 시작 (실제 완료까지 대기)');

    final Completer<bool> loginCompleter = Completer<bool>();
    StreamSubscription<AuthState>? authSubscription;
    Timer? timeoutTimer;

    try {
      final initialUser = SupabaseService.instance.auth.currentUser;

      authSubscription = SupabaseService.instance.auth.onAuthStateChange.listen(
            (AuthState data) async {
          final event = data.event;
          final session = data.session;
          final user = session?.user;

          _logInfo('🔐 Apple Auth Event 수신: $event');

          if (event == AuthChangeEvent.signedIn &&
              session != null &&
              user != null &&
              user.id != initialUser?.id) {

            _logInfo('🎉 애플 로그인 성공: ${user.email}');

            _syncProfileSafely();

            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(true);
            }
          }
          else if (event == AuthChangeEvent.signedOut && initialUser == null) {
            _logError('❌ 애플 로그인 실패');
            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(false);
            }
          }
        },
        onError: (error) {
          _logError('애플 Auth 리스너 에러: $error');
          if (!loginCompleter.isCompleted) {
            loginCompleter.completeError(error);
          }
        },
      );

      timeoutTimer = Timer(timeout, () {
        _logError('⏰ 애플 로그인 타임아웃');
        if (!loginCompleter.isCompleted) {
          loginCompleter.complete(false);
        }
      });

      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: _getRedirectUrl(),
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw Exception('애플 OAuth 플로우 시작 실패');
      }

      _logInfo('✅ 애플 OAuth 요청 성공, 인증 완료 대기 중...');

      return await loginCompleter.future;

    } catch (error) {
      _logError('애플 로그인 실패: $error');
      if (!loginCompleter.isCompleted) {
        loginCompleter.complete(false);
      }
      throw Exception('애플 로그인 중 오류가 발생했습니다: ${error.toString()}');
    } finally {
      authSubscription?.cancel();
      timeoutTimer?.cancel();
    }
  }

  /// 🔧 수정된 디스코드 소셜 로그인
  Future<bool> _signInWithDiscordFixed(Duration timeout) async {
    _logInfo('🚀 디스코드 로그인 시작 (실제 완료까지 대기)');

    final Completer<bool> loginCompleter = Completer<bool>();
    StreamSubscription<AuthState>? authSubscription;
    Timer? timeoutTimer;

    try {
      final initialUser = SupabaseService.instance.auth.currentUser;

      authSubscription = SupabaseService.instance.auth.onAuthStateChange.listen(
            (AuthState data) {
          final event = data.event;
          final session = data.session;
          final user = session?.user;

          _logInfo('🔐 Discord Auth Event 수신: $event');

          if (event == AuthChangeEvent.signedIn &&
              session != null &&
              user != null &&
              user.id != initialUser?.id) {

            _logInfo('🎉 디스코드 로그인 성공: ${user.email}');

            _syncProfileSafely();

            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(true);
            }
          }
          else if (event == AuthChangeEvent.signedOut && initialUser == null) {
            _logError('❌ 디스코드 로그인 실패');
            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(false);
            }
          }
        },
        onError: (error) {
          _logError('디스코드 Auth 리스너 에러: $error');
          if (!loginCompleter.isCompleted) {
            loginCompleter.completeError(error);
          }
        },
      );

      timeoutTimer = Timer(timeout, () {
        _logError('⏰ 디스코드 로그인 타임아웃');
        if (!loginCompleter.isCompleted) {
          loginCompleter.complete(false);
        }
      });

      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.discord,
        redirectTo: _getRedirectUrl(),
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw Exception('디스코드 OAuth 플로우 시작 실패');
      }

      _logInfo('✅ 디스코드 OAuth 요청 성공, 인증 완료 대기 중...');

      return await loginCompleter.future;

    } catch (error) {
      _logError('디스코드 로그인 실패: $error');
      if (!loginCompleter.isCompleted) {
        loginCompleter.complete(false);
      }
      throw Exception('디스코드 로그인 중 오류가 발생했습니다: ${error.toString()}');
    } finally {
      authSubscription?.cancel();
      timeoutTimer?.cancel();
    }
  }

  // ==================== 프로필 동기화 로직 (camelCase 수정) ====================

  /// 소셜 로그인 후 사용자 프로필 동기화 (중복 방지 강화)
  Future<void> syncSocialUserProfile() async {
    try {
      final currentUser = SupabaseService.instance.auth.currentUser;
      if (currentUser == null) {
        _logWarning('현재 사용자 정보가 없습니다.');
        return;
      }

      _logInfo('소셜 로그인 사용자 프로필 동기화 시작: ${currentUser.email}');

      // 이미 UserProvider에서 처리된 경우 건너뛰기
      if (daylitUser != null && daylitUser!.uid == currentUser.id) {
        _logInfo('UserProvider에서 이미 프로필이 로드됨 - 동기화 건너뛰기');
        return;
      }

      // 기존 프로필 확인
      final existingProfile = await SupabaseService.instance
          .from('user_profiles')
          .select()
          .eq('uid', currentUser.id)
          .maybeSingle();

      if (existingProfile != null && existingProfile.isNotEmpty) {
        await _updateExistingSocialProfile(existingProfile, currentUser);
        _logInfo('기존 사용자 프로필 업데이트 완료');

        // 로컬 모델 업데이트 (UserProvider와 동기화)
        _updateLocalUserModel(existingProfile);
      } else {
        // 프로필이 없는 경우에만 생성 (중복 체크 강화)
        await _createNewSocialProfileSafe(currentUser);
        _logInfo('신규 사용자 프로필 생성 완료');
      }

      _logInfo('소셜 프로필 동기화 성공');

    } catch (error) {
      _logError('소셜 프로필 동기화 실패: $error');
      // 에러를 다시 throw하지 않음 - UserProvider의 백업 로직이 작동하도록 함
      _logWarning('UserProvider의 기본 프로필 로직으로 대체됩니다.');
    }
  }

  /// 안전한 신규 소셜 사용자 프로필 생성 (camelCase + 중복 체크 강화)
  Future<void> _createNewSocialProfileSafe(User currentUser) async {
    try {
      // 프로필 생성 직전 한 번 더 중복 체크
      final doubleCheckProfile = await SupabaseService.instance
          .from('user_profiles')
          .select('uid')
          .eq('uid', currentUser.id)
          .maybeSingle();

      if (doubleCheckProfile != null) {
        _logWarning('프로필이 이미 존재합니다. 생성을 건너뜁니다: ${currentUser.id}');

        // 기존 프로필 전체 정보를 다시 로드해서 업데이트
        final fullProfile = await SupabaseService.instance
            .from('user_profiles')
            .select()
            .eq('uid', currentUser.id)
            .single();

        await _updateExistingSocialProfile(fullProfile, currentUser);
        _updateLocalUserModel(fullProfile);
        return;
      }

      final now = DateTime.now();
      final email = currentUser.email ?? '';
      final nickname = _generateNicknameFromEmail(email);
      final socialType = _detectSocialTypeFromProvider(currentUser);
      final profileUrl = _extractProfileImageUrl(currentUser);

      // ⚠️ 수정: Supabase는 camelCase로 반환하므로 camelCase 사용
      final profileData = {
        'uid': currentUser.id,
        'id': nickname,
        'socialType': socialType,        // social_type → socialType
        'email': email,
        'profileUrl': profileUrl,        // profile_url → profileUrl
        'lastLogin': now.toIso8601String(),  // last_login → lastLogin
        'createAt': now.toIso8601String(),   // create_at → createAt
        'level': 1,
        'gender': null,
      };

      // insert 후 select로 생성된 데이터 확인
      final insertedData = await SupabaseService.instance
          .from('user_profiles')
          .insert(profileData)
          .select()
          .single();

      _logInfo('신규 소셜 프로필 생성 성공: ${nickname}');

      // 로컬 모델 업데이트
      _updateLocalUserModel(insertedData);

    } catch (e) {
      // 중복 키 에러인 경우 특별 처리
      if (e.toString().contains('duplicate key value violates unique constraint')) {
        _logWarning('프로필이 이미 존재합니다 (중복 키 에러): ${currentUser.id}');

        try {
          // 기존 프로필을 로드해서 업데이트
          final existingProfile = await SupabaseService.instance
              .from('user_profiles')
              .select()
              .eq('uid', currentUser.id)
              .single();

          await _updateExistingSocialProfile(existingProfile, currentUser);
          _updateLocalUserModel(existingProfile);

          _logInfo('기존 프로필 재로드 및 업데이트 완료');
        } catch (loadError) {
          _logError('기존 프로필 재로드 실패: $loadError');
          throw loadError;
        }
      } else {
        _logError('신규 소셜 프로필 생성 실패: $e');
        throw e;
      }
    }
  }

  /// 기존 소셜 사용자 프로필 업데이트 (camelCase 수정)
  Future<void> _updateExistingSocialProfile(Map<String, dynamic> existingProfile, User currentUser) async {
    try {
      final now = DateTime.now();
      final profileUrl = _extractProfileImageUrl(currentUser);

      // ⚠️ 수정: Supabase는 camelCase로 반환하므로 camelCase 사용
      final updateData = {
        'lastLogin': now.toIso8601String(),  // last_login → lastLogin
        'email': currentUser.email ?? existingProfile['email'],
      };

      // 프로필 URL이 있고 기존 것과 다른 경우에만 업데이트
      if (profileUrl != null && profileUrl != existingProfile['profileUrl']) {  // profile_url → profileUrl
        updateData['profileUrl'] = profileUrl;  // profile_url → profileUrl
      }

      await SupabaseService.instance
          .from('user_profiles')
          .update(updateData)
          .eq('uid', currentUser.id);

      _logInfo('소셜 프로필 업데이트 완료');
    } catch (e) {
      _logError('소셜 프로필 업데이트 실패: $e');
      throw e;
    }
  }

  /// 로컬 UserModel 업데이트 (UserProvider와 동기화)
  void _updateLocalUserModel(Map<String, dynamic> profileData) {
    try {
      // daylitUser가 없거나 다른 사용자인 경우에만 업데이트
      if (daylitUser == null || daylitUser!.uid != profileData['uid']) {
        // ⚠️ Supabase 데이터가 이미 camelCase이므로 변환 불필요
        daylitUser = UserModel.fromJson(profileData);

        // ⚠️ 주의: notifyListeners() 호출하지 않음
        // UserProvider의 AuthState 리스너에서 처리하도록 함
        _logInfo('로컬 사용자 모델 업데이트: ${daylitUser!.id} (notify 생략)');
      }
    } catch (e) {
      _logError('로컬 사용자 모델 업데이트 실패: $e');
    }
  }

  /// 안전한 프로필 동기화 (비동기 실행)
  void _syncProfileSafely() {
    // UserProvider 로직이 완료된 후 실행되도록 충분한 지연
    Timer(const Duration(milliseconds: 1000), () async {
      try {
        // UserProvider에서 이미 처리했는지 확인
        if (daylitUser != null) {
          _logInfo('UserProvider에서 이미 프로필 처리 완료 - 동기화 생략');
          return;
        }

        await syncSocialUserProfile();
      } catch (e) {
        _logError('백그라운드 프로필 동기화 실패: $e');
        // 에러를 삼킴 - UserProvider의 백업 로직에 의존
      }
    });
  }

  // ==================== 기존 헬퍼 메서드들 (유지) ====================

  /// 리디렉트 URL 생성
  String _getRedirectUrl() {
    return 'io.daylit.app://login-callback/';
  }

  /// 이메일에서 닉네임 생성
  String _generateNicknameFromEmail(String email) {
    if (email.isEmpty) return 'user${DateTime.now().millisecondsSinceEpoch}';

    final username = email.split('@').first;
    final cleanUsername = username
        .replaceAll(RegExp(r'[^\w\d]'), '')
        .toLowerCase();

    return cleanUsername.isNotEmpty
        ? cleanUsername.substring(0, cleanUsername.length > 20 ? 20 : cleanUsername.length)
        : 'user${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 소셜 로그인 제공자 감지 (카카오 포함)
  String _detectSocialTypeFromProvider(User currentUser) {
    final identities = currentUser.identities;
    if (identities != null && identities.isNotEmpty) {
      final provider = identities.first.provider.toLowerCase() ?? '';
      switch (provider) {
        case 'google': return 'google';
        case 'apple': return 'apple';
        case 'discord': return 'discord';
        case 'kakao': return 'kakao';
        default: return 'google';
      }
    }

    final providers = currentUser.appMetadata['providers'] as List<dynamic>?;
    if (providers != null && providers.isNotEmpty) {
      final provider = providers.first.toString().toLowerCase();
      switch (provider) {
        case 'google': return 'google';
        case 'apple': return 'apple';
        case 'discord': return 'discord';
        case 'kakao': return 'kakao';
        default: return 'google';
      }
    }

    return 'google';
  }

  /// 프로필 이미지 URL 추출
  String? _extractProfileImageUrl(User currentUser) {
    // userMetadata에서 프로필 이미지 URL 추출
    final metadata = currentUser.userMetadata;

    // 일반적인 프로필 이미지 키들
    final imageKeys = ['avatar_url', 'picture', 'profile_image', 'avatar'];

    for (final key in imageKeys) {
      final url = metadata?[key];
      if (url is String && url.isNotEmpty) {
        return url;
      }
    }

    return null;
  }

  // ==================== 로깅 메서드들 ====================

  void _logInfo(String message) {
    if (kDebugMode) {
      debugPrint('🔵 [SocialLogin] $message');
    }
  }

  void _logWarning(String message) {
    if (kDebugMode) {
      debugPrint('🟡 [SocialLogin] $message');
    }
  }

  void _logError(String message) {
    if (kDebugMode) {
      debugPrint('🔴 [SocialLogin] $message');
    }
  }

  // ==================== 편의 메서드들 ====================

  /// 현재 로그인 상태 즉시 확인
  bool get isCurrentlyLoggedIn {
    final user = SupabaseService.instance.auth.currentUser;
    final session = SupabaseService.instance.auth.currentSession;

    if (user == null || session == null) return false;

    // 세션 만료 체크
    if (session.expiresAt != null) {
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
      if (DateTime.now().isAfter(expiryDate)) {
        return false;
      }
    }

    return true;
  }

  /// 현재 로그인 상태 정보
  String get currentLoginInfo {
    final user = SupabaseService.instance.auth.currentUser;

    if (user == null) return '로그인되지 않음';

    final providers = user.appMetadata['providers'] as List<dynamic>?;
    final provider = providers?.isNotEmpty == true ? providers!.first : 'unknown';

    return '로그인됨: ${user.email ?? user.id} ($provider)';
  }

  /// 빠른 카카오 로그인 (1분 타임아웃)
  Future<bool> quickSignInWithKakao() async {
    return await signInWithSocial(
      socialType: Social.kakao,
      timeout: const Duration(minutes: 1),
    );
  }
}
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../provider/User_Provider.dart';
import '../../service/Supabase_Service.dart';
import '../../util/Daylit_Social.dart';

/// 수정된 소셜 로그인 확장 (2024-2025 최신 방법)
///
/// ✅ 실제 AuthState 이벤트까지 기다리는 올바른 방식
/// ✅ OAuth 시작 ≠ 로그인 성공을 구분
/// ✅ 타임아웃 처리로 무한 대기 방지
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

    // 로그인 결과를 기다릴 Completer 생성
    final Completer<bool> loginCompleter = Completer<bool>();
    StreamSubscription<AuthState>? authSubscription;
    Timer? timeoutTimer;

    try {
      // 현재 세션 상태 저장 (중복 이벤트 방지용)
      final initialUser = SupabaseService.instance.auth.currentUser;
      _logInfo('초기 사용자 상태: ${initialUser?.email ?? "없음"}');

      // ✅ AuthStateChange 리스너 설정 (핵심!)
      authSubscription = SupabaseService.instance.auth.onAuthStateChange.listen(
            (AuthState data) {
          final event = data.event;
          final session = data.session;
          final user = session?.user;

          _logInfo('🔐 Kakao Auth Event 수신: $event');
          _logInfo('  - Session: ${session != null}');
          _logInfo('  - User: ${user?.email ?? "없음"}');

          // ✅ 로그인 성공 이벤트 처리
          if (event == AuthChangeEvent.signedIn &&
              session != null &&
              user != null &&
              user.id != initialUser?.id) {  // 새로운 사용자인지 확인

            _logInfo('🎉 카카오 로그인 성공: ${user.email}');

            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(true);
            }
          }

          // ✅ 로그아웃 이벤트 처리 (로그인 실패 의미)
          else if (event == AuthChangeEvent.signedOut &&
              initialUser == null) {  // 원래 로그인 상태가 아니었다면

            _logError('❌ 카카오 로그인 실패 (로그아웃 이벤트)');

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

      // ✅ 타임아웃 타이머 설정
      timeoutTimer = Timer(timeout, () {
        _logError('⏰ 카카오 로그인 타임아웃 (${timeout.inMinutes}분)');
        if (!loginCompleter.isCompleted) {
          loginCompleter.complete(false);
        }
      });

      // ✅ OAuth 플로우 시작 (기존과 동일)
      _logInfo('🌐 카카오 OAuth 플로우 시작...');

      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: _getRedirectUrl(),
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!response) {
        throw Exception('카카오 OAuth 플로우 시작 실패');
      }

      _logInfo('✅ 카카오 OAuth 요청 성공');
      _logInfo('⏳ 사용자 인증 완료 대기 중... (최대 ${timeout.inMinutes}분)');

      // 🔑 핵심: 실제 로그인 완료까지 대기!
      final result = await loginCompleter.future;

      _logInfo(result
          ? '🎉 카카오 로그인 최종 성공!'
          : '💥 카카오 로그인 최종 실패');

      return result;

    } catch (error) {
      _logError('카카오 로그인 실패: $error');

      if (!loginCompleter.isCompleted) {
        loginCompleter.complete(false);
      }

      throw Exception('카카오 로그인 중 오류가 발생했습니다: ${error.toString()}');

    } finally {
      // ✅ 리소스 정리
      authSubscription?.cancel();
      timeoutTimer?.cancel();
      _logInfo('🧹 카카오 로그인 리소스 정리 완료');
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
            (AuthState data) {
          final event = data.event;
          final session = data.session;
          final user = session?.user;

          _logInfo('🔐 Google Auth Event 수신: $event');

          if (event == AuthChangeEvent.signedIn &&
              session != null &&
              user != null &&
              user.id != initialUser?.id) {

            _logInfo('🎉 구글 로그인 성공: ${user.email}');
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
            (AuthState data) {
          final event = data.event;
          final session = data.session;
          final user = session?.user;

          _logInfo('🔐 Apple Auth Event 수신: $event');

          if (event == AuthChangeEvent.signedIn &&
              session != null &&
              user != null &&
              user.id != initialUser?.id) {

            _logInfo('🎉 애플 로그인 성공: ${user.email ?? user.id}');
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

  // ==================== 기존 헬퍼 메서드들 (유지) ====================

  /// 리디렉트 URL 생성
  String _getRedirectUrl() {
    return 'io.daylit.app://login-callback/';
  }

  /// 소셜 로그인 후 사용자 프로필 동기화
  Future<void> syncSocialUserProfile() async {
    try {
      final currentUser = SupabaseService.instance.auth.currentUser;
      if (currentUser == null) {
        _logWarning('현재 사용자 정보가 없습니다.');
        return;
      }

      _logInfo('소셜 로그인 사용자 프로필 동기화 시작: ${currentUser.email}');

      // 기존 프로필 동기화 로직 (변경 없음)
      final existingProfile = await SupabaseService.instance
          .from('user_profiles')
          .select()
          .eq('uid', currentUser.id)
          .maybeSingle();

      if (existingProfile != null) {
        await _updateExistingSocialProfile(existingProfile, currentUser);
        _logInfo('기존 사용자 프로필 업데이트 완료');
      } else {
        await _createNewSocialProfile(currentUser);
        _logInfo('신규 사용자 프로필 생성 완료');
      }

      _logInfo('소셜 프로필 동기화 성공');

    } catch (error) {
      _logError('소셜 프로필 동기화 실패: $error');
      throw Exception('사용자 프로필 동기화에 실패했습니다: $error');
    }
  }

  /// 신규 소셜 사용자 프로필 생성
  Future<void> _createNewSocialProfile(User currentUser) async {
    final now = DateTime.now();
    final email = currentUser.email ?? '';
    final nickname = _generateNicknameFromEmail(email);
    final socialType = _detectSocialTypeFromProvider(currentUser);
    final profileUrl = _extractProfileImageUrl(currentUser);

    final profileData = {
      'uid': currentUser.id,
      'id': nickname,
      'social_type': socialType,
      'email': email,
      'profile_url': profileUrl,
      'last_login': now.toIso8601String(),
      'create_at': now.toIso8601String(),
      'level': 1,
      'gender': null,
    };

    await SupabaseService.instance
        .from('user_profiles')
        .insert(profileData);
  }

  /// 기존 소셜 사용자 프로필 업데이트
  Future<void> _updateExistingSocialProfile(Map<String, dynamic> existingProfile, User currentUser) async {
    final now = DateTime.now();
    final profileUrl = _extractProfileImageUrl(currentUser);

    final updateData = {
      'last_login': now.toIso8601String(),
      'profile_url': profileUrl ?? existingProfile['profile_url'],
      'email': currentUser.email ?? existingProfile['email'],
    };

    await SupabaseService.instance
        .from('user_profiles')
        .update(updateData)
        .eq('uid', currentUser.id);
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

  /// 소셜 로그인 제공자 감지
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

    final providers = currentUser.appMetadata?['providers'] as List<dynamic>?;
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

    return '로그인됨: ${user.email ?? user.id} (${provider})';
  }

  /// 빠른 카카오 로그인 (1분 타임아웃)
  Future<bool> quickSignInWithKakao() async {
    return await signInWithSocial(
      socialType: Social.kakao,
      timeout: const Duration(minutes: 1),
    );
  }
}
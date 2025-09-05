import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../provider/User_Provider.dart';
import '../../service/Supabase_Service.dart';
import '../../util/Daylit_Social.dart';

/// 소셜 로그인 확장된 UserProvider
///
/// Supabase OAuth를 통한 소셜 로그인 기능을 제공합니다.
/// Google, Apple, Discord, Kakao 모두 지원 (Supabase 기본 제공)
extension SocialLoginExtension on UserProvider {

  // ==================== 소셜 로그인 메인 메서드 ====================

  /// 소셜 로그인 실행
  ///
  /// [socialType]: 로그인할 소셜 플랫폼 타입
  /// [context]: BuildContext (리다이렉트용)
  ///
  /// Returns: 로그인 성공 여부
  ///
  /// 참고: 로딩 상태 관리는 UserProvider 클래스에서 별도로 구현하세요.
  Future<bool> signInWithSocial({
    required Social socialType,
    BuildContext? context,
  }) async {
    try {
      switch (socialType) {
        case Social.google:
          return await _signInWithGoogle();
        case Social.apple:
          return await _signInWithApple();
        case Social.discord:
          return await _signInWithDiscord();
        case Social.kakao:
          return await _signInWithKakao();
      }
    } catch (error) {
      _logError('소셜 로그인 실패: $error');
      rethrow;
    }
  }

  // ==================== 개별 소셜 로그인 구현 ====================

  /// Google 소셜 로그인
  Future<bool> _signInWithGoogle() async {
    try {
      _logInfo('Google 로그인 시작');

      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _getRedirectUrl(),
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (response) {
        _logInfo('Google OAuth 요청 성공');
        return true;
      } else {
        throw Exception('Google 로그인에 실패했습니다.');
      }
    } catch (error) {
      _logError('Google 로그인 실패: $error');
      throw Exception('Google 로그인 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /// Apple 소셜 로그인
  Future<bool> _signInWithApple() async {
    try {
      _logInfo('Apple 로그인 시작');

      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: _getRedirectUrl(),
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (response) {
        _logInfo('Apple OAuth 요청 성공');
        return true;
      } else {
        throw Exception('Apple 로그인에 실패했습니다.');
      }
    } catch (error) {
      _logError('Apple 로그인 실패: $error');
      throw Exception('Apple 로그인 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /// Discord 소셜 로그인
  Future<bool> _signInWithDiscord() async {
    try {
      _logInfo('Discord 로그인 시작');

      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.discord,
        redirectTo: _getRedirectUrl(),
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (response) {
        _logInfo('Discord OAuth 요청 성공');
        return true;
      } else {
        throw Exception('Discord 로그인에 실패했습니다.');
      }
    } catch (error) {
      _logError('Discord 로그인 실패: $error');
      throw Exception('Discord 로그인 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /// Kakao 소셜 로그인
  Future<bool> _signInWithKakao() async {
    try {
      _logInfo('Kakao 로그인 시작');

      final response = await SupabaseService.instance.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: _getRedirectUrl(),
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (response) {
        _logInfo('Kakao OAuth 요청 성공');
        return true;
      } else {
        throw Exception('Kakao 로그인에 실패했습니다.');
      }
    } catch (error) {
      _logError('Kakao 로그인 실패: $error');
      throw Exception('Kakao 로그인 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  // ==================== 헬퍼 메서드들 ====================

  /// 리다이렉트 URL 생성
  String _getRedirectUrl() {
    // Deep Link URL 반환 (앱으로 돌아오기 위한 URL)
    return 'io.daylit.app://login-callback/';
  }

  /// 소셜 로그인 후 사용자 프로필 동기화
  ///
  /// OAuth 로그인 성공 후 자동으로 호출되는 메서드
  /// (AuthStateListener에서 signedIn 이벤트 시 실행)
  Future<void> syncSocialUserProfile() async {
    try {
      final currentUser = SupabaseService.instance.auth.currentUser;
      if (currentUser == null) {
        _logWarning('현재 사용자 정보가 없습니다.');
        return;
      }

      _logInfo('소셜 로그인 사용자 프로필 동기화 시작: ${currentUser.email}');

      // Supabase user_profiles 테이블에서 기존 프로필 조회
      final existingProfile = await SupabaseService.instance
          .from('user_profiles')
          .select()
          .eq('uid', currentUser.id)
          .maybeSingle();

      if (existingProfile != null) {
        // 기존 사용자 - 프로필 업데이트
        await _updateExistingSocialProfile(existingProfile, currentUser);
        _logInfo('기존 사용자 프로필 업데이트 완료');
      } else {
        // 신규 사용자 - 프로필 생성
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

    _logInfo('신규 프로필 생성: $email, 소셜타입: $socialType');

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

    _logInfo('기존 프로필 업데이트: ${currentUser.email}');

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
    // 특수문자 제거 및 길이 제한
    final cleanUsername = username
        .replaceAll(RegExp(r'[^\w\d]'), '')
        .toLowerCase();

    return cleanUsername.isNotEmpty
        ? cleanUsername.substring(0, cleanUsername.length > 20 ? 20 : cleanUsername.length)
        : 'user${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 소셜 로그인 제공자 감지
  String _detectSocialTypeFromProvider(User currentUser) {
    // OAuth Provider 정보에서 감지
    final identities = currentUser.identities;
    if (identities != null && identities.isNotEmpty) {
      final provider = identities.first.provider.toLowerCase() ?? '';
      _logInfo('Provider 감지 (identities): $provider');
      switch (provider) {
        case 'google': return 'google';
        case 'apple': return 'apple';
        case 'discord': return 'discord';
        case 'kakao': return 'kakao';
        default: return 'google';
      }
    }

    // 앱 메타데이터에서 감지
    final providers = currentUser.appMetadata?['providers'] as List<dynamic>?;
    if (providers != null && providers.isNotEmpty) {
      final provider = providers.first.toString().toLowerCase();
      _logInfo('Provider 감지 (appMetadata): $provider');
      switch (provider) {
        case 'google': return 'google';
        case 'apple': return 'apple';
        case 'discord': return 'discord';
        case 'kakao': return 'kakao';
        default: return 'google';
      }
    }

    _logInfo('Provider 감지 실패, 기본값(google) 사용');
    return 'google'; // 기본값
  }

  /// 프로필 이미지 URL 추출
  String? _extractProfileImageUrl(User currentUser) {
    // 사용자 메타데이터에서 프로필 이미지 추출
    final userMetadata = currentUser.userMetadata;

    if (userMetadata == null) {
      _logInfo('사용자 메타데이터가 없습니다.');
      return null;
    }

    // 각 소셜별로 다른 필드명 사용
    final profileImageFields = [
      'avatar_url',      // Google, Discord
      'picture',         // Google
      'photo',           // Apple (때로는 제공되지 않음)
      'profile_image',   // Kakao
      'thumbnail_image', // Kakao
      'profile_image_url', // Kakao 추가
    ];

    for (final field in profileImageFields) {
      final imageUrl = userMetadata[field];
      if (imageUrl != null && imageUrl is String && imageUrl.isNotEmpty) {
        _logInfo('프로필 이미지 발견: $field = $imageUrl');
        return imageUrl;
      }
    }

    _logInfo('프로필 이미지를 찾을 수 없습니다. 메타데이터: $userMetadata');
    return null;
  }

  // ==================== 유틸리티 메서드들 ====================

  /// 로딩 상태 관리 안내
  ///
  /// 참고: Extension에서는 UserProvider의 private 필드에 접근할 수 없으므로,
  /// 로딩 상태 관리는 UserProvider 클래스 내부에서 다음과 같이 구현하세요:
  ///
  /// ```dart
  /// Future<bool> signInWithSocialWrapper(Social socialType) async {
  ///   _setLoading(true);
  ///   _clearError();
  ///
  ///   try {
  ///     final result = await signInWithSocial(socialType: socialType);
  ///     if (result) {
  ///       await syncSocialUserProfile();
  ///     }
  ///     return result;
  ///   } catch (error) {
  ///     _setError(error.toString());
  ///     rethrow;
  ///   } finally {
  ///     _setLoading(false);
  ///   }
  /// }
  /// ```

  // ==================== 로그 메서드들 ====================

  void _logInfo(String message) {
    print('📱 [SocialLogin] $message');
  }

  void _logWarning(String message) {
    print('⚠️ [SocialLogin] $message');
  }

  void _logError(String message) {
    print('❌ [SocialLogin] $message');
  }
}

// ==================== 소셜 로그인 상태 확장 ====================

/// 소셜 로그인 관련 상태 확장
extension SocialLoginStateExtension on UserProvider {

  /// 현재 소셜 로그인 타입 반환
  Social? get currentSocialType {
    if (!isLoggedIn) return null;
    return daylitUser?.socialType;
  }

  /// 소셜 로그인 사용자인지 확인
  bool get isSocialLogin {
    return currentSocialType != null;
  }

  /// 특정 소셜 타입으로 로그인했는지 확인
  bool isLoggedInWith(Social socialType) {
    return currentSocialType == socialType;
  }

  /// 소셜 로그인 상태 정보
  Map<String, dynamic> get socialLoginInfo {
    final currentUser = SupabaseService.instance.auth.currentUser;
    return {
      'isSocialLogin': isSocialLogin,
      'socialType': currentSocialType?.value,
      'hasProfileImage': profileImageUrl != null,
      'provider': currentUser?.identities?.first.provider,
      'userEmail': currentUser?.email,
      'userId': currentUser?.id,
    };
  }

  /// 현재 Supabase 사용자 정보 (디버깅용)
  User? get currentSupabaseUser {
    return SupabaseService.instance.auth.currentUser;
  }
}
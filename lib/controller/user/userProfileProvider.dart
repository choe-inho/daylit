// pubspec.yaml에 추가할 의존성
/*
dependencies:
  supabase_flutter: ^2.5.0
  flutter_riverpod: ^2.4.9
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== 사용자 모델 ====================

class UserProfile {
  final String id;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final SubscriptionType subscriptionType;
  final int aiGenerationCount;
  final DateTime aiResetDate;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    this.nickname,
    this.avatarUrl,
    this.subscriptionType = SubscriptionType.free,
    this.aiGenerationCount = 0,
    required this.aiResetDate,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      avatarUrl: json['avatar_url'],
      subscriptionType: SubscriptionType.values.firstWhere(
            (e) => e.name == json['subscription_type'],
        orElse: () => SubscriptionType.free,
      ),
      aiGenerationCount: json['ai_generation_count'] ?? 0,
      aiResetDate: DateTime.parse(json['ai_reset_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'subscription_type': subscriptionType.name,
      'ai_generation_count': aiGenerationCount,
      'ai_reset_date': aiResetDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? nickname,
    String? avatarUrl,
    SubscriptionType? subscriptionType,
    int? aiGenerationCount,
    DateTime? aiResetDate,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      aiGenerationCount: aiGenerationCount ?? this.aiGenerationCount,
      aiResetDate: aiResetDate ?? this.aiResetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 프리미엄 여부 확인
  bool get isPremium => subscriptionType == SubscriptionType.premium;

  // 이번 달 AI 사용 가능 여부
  bool get canUseAI {
    final now = DateTime.now();

    // 프리미엄은 무제한
    if (isPremium) return true;

    // 새 달이면 사용 가능
    if (aiResetDate.month != now.month || aiResetDate.year != now.year) {
      return true;
    }

    // 무료는 월 3회 제한
    return aiGenerationCount < 3;
  }

  // 남은 AI 사용 횟수
  int get remainingAICount {
    if (isPremium) return -1; // 무제한

    final now = DateTime.now();
    if (aiResetDate.month != now.month || aiResetDate.year != now.year) {
      return 3; // 새 달이면 3회
    }

    return (3 - aiGenerationCount).clamp(0, 3);
  }
}

enum SubscriptionType { free, premium }

// ==================== 인증 상태 모델 ====================

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final UserProfile? userProfile;
  final String? errorMessage;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.userProfile,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    UserProfile? userProfile,
    String? errorMessage,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage,
    );
  }
}

// ==================== Supabase 인증 서비스 ====================

class SupabaseAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // 소셜 로그인 (Google)
  static Future<AuthResponse> signInWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'your-app://auth-callback',
    );
  }

  // 소셜 로그인 (Apple)
  static Future<AuthResponse> signInWithApple() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'your-app://auth-callback',
    );
  }

  // 로그아웃
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 현재 사용자 가져오기
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // 사용자 프로필 생성 (자동 회원가입)
  static Future<UserProfile> createUserProfile(User user) async {
    final now = DateTime.now();
    final profile = UserProfile(
      id: user.id,
      email: user.email ?? '',
      nickname: user.userMetadata?['full_name'] ?? '사용자',
      avatarUrl: user.userMetadata?['avatar_url'],
      subscriptionType: SubscriptionType.free,
      aiGenerationCount: 0,
      aiResetDate: DateTime(now.year, now.month, 1), // 이번 달 1일
      createdAt: now,
    );

    await _supabase.from('profiles').insert(profile.toJson());
    return profile;
  }

  // 사용자 프로필 가져오기
  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // 사용자 프로필 업데이트
  static Future<void> updateUserProfile(UserProfile profile) async {
    await _supabase
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }

  // AI 사용 횟수 증가
  static Future<void> incrementAIUsage(String userId) async {
    final profile = await getUserProfile(userId);
    if (profile == null) return;

    final now = DateTime.now();

    // 새 달이면 카운트 리셋
    if (profile.aiResetDate.month != now.month ||
        profile.aiResetDate.year != now.year) {
      await updateUserProfile(profile.copyWith(
        aiGenerationCount: 1,
        aiResetDate: DateTime(now.year, now.month, 1),
      ));
    } else {
      // 기존 달이면 카운트 증가
      await updateUserProfile(profile.copyWith(
        aiGenerationCount: profile.aiGenerationCount + 1,
      ));
    }
  }

  // 구독 타입 업데이트
  static Future<void> updateSubscription(String userId, SubscriptionType type) async {
    await _supabase
        .from('profiles')
        .update({'subscription_type': type.name})
        .eq('id', userId);
  }
}

// ==================== 인증 Provider ====================

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initialize();
  }

  // 초기화 - 기존 로그인 상태 확인
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = SupabaseAuthService.getCurrentUser();
      if (user != null) {
        await _loadUserProfile(user.id);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 소셜 로그인
  Future<void> socialLogin(String provider) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      AuthResponse response;

      switch (provider.toLowerCase()) {
        case 'google':
          response = await SupabaseAuthService.signInWithGoogle();
          break;
        case 'apple':
          response = await SupabaseAuthService.signInWithApple();
          break;
        default:
          throw Exception('지원하지 않는 로그인 방식입니다: $provider');
      }

      if (response.user != null) {
        await _handleSuccessfulLogin(response.user!);
      } else {
        throw Exception('로그인에 실패했습니다');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  // 로그인 성공 처리
  Future<void> _handleSuccessfulLogin(User user) async {
    try {
      // 기존 프로필 확인
      UserProfile? profile = await SupabaseAuthService.getUserProfile(user.id);

      // 신규 사용자면 프로필 생성 (자동 회원가입)
      if (profile == null) {
        profile = await SupabaseAuthService.createUserProfile(user);
        print('✅ 새 사용자 프로필 생성: ${profile.email}');
      } else {
        print('✅ 기존 사용자 로그인: ${profile.email}');
      }

      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        userProfile: profile,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '프로필 로딩 중 오류가 발생했습니다: $e',
      );
      rethrow;
    }
  }

  // 사용자 프로필 로드
  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await SupabaseAuthService.getUserProfile(userId);

      if (profile != null) {
        state = state.copyWith(
          isLoggedIn: true,
          isLoading: false,
          userProfile: profile,
        );
      } else {
        // 프로필이 없으면 로그아웃 처리
        await signOut();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 프로필 업데이트
  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      await SupabaseAuthService.updateUserProfile(updatedProfile);
      state = state.copyWith(userProfile: updatedProfile);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  // AI 사용 처리
  Future<void> useAI() async {
    if (state.userProfile == null) return;

    try {
      await SupabaseAuthService.incrementAIUsage(state.userProfile!.id);

      // 프로필 재로드
      final updatedProfile = await SupabaseAuthService.getUserProfile(
          state.userProfile!.id
      );

      if (updatedProfile != null) {
        state = state.copyWith(userProfile: updatedProfile);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  // 구독 업그레이드
  Future<void> upgradeToPremium() async {
    if (state.userProfile == null) return;

    try {
      await SupabaseAuthService.updateSubscription(
        state.userProfile!.id,
        SubscriptionType.premium,
      );

      final updatedProfile = state.userProfile!.copyWith(
        subscriptionType: SubscriptionType.premium,
      );

      state = state.copyWith(userProfile: updatedProfile);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await SupabaseAuthService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  // 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ==================== Provider 정의 ====================

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// 편의 Provider들
final userProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authProvider).userProfile;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final isPremiumProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.isPremium ?? false;
});

final canUseAIProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.canUseAI ?? false;
});

final remainingAICountProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.remainingAICount ?? 0;
});
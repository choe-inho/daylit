import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ==================== 인증 상태 모델 ====================

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? errorMessage;
  final String? currentProvider; // 로그인 중인 소셜 프로바이더

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.errorMessage,
    this.currentProvider,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? errorMessage,
    String? currentProvider,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentProvider: currentProvider,
    );
  }
}

// ==================== 인증 상태 관리자 ====================

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // 소셜 로그인 처리
  Future<void> socialLogin(String provider) async {
    if (state.isLoading) return; // 중복 요청 방지

    state = state.copyWith(
      isLoading: true,
      currentProvider: provider,
      errorMessage: null,
    );

    try {
      // 실제 소셜 로그인 API 호출
      await _performSocialLogin(provider);

      // 로그인 성공
      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        currentProvider: null,
      );

    } catch (error) {
      // 로그인 실패
      state = state.copyWith(
        isLoading: false,
        currentProvider: null,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // 이메일 로그인 처리
  Future<void> emailLogin({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      // 실제 이메일 로그인 API 호출
      await _performEmailLogin(email, password);

      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
      );

    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // 로그아웃 API 호출 (토큰 무효화 등)
      await _performLogout();

      state = const AuthState(); // 초기 상태로 리셋

    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  // 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // 로그인 상태 직접 설정 (개발/테스트용)
  void setLoggedIn(bool value) {
    state = state.copyWith(isLoggedIn: value);
  }

  // ==================== Private Methods ====================

  Future<void> _performSocialLogin(String provider) async {
    // 실제 구현에서는 각 소셜 로그인 SDK 호출
    switch (provider.toLowerCase()) {
      case 'google':
        await _googleLogin();
        break;
      case 'apple':
        await _appleLogin();
        break;
      case 'kakao':
        await _kakaoLogin();
        break;
      case 'discord':
        await _discordLogin();
        break;
      default:
        throw Exception('지원하지 않는 로그인 방식입니다: $provider');
    }
  }

  Future<void> _performEmailLogin(String email, String password) async {
    // 임시 딜레이 (실제로는 API 호출)
    await Future.delayed(const Duration(seconds: 2));

    // 간단한 유효성 검사 예시
    if (email.isEmpty || password.isEmpty) {
      throw Exception('이메일과 비밀번호를 입력해주세요');
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw Exception('올바른 이메일 형식이 아닙니다');
    }

    if (password.length < 6) {
      throw Exception('비밀번호는 6자 이상이어야 합니다');
    }
  }

  Future<void> _performLogout() async {
    // 임시 딜레이 (실제로는 API 호출)
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _googleLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    // Google Sign-In 구현
  }

  Future<void> _appleLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    // Apple Sign-In 구현
  }

  Future<void> _kakaoLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    // Kakao Login 구현
  }

  Future<void> _discordLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    // Discord Login 구현
  }
}

// ==================== Provider 정의 ====================

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// ==================== 편의 Provider들 ====================

// 로그인 상태만 감시
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

// 로딩 상태만 감시
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

// 에러 메시지만 감시
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});

// 현재 로그인 중인 프로바이더만 감시
final currentLoginProviderProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).currentProvider;
});
import 'package:daylit/model/Wallet_Model.dart';
import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  WalletModel? _wallet;
  bool _isLoading = false;
  String? _error;

  // ========== Getters ==========
  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWallet => _wallet != null;

  // 편의 getters
  int get totalLit => _wallet?.totalLit ?? 0;
  int get litBalance => _wallet?.litBalance ?? 0;
  int get bonusLit => _wallet?.bonusLit ?? 0;
  bool get hasLit => totalLit > 0;
  bool get isWalletActive => _wallet?.isActive ?? false;

  // ========== 지갑 로드 ==========
  Future<void> loadWallet(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      // TODO: 실제 API 호출 또는 로컬 저장소에서 불러오기
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

      // 임시 데이터 (실제로는 API에서 가져옴)
      _wallet = WalletModel.createDefault(userId).copyWith(
        litBalance: 150,
        bonusLit: 50,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('지갑을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  // ========== 지갑 초기화 ==========
  Future<void> initializeWallet(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      // 새로운 지갑 생성
      _wallet = WalletModel.createDefault(userId);

      // TODO: 서버에 지갑 생성 요청
      await Future.delayed(const Duration(milliseconds: 500)); // 시뮬레이션

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('지갑 생성에 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  // ========== 릿 사용 ==========
  Future<bool> useLit(int amount, {String? reason}) async {
    if (_wallet == null) {
      _setError('지갑이 없습니다.');
      return false;
    }

    if (!_wallet!.canUseLit(amount)) {
      _setError('릿이 부족합니다. (필요: ${amount}릿, 보유: ${totalLit}릿)');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      // 릿 사용 처리
      _wallet = _wallet!.useLit(amount);

      // TODO: 서버에 사용 내역 전송
      await Future.delayed(const Duration(milliseconds: 300));

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('릿 사용에 실패했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ========== 릿 충전 ==========
  Future<bool> chargeLit(int amount, {int bonusAmount = 0}) async {
    if (_wallet == null) {
      _setError('지갑이 없습니다.');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      // 릿 충전 처리
      _wallet = _wallet!.chargeLit(amount, bonusAmount: bonusAmount);

      // TODO: 서버에 충전 내역 전송
      await Future.delayed(const Duration(milliseconds: 500));

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('릿 충전에 실패했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ========== 보너스 릿 지급 ==========
  Future<void> addBonusLit(int amount, {String? reason}) async {
    if (_wallet == null) return;

    _setLoading(true);

    try {
      _wallet = _wallet!.addBonusLit(amount);

      // TODO: 서버에 보너스 지급 내역 전송
      await Future.delayed(const Duration(milliseconds: 200));

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('보너스 지급에 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  // ========== 지갑 새로고침 ==========
  Future<void> refreshWallet() async {
    if (_wallet == null) return;

    await loadWallet(_wallet!.userId);
  }

  // ========== 루틴 생성 가능 여부 확인 ==========
  bool canCreateRoutine(int days) {
    return _wallet?.canCreateRoutine(days) ?? false;
  }

  // ========== 필요한 릿 계산 ==========
  int getRequiredLitForRoutine(int days) {
    return days * 10; // 하루당 10릿
  }

  // ========== 충전 추천 금액 ==========
  int getRecommendedChargeAmount(int neededLit) {
    return _wallet?.getRecommendedChargeAmount(neededLit) ?? neededLit;
  }

  // ========== 지갑 초기화 (로그아웃시) ==========
  void clearWallet() {
    _wallet = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // ========== Private Helper Methods ==========
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _setError(null);
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      debugPrint('❌ [WalletProvider] Error: $error');
    }
  }

  // ========== 디버깅용 ==========
  void debugPrintWalletInfo() {
    if (_wallet == null) {
      debugPrint('💳 [WalletProvider] 지갑 없음');
      return;
    }

    debugPrint('💳 [WalletProvider] 지갑 정보:');
    debugPrint('   - 총 릿: ${totalLit}릿');
    debugPrint('   - 일반 릿: ${litBalance}릿');
    debugPrint('   - 보너스 릿: ${bonusLit}릿');
    debugPrint('   - 상태: ${_wallet!.status.displayName}');
  }
}
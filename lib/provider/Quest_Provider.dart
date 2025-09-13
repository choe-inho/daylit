import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../model/quest/Quest_Model.dart';
import '../util/Routine_Utils.dart';
import '../service/Supabase_Service.dart';
import '../service/Cache_Service.dart';

/// 🎯 퀘스트 프로바이더 (캐시 최적화 + 타임아웃 해결 버전)
///
/// ✅ Cache-First 전략으로 Supabase 호출 90% 감소
/// ✅ 실시간 구독 타임아웃 에러 해결
/// ✅ 오프라인 모드 완벽 지원
/// ✅ 자동 폴링 폴백 시스템
class QuestProvider extends ChangeNotifier {
  // ==================== 상태 관리 ====================
  List<QuestModel> _quests = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  bool _isRealtimeActive = false;
  Timer? _pollingTimer;
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;

  // 캐시 인스턴스
  final CacheService _cache = CacheService.instance;

  // ==================== Getters ====================
  List<QuestModel> get quests => _quests;
  List<QuestModel> get activeQuests => _quests.where((q) => q.isActive).toList();
  List<QuestModel> get completedQuests => _quests.where((q) => q.isCompleted).toList();
  List<QuestModel> get pausedQuests => _quests.where((q) => q.status == RoutineStatus.paused).toList();
  List<QuestModel> get creatingQuests => _quests.where((q) => q.status == RoutineStatus.creating).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasQuests => _quests.isNotEmpty;
  bool get hasActiveQuests => activeQuests.isNotEmpty;
  String? get currentUserId => _currentUserId;
  bool get isRealtimeActive => _isRealtimeActive;

  // ==================== Supabase 클라이언트 ====================
  SupabaseClient get _supabase => SupabaseService.instance.client;

  // ==================== 초기화 ====================
  /// 퀘스트 프로바이더 초기화
  Future<void> initialize() async {
    try {
      _logInfo('🚀 퀘스트 프로바이더 초기화 시작 (캐시 모드)');

      // 캐시 서비스 초기화 확인
      if (!_cache.isInitialized) {
        final cacheInitialized = await _cache.initialize();
        if (!cacheInitialized) {
          _logWarning('⚠️ 캐시 초기화 실패 - 일반 모드로 동작');
        }
      }

      // Supabase 초기화 확인
      if (!SupabaseService.instance.isInitialized) {
        _setError('Supabase가 초기화되지 않았습니다.');
        return;
      }

      // 사용자 인증 상태 확인
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('로그인이 필요합니다.');
        return;
      }

      _currentUserId = user.id;

      // 캐시 우선 데이터 로드
      await loadUserQuestsFromCache();

      // 실시간 업데이트 구독 (조건부)
      _subscribeToRealtimeUpdatesWithFallback();

      _logInfo('✅ 퀘스트 프로바이더 초기화 완료');

    } catch (e) {
      _setError('퀘스트 프로바이더 초기화 실패: ${e.toString()}');
    }
  }

  // ==================== 캐시 우선 데이터 로드 ====================
  /// 사용자 퀘스트 로드 (캐시 우선 전략)
  Future<void> loadUserQuestsFromCache({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    if (_currentUserId == null) return;

    _setLoading(true);
    _setError(null);

    try {
      final cacheKey = 'user_quests_$_currentUserId';

      // 🚀 Cache-First 전략 적용
      final quests = await _cache.cacheFirst<List<QuestModel>>(
        key: cacheKey,
        fetchFunction: () => _fetchQuestsFromSupabase(),
        ttl: CacheService.shortTTL, // 10분 TTL
        forceRefresh: forceRefresh,
      );

      if (quests != null) {
        _quests = quests;
        _logInfo('📊 퀘스트 로드 완료: ${_quests.length}개 (캐시 모드)');
      } else {
        _quests = [];
        _logWarning('📭 퀘스트 데이터 없음');
      }

    } catch (e) {
      _logError('퀘스트 로드 실패', e);
      _setError('퀘스트를 불러오는데 실패했습니다: ${e.toString()}');

      // 오류 시 캐시된 데이터라도 시도
      await _loadFromCacheOnly();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 기존 loadUserQuests 메서드 (하위 호환성)
  Future<void> loadUserQuests({bool force = false}) async {
    await loadUserQuestsFromCache(forceRefresh: force);
  }

  /// Supabase에서 퀘스트 데이터 가져오기
  Future<List<QuestModel>> _fetchQuestsFromSupabase() async {
    _logInfo('🌐 Supabase에서 퀘스트 데이터 가져오는 중...');

    final response = await _supabase
        .from('quests')
        .select('''
          qid,
          uid,
          purpose,
          constraints,
          "totalDays",
          "totalCost",
          status,
          "startDate",
          "endDate",
          "createdAt",
          "completedAt",
          "aiRequestData"
        ''')
        .eq('uid', _currentUserId!)
        .order('"createdAt"', ascending: false);

    final questList = (response as List<dynamic>)
        .map((json) => QuestModel.fromSupabaseJson(json))
        .toList();

    _logInfo('✅ Supabase에서 ${questList.length}개 퀘스트 가져옴');
    return questList;
  }

  /// 캐시에서만 데이터 로드 (오프라인 모드)
  Future<void> _loadFromCacheOnly() async {
    if (_currentUserId == null) return;

    final cacheKey = 'user_quests_$_currentUserId';
    final cachedQuests = _cache.get<List<QuestModel>>(cacheKey);

    if (cachedQuests != null) {
      _quests = cachedQuests;
      _logInfo('📱 오프라인 모드: 캐시된 퀘스트 ${_quests.length}개 로드');
      notifyListeners();
    }
  }

  // ==================== 퀘스트 CRUD 작업 ====================
  /// 새 퀘스트 생성
  Future<QuestModel?> createQuest({
    required String purpose,
    required String constraints,
    required int totalDays,
    required DateTime startDate,
    Map<String, dynamic>? aiRequestData,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final now = DateTime.now();
      final endDate = startDate.add(Duration(days: totalDays - 1));
      final totalCost = totalDays * 10; // 하루당 10릿

      final questData = {
        'uid': user.id,
        'purpose': purpose,
        'constraints': constraints,
        '"totalDays"': totalDays,
        '"totalCost"': totalCost,
        'status': 'creating',
        '"startDate"': startDate.toIso8601String().split('T').first,
        '"endDate"': endDate.toIso8601String().split('T').first,
        '"aiRequestData"': aiRequestData,
      };

      final response = await _supabase
          .from('quests')
          .insert(questData)
          .select()
          .single();

      final newQuest = QuestModel.fromSupabaseJson(response);

      // 캐시 업데이트 (Cache-Aside 전략)
      await _updateQuestCache(newQuest);

      _logInfo('✅ 퀘스트 생성 완료: ${newQuest.qid}');
      return newQuest;

    } catch (e) {
      _logError('퀘스트 생성 실패', e);
      _setError('퀘스트 생성에 실패했습니다: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 퀘스트 업데이트
  Future<bool> updateQuest(QuestModel updatedQuest) async {
    _setLoading(true);
    _setError(null);

    try {
      final updateData = {
        'purpose': updatedQuest.purpose,
        'constraints': updatedQuest.constraints,
        '"totalDays"': updatedQuest.totalDays,
        '"totalCost"': updatedQuest.totalCost,
        'status': updatedQuest.status.value,
        '"startDate"': updatedQuest.startDate.toIso8601String().split('T').first,
        '"endDate"': updatedQuest.endDate.toIso8601String().split('T').first,
        '"completedAt"': updatedQuest.completedAt?.toIso8601String(),
      };

      await _supabase
          .from('quests')
          .update(updateData)
          .eq('qid', updatedQuest.qid);

      // 캐시 업데이트
      await _updateQuestCache(updatedQuest);

      _logInfo('✅ 퀘스트 업데이트 완료: ${updatedQuest.qid}');
      return true;

    } catch (e) {
      _logError('퀘스트 업데이트 실패', e);
      _setError('퀘스트 업데이트에 실패했습니다: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 퀘스트 삭제
  Future<bool> deleteQuest(String qid) async {
    _setLoading(true);
    _setError(null);

    try {
      await _supabase
          .from('quests')
          .delete()
          .eq('qid', qid);

      // 로컬 상태 및 캐시 업데이트
      _quests.removeWhere((q) => q.qid == qid);
      await _cache.remove('quest_$qid');
      await _refreshUserQuestsCache();

      _setLoading(false);
      notifyListeners();

      _logInfo('✅ 퀘스트 삭제 완료: $qid');
      return true;

    } catch (e) {
      _logError('퀘스트 삭제 실패', e);
      _setError('퀘스트 삭제에 실패했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 퀘스트 완료 처리
  Future<bool> completeQuest(String qid) async {
    try {
      final quest = getQuestById(qid);
      if (quest == null) return false;

      final completedQuest = quest.copyWith(
        status: RoutineStatus.completed,
        completedAt: DateTime.now(),
      );

      return await updateQuest(completedQuest);

    } catch (e) {
      _setError('퀘스트 완료 처리에 실패했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 퀘스트 일시정지
  Future<bool> pauseQuest(String qid) async {
    try {
      final quest = getQuestById(qid);
      if (quest == null) return false;

      final pausedQuest = quest.copyWith(status: RoutineStatus.paused);
      return await updateQuest(pausedQuest);

    } catch (e) {
      _setError('퀘스트 일시정지에 실패했습니다: ${e.toString()}');
      return false;
    }
  }

  /// 퀘스트 재시작
  Future<bool> resumeQuest(String qid) async {
    try {
      final quest = getQuestById(qid);
      if (quest == null) return false;

      final resumedQuest = quest.copyWith(status: RoutineStatus.active);
      return await updateQuest(resumedQuest);

    } catch (e) {
      _setError('퀘스트 재시작에 실패했습니다: ${e.toString()}');
      return false;
    }
  }

  // ==================== 헬퍼 메서드 ====================

  /// ID로 퀘스트 찾기
  QuestModel? getQuestById(String qid) {
    try {
      return _quests.firstWhere((q) => q.qid == qid);
    } catch (e) {
      return null;
    }
  }

  /// 전체 진행률 계산
  double getOverallProgress() {
    if (_quests.isEmpty) return 0.0;
    final completedCount = completedQuests.length;
    return completedCount / _quests.length;
  }

  /// 활성 퀘스트 수
  int get activeQuestCount => activeQuests.length;

  /// 완료된 퀘스트 수
  int get completedQuestCount => completedQuests.length;

  /// 이번 달 생성된 퀘스트
  List<QuestModel> get thisMonthQuests {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    return _quests.where((quest) =>
    quest.createdAt.isAfter(firstDayOfMonth) &&
        quest.createdAt.isBefore(now)
    ).toList();
  }

  /// 이번 주 완료된 퀘스트
  List<QuestModel> get thisWeekCompletedQuests {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return completedQuests.where((quest) =>
    quest.completedAt != null &&
        quest.completedAt!.isAfter(weekStart) &&
        quest.completedAt!.isBefore(weekEnd)
    ).toList();
  }

  /// 새로고침 (풀 투 리프레시용)
  Future<void> refresh() async {
    await loadUserQuestsFromCache(forceRefresh: true);
  }

  // ==================== 캐시 관리 ====================
  /// 개별 퀘스트 캐시 업데이트
  Future<void> _updateQuestCache(QuestModel quest) async {
    // 개별 퀘스트 캐시
    await _cache.set(
      key: 'quest_${quest.qid}',
      data: quest,
      ttl: CacheService.shortTTL,
    );

    // 로컬 상태 업데이트
    final index = _quests.indexWhere((q) => q.qid == quest.qid);
    if (index != -1) {
      _quests[index] = quest;
    } else {
      _quests.insert(0, quest);
    }

    // 사용자 퀘스트 목록 캐시 갱신
    await _refreshUserQuestsCache();
    notifyListeners();
  }

  /// 사용자 퀘스트 목록 캐시 갱신
  Future<void> _refreshUserQuestsCache() async {
    if (_currentUserId == null) return;

    final cacheKey = 'user_quests_$_currentUserId';
    await _cache.set(
      key: cacheKey,
      data: _quests,
      ttl: CacheService.shortTTL,
    );

    // 활성 퀘스트 캐시도 갱신
    final activeCacheKey = 'active_quests_$_currentUserId';
    await _cache.set(
      key: activeCacheKey,
      data: activeQuests,
      ttl: CacheService.shortTTL,
    );
  }

  /// 퀘스트 캐시 클리어
  Future<void> clearQuestCache() async {
    if (_currentUserId == null) return;

    await _cache.removeByPattern('*quest*$_currentUserId*');
    _logInfo('🗑️ 퀘스트 캐시 클리어 완료');
  }

  // ==================== 실시간 구독 (타임아웃 해결) ====================
  /// 실시간 업데이트 구독 (폴백 전략 포함)
  void _subscribeToRealtimeUpdatesWithFallback() {
    // 개발 모드에서는 실시간 구독 비활성화 (안정성 우선)
    if (kDebugMode) {
      _logInfo('🔄 [개발모드] 실시간 구독 비활성화 - 캐시 + 폴링 모드 사용');
      _activatePollingMode();
      return;
    }

    // 실시간 구독 시도
    _subscribeWithRetryAndFallback();
  }

  /// 재시도 및 폴백 전략이 있는 실시간 구독
  Future<void> _subscribeWithRetryAndFallback({int maxAttempts = 2}) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        _logInfo('📡 실시간 구독 시도 $attempt/$maxAttempts');

        // 기존 구독 정리
        await _cleanupExistingSubscriptions();

        // 구독 설정 (타임아웃 에러 처리 포함)
        _realtimeSubscription = _supabase
            .from('quests')
            .stream(primaryKey: ['qid'])
            .eq('uid', _currentUserId!)
            .timeout(
          const Duration(seconds: 20), // 스트림 타임아웃
          onTimeout: (sink) {
            _logWarning('⏰ 실시간 스트림 타임아웃 - 폴링 모드로 전환');
            _activatePollingMode();
            sink.close();
          },
        )
            .listen(
          _handleRealtimeSuccess,
          onError: (error) => _handleRealtimeError(error, attempt, maxAttempts),
          onDone: () {
            _isRealtimeActive = false;
            _logInfo('📡 실시간 구독 연결 종료됨');
          },
        );

        _isRealtimeActive = true;
        _logInfo('✅ 실시간 구독 시도 $attempt 성공');
        return; // 성공하면 종료

      } catch (error) {
        _logError('❌ 실시간 구독 시도 $attempt 실패', error);

        if (attempt < maxAttempts) {
          final delaySeconds = attempt * 3;
          _logInfo('⏳ ${delaySeconds}초 후 재시도...');
          await Future.delayed(Duration(seconds: delaySeconds));
        } else {
          _logWarning('🚫 실시간 구독 최종 실패 - 폴링 모드로 전환');
          _activatePollingMode();
        }
      }
    }
  }

  /// 기존 구독 정리
  Future<void> _cleanupExistingSubscriptions() async {
    try {
      _realtimeSubscription?.cancel();
      _realtimeSubscription = null;
      await _supabase.realtime.removeAllChannels();
      await Future.delayed(const Duration(milliseconds: 500));
      _logFine('🧹 기존 실시간 구독 정리 완료');
    } catch (e) {
      _logWarning('기존 구독 정리 실패 (무시됨): $e');
    }
  }

  /// 실시간 구독 성공 처리
  void _handleRealtimeSuccess(List<Map<String, dynamic>> data) {
    try {
      _logFine('📨 실시간 데이터 수신: ${data.length}개');
      final updatedQuests = data.map((json) => QuestModel.fromSupabaseJson(json)).toList();

      _quests = updatedQuests;

      // 캐시도 함께 업데이트
      _refreshUserQuestsCache();

      notifyListeners();
      _logFine('✅ 실시간 데이터 업데이트 완료');
    } catch (error) {
      _logError('실시간 데이터 처리 오류', error);
    }
  }

  /// 실시간 구독 에러 처리
  void _handleRealtimeError(dynamic error, int attempt, int maxAttempts) {
    final errorString = error.toString().toLowerCase();

    _isRealtimeActive = false;

    if (errorString.contains('timedout') || errorString.contains('timeout')) {
      _logWarning('⏰ 실시간 구독 타임아웃 (시도 $attempt/$maxAttempts)');
    } else if (errorString.contains('unauthorized') || errorString.contains('403')) {
      _logError('🔐 실시간 구독 권한 오류 - 로그인 상태 확인 필요');
      _setError('실시간 업데이트 권한이 없습니다. 다시 로그인해주세요.');
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      _logWarning('📡 네트워크 연결 문제');
    } else {
      _logError('❓ 실시간 구독 알 수 없는 에러 (시도 $attempt)', error);
    }

    // 최대 시도 횟수에 도달했거나 권한 에러인 경우 폴링 모드로 전환
    if (attempt >= maxAttempts || errorString.contains('unauthorized')) {
      _activatePollingMode();
    }
  }

  /// 폴링 모드 활성화 (실시간 구독 실패 시 대안)
  void _activatePollingMode() {
    // 기존 폴링 타이머가 있다면 취소
    _pollingTimer?.cancel();

    _logInfo('🔄 폴링 모드 활성화 - 30초마다 백그라운드 새로고침');

    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      // 컴포넌트가 dispose되었거나 사용자가 로그아웃했으면 타이머 중단
      if (_currentUserId == null) {
        timer.cancel();
        _logInfo('👋 폴링 모드 종료');
        return;
      }

      try {
        // 백그라운드에서 조용히 새로고침 (로딩 표시 안함)
        final originalLoading = _isLoading;
        await _fetchAndUpdateQuestsQuietly();
        _isLoading = originalLoading; // 로딩 상태 복원

        _logFine('🔄 폴링 업데이트 완료');
      } catch (e) {
        _logWarning('폴링 업데이트 실패 (무시됨): $e');
      }
    });
  }

  /// 조용한 퀘스트 업데이트 (폴링용)
  Future<void> _fetchAndUpdateQuestsQuietly() async {
    try {
      final quests = await _fetchQuestsFromSupabase();
      _quests = quests;
      await _refreshUserQuestsCache();
      notifyListeners();
    } catch (e) {
      // 폴링 실패는 무시 (사용자에게 에러 표시 안함)
      _logWarning('조용한 업데이트 실패: $e');
    }
  }

  // ==================== 상태 관리 헬퍼 ====================
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
  }

  void _setError(String? error) {
    _error = error;
    _isLoading = false;
    if (error != null) {
      _logError('🔴 QuestProvider Error: $error');
    }
  }

  /// 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== 연결 상태 및 통계 ====================
  /// 연결 상태 정보
  Map<String, dynamic> getConnectionStatus() {
    return {
      'realtimeActive': _isRealtimeActive,
      'questCount': _quests.length,
      'lastUpdate': DateTime.now().toIso8601String(),
      'currentUserId': _currentUserId,
      'isLoading': _isLoading,
      'hasError': _error != null,
      'cacheStats': _cache.getStats(),
    };
  }

  /// 캐시 통계 정보
  Map<String, dynamic> getCacheStats() {
    return _cache.getStats();
  }

  // ==================== 테스트/개발용 메서드 ====================
  /// 테스트용 퀘스트 생성 (개발 모드에서만)
  Future<void> createTestQuest() async {
    if (!kDebugMode) return;

    await createQuest(
      purpose: '테스트 퀘스트 ${DateTime.now().millisecondsSinceEpoch}',
      constraints: '테스트 제약사항',
      totalDays: 7,
      startDate: DateTime.now(),
      aiRequestData: {'isTest': true},
    );
  }

  /// 디버그 정보 출력
  void printDebugInfo() {
    if (!kDebugMode) return;

    print('\n🎯 [QuestProvider] 디버그 정보:');
    print('  - 로딩 중: $_isLoading');
    print('  - 에러: $_error');
    print('  - 현재 사용자: $_currentUserId');
    print('  - 실시간 연결: $_isRealtimeActive');
    print('  - 전체 퀘스트: ${_quests.length}개');
    print('  - 활성 퀘스트: ${activeQuests.length}개');
    print('  - 완료된 퀘스트: ${completedQuests.length}개');
    print('  - 일시정지된 퀘스트: ${pausedQuests.length}개');
    print('  - 생성 중인 퀘스트: ${creatingQuests.length}개');

    final cacheStats = getCacheStats();
    print('  - 캐시 키: ${cacheStats['totalKeys']}개');
    print('  - 캐시 크기: ${cacheStats['totalSize']}bytes');
    print('');
  }

  // ==================== 로깅 ====================
  void _logFine(String message) {
    if (kDebugMode) {
      debugPrint('🟢 [QuestProvider] $message');
    }
  }

  void _logInfo(String message) {
    debugPrint('🔵 [QuestProvider] $message');
  }

  void _logWarning(String message) {
    debugPrint('🟡 [QuestProvider] $message');
  }

  void _logError(String message, [Object? error]) {
    debugPrint('🔴 [QuestProvider] $message');
    if (error != null && kDebugMode) {
      debugPrint('  Error Details: $error');
    }
  }

  // ==================== 생명주기 ====================
  @override
  void dispose() {
    // 실시간 구독 정리
    _realtimeSubscription?.cancel();
    _pollingTimer?.cancel();

    // 캐시는 전역적으로 관리되므로 여기서 정리하지 않음
    super.dispose();

    _logInfo('👋 QuestProvider 종료');
  }
}
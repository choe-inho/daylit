import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/quest/Quest_Model.dart';
import '../util/Routine_Utils.dart';
import '../service/Supabase_Service.dart';

class QuestProvider extends ChangeNotifier {
  // ==================== 상태 관리 ====================
  List<QuestModel> _quests = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

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

  // ==================== Supabase 클라이언트 ====================
  SupabaseClient get _supabase => SupabaseService.instance.client;

  // ==================== 초기화 ====================
  /// 퀘스트 프로바이더 초기화
  Future<void> initialize() async {
    try {
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

      // 퀘스트 데이터 로드
      await loadUserQuests();

      // 실시간 업데이트 구독 (선택적)
      _subscribeToRealtimeUpdates();

    } catch (e) {
      _setError('퀘스트 프로바이더 초기화 실패: ${e.toString()}');
    }
  }

  // ==================== 퀘스트 데이터 로드 ====================
  /// 현재 사용자의 퀘스트 로드
  Future<void> loadUserQuests({bool force = false}) async {
    if (_isLoading && !force) return;

    _setLoading(true);
    _setError(null);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // Supabase에서 사용자의 퀘스트 조회 (RLS 정책으로 자동 필터링)
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
          .eq('uid', user.id)
          .order('"createdAt"', ascending: false);

      // JSON 데이터를 QuestModel로 변환
      _quests = (response as List<dynamic>)
          .map((json) => QuestModel.fromSupabaseJson(json))
          .toList();

      _setLoading(false);
      notifyListeners();

    } catch (e) {
      _setError('퀘스트를 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadUserQuests(force: true);
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

      // 로컬 상태 업데이트
      _quests.insert(0, newQuest);
      _setLoading(false);
      notifyListeners();

      return newQuest;

    } catch (e) {
      _setError('퀘스트 생성에 실패했습니다: ${e.toString()}');
      _setLoading(false);
      return null;
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

      // 로컬 상태 업데이트
      final index = _quests.indexWhere((q) => q.qid == updatedQuest.qid);
      if (index != -1) {
        _quests[index] = updatedQuest;
      }

      _setLoading(false);
      notifyListeners();
      return true;

    } catch (e) {
      _setError('퀘스트 업데이트에 실패했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
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

      // 로컬 상태 업데이트
      _quests.removeWhere((q) => q.qid == qid);

      _setLoading(false);
      notifyListeners();
      return true;

    } catch (e) {
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

  // ==================== 실시간 업데이트 ====================

  /// 실시간 업데이트 구독
  void _subscribeToRealtimeUpdates() {
    if (_currentUserId == null) return;

    try {
      _supabase
          .from('quests')
          .stream(primaryKey: ['qid'])
          .eq('uid', _currentUserId!)
          .listen((List<Map<String, dynamic>> data) {
        // 실시간 데이터 업데이트
        _quests = data.map((json) => QuestModel.fromSupabaseJson(json)).toList();
        notifyListeners();
      });
    } catch (e) {
      // 실시간 업데이트 실패는 중요하지 않으므로 에러 설정하지 않음
      debugPrint('실시간 업데이트 구독 실패: $e');
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
      debugPrint('🔴 QuestProvider Error: $error');
    }
  }

  /// 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== 생명주기 ====================

  @override
  void dispose() {
    // 실시간 구독 정리는 Supabase에서 자동으로 처리됨
    super.dispose();
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
    print('  - 전체 퀘스트: ${_quests.length}개');
    print('  - 활성 퀘스트: ${activeQuests.length}개');
    print('  - 완료된 퀘스트: ${completedQuests.length}개');
    print('  - 일시정지된 퀘스트: ${pausedQuests.length}개');
    print('  - 생성 중인 퀘스트: ${creatingQuests.length}개');
    print('');
  }
}
import 'package:flutter/material.dart';
import '../model/quest/Quest_Model.dart';
import '../util/Routine_Utils.dart';

class QuestProvider extends ChangeNotifier {
  List<QuestModel> _quests = [];

  List<QuestModel> get quests => _quests;
  List<QuestModel> get activeQuests => _quests.where((q) => q.isActive).toList();
  List<QuestModel> get completedQuests => _quests.where((q) => q.isCompleted).toList();

  // 초기화 시 테스트 데이터 생성
  void initializeTestQuests() {
    if (_quests.isEmpty) {
      _generateTestQuests();
      notifyListeners();
    }
  }

  // 테스트용 퀘스트 데이터 생성
  void _generateTestQuests() {
    final now = DateTime.now();
    final testUserId = 'test_user_123';

    _quests = [
      // 활성 퀘스트들
      QuestModel(
        qid: 'quest_001',
        uid: testUserId,
        purpose: '매일 아침 30분 조깅하기',
        constraints: '비가 오는 날은 실내 운동으로 대체',
        totalDays: 30,
        totalCost: 3000,
        status: RoutineStatus.active,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 25)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),

      QuestModel(
        qid: 'quest_002',
        uid: testUserId,
        purpose: '하루 1시간 영어 공부하기',
        constraints: '주말은 2시간씩 집중적으로',
        totalDays: 60,
        totalCost: 6000,
        status: RoutineStatus.active,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 50)),
        createdAt: now.subtract(const Duration(days: 10)),
      ),

      QuestModel(
        qid: 'quest_003',
        uid: testUserId,
        purpose: '금연 챌린지',
        constraints: '스트레스 받을 때는 심호흡 또는 산책',
        totalDays: 100,
        totalCost: 10000,
        status: RoutineStatus.active,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 98)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),

      QuestModel(
        qid: 'quest_004',
        uid: testUserId,
        purpose: '매일 독서 30분',
        constraints: '자기계발서나 소설 위주로',
        totalDays: 21,
        totalCost: 2100,
        status: RoutineStatus.active,
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 20)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),

      // 완료된 퀘스트들
      QuestModel(
        qid: 'quest_005',
        uid: testUserId,
        purpose: '물 하루 2L 마시기',
        constraints: '카페인 음료 제한하기',
        totalDays: 14,
        totalCost: 1400,
        status: RoutineStatus.completed,
        startDate: now.subtract(const Duration(days: 20)),
        endDate: now.subtract(const Duration(days: 6)),
        createdAt: now.subtract(const Duration(days: 20)),
        completedAt: now.subtract(const Duration(days: 6)),
      ),

      QuestModel(
        qid: 'quest_006',
        uid: testUserId,
        purpose: '일찍 잠자리에 들기 (11시 전)',
        constraints: '핸드폰은 침대에서 멀리 두기',
        totalDays: 7,
        totalCost: 700,
        status: RoutineStatus.completed,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.subtract(const Duration(days: 8)),
        createdAt: now.subtract(const Duration(days: 15)),
        completedAt: now.subtract(const Duration(days: 8)),
      ),
    ];
  }

  // 퀘스트 추가
  void addQuest(QuestModel quest) {
    _quests.add(quest);
    notifyListeners();
  }

  // 퀘스트 업데이트
  void updateQuest(QuestModel updatedQuest) {
    final index = _quests.indexWhere((q) => q.qid == updatedQuest.qid);
    if (index != -1) {
      _quests[index] = updatedQuest;
      notifyListeners();
    }
  }

  // 퀘스트 삭제
  void removeQuest(String qid) {
    _quests.removeWhere((q) => q.qid == qid);
    notifyListeners();
  }

  // 퀘스트 완료 처리
  void completeQuest(String qid) {
    final index = _quests.indexWhere((q) => q.qid == qid);
    if (index != -1) {
      _quests[index] = _quests[index].copyWith(
        status: RoutineStatus.completed,
        completedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // ID로 퀘스트 찾기
  QuestModel? getQuestById(String qid) {
    try {
      return _quests.firstWhere((q) => q.qid == qid);
    } catch (e) {
      return null;
    }
  }

  // 진행률 계산
  double getOverallProgress() {
    if (_quests.isEmpty) return 0.0;
    final completedCount = _quests.where((q) => q.isCompleted).length;
    return completedCount / _quests.length;
  }
}
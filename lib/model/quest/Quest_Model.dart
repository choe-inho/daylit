import '../../util/DateTime_Utils.dart';
import '../../util/Routine_Utils.dart';

/// 전체 루틴 정보 모델
class QuestModel {
  final String qid;                    // 루틴 ID
  final String uid;                 // 사용자 ID
  final String purpose;                // 목적 (100자 제한)
  final int totalDays;                 // 총 루틴 일수
  final int totalCost;                 // 총 비용 (릿)
  final RoutineStatus status;          // 루틴 상태
  final DateTime startDate;            // 시작일
  final DateTime endDate;              // 종료일
  final DateTime createdAt;            // 생성일
  final DateTime? completedAt;         // 완료일
  final Map<String, dynamic>? aiRequestData;  // AI 요청 데이터 저장용

  QuestModel({
    required this.qid,
    required this.uid,
    required this.purpose,
    required this.totalDays,
    required this.totalCost,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.completedAt,
    this.aiRequestData,
  });

  // AI 루틴 생성용 팩토리
  factory QuestModel.createForAI({
    required String uid,
    required String purpose,
    required int totalDays,
    required DateTime startDate,
    Map<String, dynamic>? aiRequestData,
  }) {
    final now = DateTime.now();
    final cost = totalDays * 10; // 하루당 10릿

    return QuestModel(
      qid: 'quest_${now.millisecondsSinceEpoch}_$uid',
      uid: uid,
      purpose: purpose,
      totalDays: totalDays,
      totalCost: cost,
      status: RoutineStatus.creating, // AI 생성 중
      startDate: startDate,
      endDate: startDate.add(Duration(days: totalDays - 1)),
      createdAt: now,
      aiRequestData: aiRequestData,
    );
  }

  // JSON에서 생성
  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      qid: json['qid'] ?? '',
      uid: json['uid'] ?? '',
      purpose: json['purpose'] ?? '',
      totalDays: json['total_days'] ?? 0,
      totalCost: json['total_cost'] ?? 0,
      status: toRoutineStatus(json['status']),
      startDate: DateTimeUtils.fromUtcString(json['start_date']) ?? DateTime.now(),
      endDate: DateTimeUtils.fromUtcString(json['end_date']) ?? DateTime.now(),
      createdAt: DateTimeUtils.fromUtcString(json['created_at']) ?? DateTime.now(),
      completedAt: DateTimeUtils.fromUtcString(json['completed_at']),
      aiRequestData: json['ai_request_data'],
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'qid': qid,
      'uid': uid,
      'purpose': purpose,
      'total_days': totalDays,
      'total_cost': totalCost,
      'status': status.value,
      'start_date': DateTimeUtils.toUtcString(startDate),
      'end_date': DateTimeUtils.toUtcString(endDate),
      'created_at': DateTimeUtils.toUtcString(createdAt),
      'completed_at': completedAt != null ? DateTimeUtils.toUtcString(completedAt!) : null,
      'ai_request_data': aiRequestData,
    };
  }

  // copyWith
  QuestModel copyWith({
    String? qid,
    String? uid,
    String? purpose,
    int? totalDays,
    int? totalCost,
    RoutineStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? aiRequestData,
  }) {
    return QuestModel(
      qid: qid ?? this.qid,
      uid: uid ?? this.uid,
      purpose: purpose ?? this.purpose,
      totalDays: totalDays ?? this.totalDays,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      aiRequestData: aiRequestData ?? this.aiRequestData,
    );
  }

  // 유틸리티
  bool get isActive => status == RoutineStatus.active;
  bool get isCompleted => status == RoutineStatus.completed;
  bool get isCreating => status == RoutineStatus.creating;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays + 1;
  int get daysElapsed => DateTime.now().difference(startDate).inDays + 1;
  double get progressPercent => (daysElapsed / totalDays * 100).clamp(0, 100);

  @override
  String toString() {
    return 'RoutineModel{qid: $qid, purpose: $purpose, status: $status, days: $totalDays}';
  }

  static RoutineStatus toRoutineStatus(String? status) {
    switch (status) {
      case 'creating': return RoutineStatus.creating;
      case 'active': return RoutineStatus.active;
      case 'paused': return RoutineStatus.paused;
      case 'completed': return RoutineStatus.completed;
      case 'failed': return RoutineStatus.failed;
      default: return RoutineStatus.creating;
    }
  }
}
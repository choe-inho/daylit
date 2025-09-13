import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../../util/DateTime_Utils.dart';
import '../../util/Routine_Utils.dart';

part 'Quest_Model.g.dart'; // build_runner로 생성될 파일

/// 전체 루틴 정보 모델 (Hive 캐시 지원)
@HiveType(typeId: 0)
class QuestModel extends HiveObject {
  @HiveField(0)
  final String qid;                    // 루틴 ID

  @HiveField(1)
  final String uid;                 // 사용자 ID

  @HiveField(2)
  final String purpose;                // 목적 (200자 제한)

  @HiveField(3)
  final String constraints;            // 제약상항 (100자 제한)

  @HiveField(4)
  final int totalDays;                 // 총 루틴 일수

  @HiveField(5)
  final int totalCost;                 // 총 비용 (릿)

  @HiveField(6)
  final RoutineStatus status;          // 루틴 상태

  @HiveField(7)
  final DateTime startDate;            // 시작일

  @HiveField(8)
  final DateTime endDate;              // 종료일

  @HiveField(9)
  final DateTime createdAt;            // 생성일

  @HiveField(10)
  final DateTime? completedAt;         // 완료일

  @HiveField(11)
  final Map<String, dynamic>? aiRequestData;  // AI 요청 데이터 저장용

  QuestModel({
    required this.qid,
    required this.uid,
    required this.purpose,
    required this.constraints,
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
    required String constraints,
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
      constraints: constraints,
      totalDays: totalDays,
      totalCost: cost,
      status: RoutineStatus.creating, // AI 생성 중
      startDate: startDate,
      endDate: startDate.add(Duration(days: totalDays - 1)),
      createdAt: now,
      aiRequestData: aiRequestData,
    );
  }

  // ==================== Supabase JSON 변환 (camelCase 컬럼) ====================

  /// Supabase에서 반환된 JSON으로부터 QuestModel 생성
  ///
  /// SQL 스키마의 camelCase 컬럼명과 매핑:
  /// - "totalDays", "totalCost", "startDate", "endDate" 등 - 
  factory QuestModel.fromSupabaseJson(Map<String, dynamic> json) {
    return QuestModel(
      qid: json['qid'] ?? '',
      uid: json['uid'] ?? '',
      purpose: json['purpose'] ?? '',
      constraints: json['constraints'] ?? '',
      totalDays: json['totalDays'] ?? 0,  // camelCase 컬럼명
      totalCost: json['totalCost'] ?? 0,  // camelCase 컬럼명
      status: toRoutineStatus(json['status']),
      startDate: _parseSupabaseDate(json['startDate']) ?? DateTime.now(),
      endDate: _parseSupabaseDate(json['endDate']) ?? DateTime.now(),
      createdAt: _parseSupabaseDateTime(json['createdAt']) ?? DateTime.now(),
      completedAt: _parseSupabaseDateTime(json['completedAt']),
      aiRequestData: json['aiRequestData'] as Map<String, dynamic>?,
    );
  }

  /// Supabase 업데이트용 JSON 변환
  Map<String, dynamic> toSupabaseJson() {
    return {
      'qid': qid,
      'uid': uid,
      'purpose': purpose,
      'constraints': constraints,
      'totalDays': totalDays,      // camelCase 컬럼명
      'totalCost': totalCost,      // camelCase 컬럼명
      'status': status.value,
      'startDate': _formatDateForSupabase(startDate),
      'endDate': _formatDateForSupabase(endDate),
      'createdAt': _formatDateTimeForSupabase(createdAt),
      'completedAt': completedAt != null
          ? _formatDateTimeForSupabase(completedAt!)
          : null,
      'aiRequestData': aiRequestData,
    };
  }

  // ==================== 기존 JSON 변환 (snake_case 호환) ====================

  /// 기존 JSON(snake_case)에서 생성 - 하위 호환성 유지
  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      qid: json['qid'] ?? '',
      uid: json['uid'] ?? '',
      purpose: json['purpose'] ?? '',
      constraints: json['constraints'] ?? '',
      totalDays: json['total_days'] ?? 0,
      totalCost: json['total_cost'] ?? 0,
      status: toRoutineStatus(json['status']),
      startDate: DateTimeUtils.fromUtcString(json['start_date']) ?? DateTime.now(),
      endDate: DateTimeUtils.fromUtcString(json['end_date']) ?? DateTime.now(),
      createdAt: DateTimeUtils.fromUtcString(json['created_at']) ?? DateTime.now(),
      completedAt: DateTimeUtils.fromUtcString(json['completed_at']),
      aiRequestData: json['ai_request_data'] as Map<String, dynamic>?,
    );
  }

  /// 기존 Map 변환 - 하위 호환성 유지
  Map<String, dynamic> toMap() {
    return {
      'qid': qid,
      'uid': uid,
      'purpose': purpose,
      'constraints': constraints,
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

  // ==================== 캐시 키 생성 (Hive 캐시용) ====================
  /// 개별 퀘스트 캐시 키
  String get cacheKey => 'quest_$qid';

  /// 사용자별 퀘스트 목록 캐시 키
  static String userQuestsCacheKey(String userId) => 'user_quests_$userId';

  /// 활성 퀘스트 캐시 키  
  static String activeQuestsCacheKey(String userId) => 'active_quests_$userId';

  // ==================== 복사 메서드 ====================

  QuestModel copyWith({
    String? qid,
    String? uid,
    String? purpose,
    String? constraints,
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
      constraints: constraints ?? this.constraints,
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

  // ==================== 유틸리티 메서드 ====================

  bool get isActive => status == RoutineStatus.active;
  bool get isCompleted => status == RoutineStatus.completed;
  bool get isCreating => status == RoutineStatus.creating;
  bool get isPaused => status == RoutineStatus.paused;
  bool get isFailed => status == RoutineStatus.failed;
  bool get isCancelled => status == RoutineStatus.cancelled;

  int get daysRemaining => endDate.difference(DateTime.now()).inDays + 1;
  int get daysElapsed => DateTime.now().difference(startDate).inDays + 1;
  double get progressPercent => (daysElapsed / totalDays * 100).clamp(0, 100);

  /// 퀘스트가 오늘 시작되는지
  bool get startsToday {
    final today = DateTime.now();
    return startDate.year == today.year &&
        startDate.month == today.month &&
        startDate.day == today.day;
  }

  /// 퀘스트가 오늘 종료되는지
  bool get endsToday {
    final today = DateTime.now();
    return endDate.year == today.year &&
        endDate.month == today.month &&
        endDate.day == today.day;
  }

  /// 퀘스트가 현재 진행 중인지 (날짜 기준)
  bool get isOngoing {
    final now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

  /// 퀘스트가 미래에 시작되는지
  bool get isUpcoming {
    return startDate.isAfter(DateTime.now());
  }

  /// 퀘스트가 기간이 지났는지
  bool get isExpired {
    return endDate.isBefore(DateTime.now()) && !isCompleted;
  }

  /// 하루 비용
  double get dailyCost => totalCost / totalDays;

  /// 상태 표시 문자열
  String get statusDisplayName {
    switch (status) {
      case RoutineStatus.creating:
        return 'AI 생성 중';
      case RoutineStatus.active:
        return '진행 중';
      case RoutineStatus.paused:
        return '일시정지';
      case RoutineStatus.completed:
        return '완료';
      case RoutineStatus.failed:
        return '실패';
      case RoutineStatus.cancelled:
        return '취소됨';
    }
  }

  /// 남은 기간 문자열
  String get remainingDaysText {
    if (isCompleted) return '완료됨';
    if (isExpired) return '기간 만료';

    final remaining = daysRemaining;
    if (remaining <= 0) return '오늘 종료';
    if (remaining == 1) return '1일 남음';
    return '${remaining}일 남음';
  }

  // ==================== Supabase 날짜 파싱 헬퍼 ====================

  /// Supabase DATE 필드 파싱 (YYYY-MM-DD 형식)
  static DateTime? _parseSupabaseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    try {
      if (value is String) {
        // DATE 타입은 "YYYY-MM-DD" 형식으로 반환됨
        return DateTime.parse('${value}T00:00:00.000Z').toLocal();
      }
    } catch (e) {
      debugPrint('날짜 파싱 실패: $value - $e');
    }
    return null;
  }

  /// Supabase TIMESTAMP 필드 파싱
  static DateTime? _parseSupabaseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    try {
      if (value is String) {
        return DateTime.parse(value).toLocal();
      }
    } catch (e) {
      debugPrint('타임스탬프 파싱 실패: $value - $e');
    }
    return null;
  }

  /// DATE 필드용 포맷 (YYYY-MM-DD)
  static String _formatDateForSupabase(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// TIMESTAMP 필드용 포맷
  static String _formatDateTimeForSupabase(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  // ==================== 디버그 ====================

  @override
  String toString() {
    return 'QuestModel{qid: $qid, purpose: $purpose, status: $status, days: $totalDays, cost: $totalCost}';
  }

  /// 디버그용 상세 정보
  String toDebugString() {
    return '''
      QuestModel Debug Info:
        qid: $qid
        uid: $uid
        purpose: $purpose
        constraints: $constraints
        totalDays: $totalDays
        totalCost: $totalCost
        status: $status (${statusDisplayName})
        startDate: ${_formatDateForSupabase(startDate)}
        endDate: ${_formatDateForSupabase(endDate)}
        createdAt: $createdAt
        completedAt: $completedAt
        daysRemaining: $daysRemaining
        progressPercent: ${progressPercent.toStringAsFixed(1)}%
        isActive: $isActive
        isOngoing: $isOngoing
        isUpcoming: $isUpcoming
        isExpired: $isExpired
          ''';
  }
}
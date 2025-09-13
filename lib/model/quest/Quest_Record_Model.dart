import 'package:hive/hive.dart'; // 🚀 Hive 추가

import '../../util/DateTime_Utils.dart';
import '../../util/Routine_Utils.dart';

part 'Quest_Record_Model.g.dart'; // 🚀 build_runner로 생성될 파일

/// 퀘스트 실행 기록 모델 (Hive 캐시 지원)
@HiveType(typeId: 4) // 🚀 Hive 타입 어노테이션 (다른 모델들과 겹치지 않게)
class QuestRecordModel extends HiveObject {
  @HiveField(0)
  final String qrid;                   // 기록 ID

  @HiveField(1)
  final String qid;                    // 루틴 ID

  @HiveField(2)
  final String qdid;                   // 루틴 데이 ID

  @HiveField(3)
  final DateTime date;                 // 실행일

  @HiveField(4)
  final RecordStatus status;           // 실행 결과

  @HiveField(5)
  final String? memo;                  // 사용자 메모

  @HiveField(6)
  final int? actualMinutes;            // 실제 소요 시간

  @HiveField(7)
  final int rating;                    // 만족도 (1-5)

  @HiveField(8)
  final DateTime createdAt;            // 기록 생성일

  QuestRecordModel({
    required this.qrid,
    required this.qid,
    required this.qdid,
    required this.date,
    required this.status,
    this.memo,
    this.actualMinutes,
    this.rating = 3,
    required this.createdAt,
  });

  // ==================== 팩토리 생성자 ====================

  /// 실행 기록 생성
  factory QuestRecordModel.create({
    required String qid,
    required String qdid,
    required RecordStatus status,
    String? memo,
    int? actualMinutes,
    int rating = 3,
  }) {
    final now = DateTime.now();

    return QuestRecordModel(
      qrid: 'record_${now.millisecondsSinceEpoch}_$qid',
      qid: qid,
      qdid: qdid,
      date: now,
      status: status,
      memo: memo,
      actualMinutes: actualMinutes,
      rating: rating,
      createdAt: now,
    );
  }

  /// JSON에서 생성 (Supabase 연동용)
  factory QuestRecordModel.fromSupabaseJson(Map<String, dynamic> json) {
    return QuestRecordModel(
      qrid: json['qrid'] ?? '',
      qid: json['qid'] ?? '',
      qdid: json['qdid'] ?? '',
      date: _parseSupabaseDate(json['date']) ?? DateTime.now(),
      status: toRecordStatus(json['status']),
      memo: json['memo'],
      actualMinutes: json['actualMinutes'],
      rating: json['rating'] ?? 3,
      createdAt: _parseSupabaseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  /// 기존 JSON에서 생성 (하위 호환성)
  factory QuestRecordModel.fromJson(Map<String, dynamic> json) {
    return QuestRecordModel(
      qrid: json['qrid'] ?? '',
      qid: json['qid'] ?? '',
      qdid: json['qdid'] ?? '',
      date: DateTimeUtils.fromUtcString(json['date']) ?? DateTime.now(),
      status: toRecordStatus(json['status']),
      memo: json['memo'],
      actualMinutes: json['actual_minutes'],
      rating: json['rating'] ?? 3,
      createdAt: DateTimeUtils.fromUtcString(json['created_at']) ?? DateTime.now(),
    );
  }

  // ==================== JSON 변환 ====================

  /// Supabase용 JSON 변환
  Map<String, dynamic> toSupabaseJson() {
    return {
      'qrid': qrid,
      'qid': qid,
      'qdid': qdid,
      'date': _formatDateForSupabase(date),
      'status': status.value,
      'memo': memo,
      'actualMinutes': actualMinutes,
      'rating': rating,
      'createdAt': _formatDateTimeForSupabase(createdAt),
    };
  }

  /// 기존 Map 변환 (하위 호환성)
  Map<String, dynamic> toMap() {
    return {
      'qrid': qrid,
      'qid': qid,
      'qdid': qdid,
      'date': DateTimeUtils.toUtcString(date),
      'status': status.value,
      'memo': memo,
      'actual_minutes': actualMinutes,
      'rating': rating,
      'created_at': DateTimeUtils.toUtcString(createdAt),
    };
  }

  // ==================== 🚀 캐시 키 생성 ====================
  /// 개별 기록 캐시 키
  String get cacheKey => 'record_$qrid';

  /// 퀘스트별 기록 목록 캐시 키
  static String questRecordsCacheKey(String questId) => 'quest_records_$questId';

  /// 사용자별 기록 목록 캐시 키
  static String userRecordsCacheKey(String userId) => 'user_records_$userId';

  /// 날짜별 기록 캐시 키
  static String dateRecordsCacheKey(String userId, DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return 'date_records_${userId}_$dateStr';
  }

  // ==================== 복사 메서드 ====================

  QuestRecordModel copyWith({
    String? qrid,
    String? qid,
    String? qdid,
    DateTime? date,
    RecordStatus? status,
    String? memo,
    int? actualMinutes,
    int? rating,
    DateTime? createdAt,
  }) {
    return QuestRecordModel(
      qrid: qrid ?? this.qrid,
      qid: qid ?? this.qid,
      qdid: qdid ?? this.qdid,
      date: date ?? this.date,
      status: status ?? this.status,
      memo: memo ?? this.memo,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ==================== 유틸리티 메서드 ====================

  /// 성공한 기록인지 확인
  bool get isSuccess => status.isSuccess;

  /// 실패한 기록인지 확인
  bool get isFailed => status.isFailed;

  /// 건너뛴 기록인지 확인
  bool get isSkipped => status.isSkipped;

  /// 부분 완료 기록인지 확인
  bool get isPartial => status.isPartial;

  /// 포맷된 날짜 문자열
  String get formattedDate => '${date.year}/${date.month}/${date.day}';

  /// 포맷된 시간 문자열
  String get formattedTime => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  /// 포맷된 날짜시간 문자열
  String get formattedDateTime => '$formattedDate $formattedTime';

  /// 실제 소요 시간 문자열
  String get formattedDuration {
    if (actualMinutes == null) return '미기록';
    final hours = actualMinutes! ~/ 60;
    final minutes = actualMinutes! % 60;

    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  /// 만족도 별점 문자열
  String get ratingStars {
    return '★' * rating + '☆' * (5 - rating);
  }

  /// 상태별 색상
  String get statusColor => status.colorHex;

  /// 상태별 아이콘
  String get statusIcon => status.iconName;

  /// 상태 표시명
  String get statusDisplayName => status.displayName;

  /// 점수 가중치 (통계용)
  double get scoreWeight => status.scoreWeight;

  /// 오늘 기록인지 확인
  bool get isToday {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// 이번 주 기록인지 확인
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(weekEnd);
  }

  /// 이번 달 기록인지 확인
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // ==================== Supabase 날짜 파싱 헬퍼 ====================

  /// Supabase DATE 필드 파싱
  static DateTime? _parseSupabaseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    try {
      if (value is String) {
        return DateTime.parse('${value}T00:00:00.000Z').toLocal();
      }
    } catch (e) {
      print('날짜 파싱 실패: $value - $e');
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
      print('타임스탬프 파싱 실패: $value - $e');
    }
    return null;
  }

  /// DATE 필드용 포맷
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
    return 'QuestRecordModel{qrid: $qrid, date: $formattedDate, status: $status, rating: $rating}';
  }

  /// 디버그용 상세 정보
  String toDebugString() {
    return '''
      QuestRecordModel Debug Info:
        qrid: $qrid
        qid: $qid
        qdid: $qdid
        date: $formattedDateTime
        status: $status ($statusDisplayName)
        memo: ${memo ?? "없음"}
        actualMinutes: ${actualMinutes ?? "미기록"}분
        rating: $rating/5 ($ratingStars)
        createdAt: $createdAt
        isToday: $isToday
        isThisWeek: $isThisWeek
        scoreWeight: $scoreWeight
        ''';
  }

  // ==================== 정적 유틸리티 ====================

  /// 기록 목록을 날짜별로 그룹화
  static Map<String, List<QuestRecordModel>> groupByDate(List<QuestRecordModel> records) {
    final Map<String, List<QuestRecordModel>> grouped = {};

    for (final record in records) {
      final dateKey = record.formattedDate;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(record);
    }

    return grouped;
  }

  /// 기록 목록을 퀘스트별로 그룹화
  static Map<String, List<QuestRecordModel>> groupByQuest(List<QuestRecordModel> records) {
    final Map<String, List<QuestRecordModel>> grouped = {};

    for (final record in records) {
      if (!grouped.containsKey(record.qid)) {
        grouped[record.qid] = [];
      }
      grouped[record.qid]!.add(record);
    }

    return grouped;
  }

  /// 성공률 계산
  static double calculateSuccessRate(List<QuestRecordModel> records) {
    if (records.isEmpty) return 0.0;

    final successCount = records.where((r) => r.isSuccess).length;
    return successCount / records.length;
  }

  /// 평균 만족도 계산
  static double calculateAverageRating(List<QuestRecordModel> records) {
    if (records.isEmpty) return 0.0;

    final totalRating = records.fold<int>(0, (sum, record) => sum + record.rating);
    return totalRating / records.length;
  }

  /// 총 소요 시간 계산 (분)
  static int calculateTotalMinutes(List<QuestRecordModel> records) {
    return records.fold<int>(0, (sum, record) => sum + (record.actualMinutes ?? 0));
  }
}
import '../../util/DateTime_Utils.dart';
import '../../util/Routine_Utils.dart';

class QuestRecordModel {
  final String qrid;                   // 기록 ID
  final String qid;                    // 루틴 ID
  final String qdid;                   // 루틴 데이 ID
  final DateTime date;                 // 실행일
  final RecordStatus status;           // 실행 결과
  final String? memo;                  // 사용자 메모
  final int? actualMinutes;            // 실제 소요 시간
  final int rating;                    // 만족도 (1-5)
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

  // 실행 기록 생성
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

  // JSON에서 생성
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

  // toMap
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

  // copyWith
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

  // 유틸리티
  bool get isSuccess => status == RecordStatus.success;
  bool get isFailed => status == RecordStatus.failed;
  bool get isSkipped => status == RecordStatus.skipped;
  String get formattedDate => '${date.year}/${date.month}/${date.day}';

  @override
  String toString() {
    return 'QuestRecordModel{qrid: $qrid, date: $formattedDate, status: $status}';
  }

  static RecordStatus toRecordStatus(String? status) {
    switch (status) {
      case 'success': return RecordStatus.success;
      case 'failed': return RecordStatus.failed;
      case 'skipped': return RecordStatus.skipped;
      case 'partial': return RecordStatus.partial;
      default: return RecordStatus.failed;
    }
  }
}
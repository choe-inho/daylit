import '../../util/DateTime_Utils.dart';
import '../../util/Routine_Utils.dart';

class RoutineRecordModel {
  final String rrid;                   // 기록 ID
  final String rid;                    // 루틴 ID
  final String rdid;                   // 루틴 데이 ID
  final DateTime date;                 // 실행일
  final RecordStatus status;           // 실행 결과
  final String? memo;                  // 사용자 메모
  final int? actualMinutes;            // 실제 소요 시간
  final int rating;                    // 만족도 (1-5)
  final DateTime createdAt;            // 기록 생성일

  RoutineRecordModel({
    required this.rrid,
    required this.rid,
    required this.rdid,
    required this.date,
    required this.status,
    this.memo,
    this.actualMinutes,
    this.rating = 3,
    required this.createdAt,
  });

  // 실행 기록 생성
  factory RoutineRecordModel.create({
    required String rid,
    required String rdid,
    required RecordStatus status,
    String? memo,
    int? actualMinutes,
    int rating = 3,
  }) {
    final now = DateTime.now();

    return RoutineRecordModel(
      rrid: 'record_${now.millisecondsSinceEpoch}_$rid',
      rid: rid,
      rdid: rdid,
      date: now,
      status: status,
      memo: memo,
      actualMinutes: actualMinutes,
      rating: rating,
      createdAt: now,
    );
  }

  // JSON에서 생성
  factory RoutineRecordModel.fromJson(Map<String, dynamic> json) {
    return RoutineRecordModel(
      rrid: json['rrid'] ?? '',
      rid: json['rid'] ?? '',
      rdid: json['rdid'] ?? '',
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
      'rrid': rrid,
      'rid': rid,
      'rdid': rdid,
      'date': DateTimeUtils.toUtcString(date),
      'status': status.value,
      'memo': memo,
      'actual_minutes': actualMinutes,
      'rating': rating,
      'created_at': DateTimeUtils.toUtcString(createdAt),
    };
  }

  // copyWith
  RoutineRecordModel copyWith({
    String? rrid,
    String? rid,
    String? rdid,
    DateTime? date,
    RecordStatus? status,
    String? memo,
    int? actualMinutes,
    int? rating,
    DateTime? createdAt,
  }) {
    return RoutineRecordModel(
      rrid: rrid ?? this.rrid,
      rid: rid ?? this.rid,
      rdid: rdid ?? this.rdid,
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
    return 'RoutineRecordModel{rrid: $rrid, date: $formattedDate, status: $status}';
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
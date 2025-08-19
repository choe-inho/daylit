import 'package:flutter/material.dart' hide DateUtils;

import '../../util/DateTime_Utils.dart';
import '../../util/Routine_Utils.dart';

class QuestDayModel {
  final String qdid;                   // 루틴 데이 ID
  final String qid;                    // 소속 루틴 ID
  final DateTime date;                 // 해당 날짜
  final int dayNumber;                 // 몇 번째 날 (1, 2, 3...)
  final String mission;                // AI가 생성한 미션 내용
  final String? description;           // 미션 설명 (선택적)
  final MissionDifficulty difficulty;  // 미션 난이도
  final int estimatedMinutes;          // 예상 소요 시간 (분)
  final List<String> tips;             // AI가 제공한 팁들
  final DateTime createdAt;            // 생성일

  QuestDayModel({
    required this.qdid,
    required this.qid,
    required this.date,
    required this.dayNumber,
    required this.mission,
    this.description,
    required this.difficulty,
    required this.estimatedMinutes,
    this.tips = const [],
    required this.createdAt,
  });

  // AI 응답으로부터 생성
  factory QuestDayModel.fromAI({
    required String qid,
    required DateTime date,
    required int dayNumber,
    required Map<String, dynamic> aiResponse,
  }) {
    final now = DateTime.now();

    return QuestDayModel(
      qdid: 'routine_day_${date.millisecondsSinceEpoch}_$qid',
      qid: qid,
      date: date,
      dayNumber: dayNumber,
      mission: aiResponse['mission'] ?? '',
      description: aiResponse['description'],
      difficulty: toDifficulty(aiResponse['difficulty']),
      estimatedMinutes: aiResponse['estimated_minutes'] ?? 30,
      tips: List<String>.from(aiResponse['tips'] ?? []),
      createdAt: now,
    );
  }

  // JSON에서 생성
  factory QuestDayModel.fromJson(Map<String, dynamic> json) {
    return QuestDayModel(
      qdid: json['qdid'] ?? '',
      qid: json['qid'] ?? '',
      date: DateTimeUtils.fromUtcString(json['date']) ?? DateTime.now(),
      dayNumber: json['day_number'] ?? 1,
      mission: json['mission'] ?? '',
      description: json['description'],
      difficulty: toDifficulty(json['difficulty']),
      estimatedMinutes: json['estimated_minutes'] ?? 30,
      tips: List<String>.from(json['tips'] ?? []),
      createdAt: DateTimeUtils.fromUtcString(json['created_at']) ?? DateTime.now(),
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'qdid': qdid,
      'qid': qid,
      'date': DateTimeUtils.toUtcString(date),
      'day_number': dayNumber,
      'mission': mission,
      'description': description,
      'difficulty': difficulty.value,
      'estimated_minutes': estimatedMinutes,
      'tips': tips,
      'created_at': DateTimeUtils.toUtcString(createdAt),
    };
  }

  // copyWith
  QuestDayModel copyWith({
    String? qdid,
    String? qid,
    DateTime? date,
    int? dayNumber,
    String? mission,
    String? description,
    MissionDifficulty? difficulty,
    int? estimatedMinutes,
    List<String>? tips,
    DateTime? createdAt,
  }) {
    return QuestDayModel(
      qdid: qdid ?? this.qdid,
      qid: qid ?? this.qid,
      date: date ?? this.date,
      dayNumber: dayNumber ?? this.dayNumber,
      mission: mission ?? this.mission,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      tips: tips ?? this.tips,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 유틸리티
  bool get isToday => DateUtils.isSameDay(date, DateTime.now());
  bool get isPast => date.isBefore(DateTime.now().subtract(Duration(days: 1)));
  bool get isFuture => date.isAfter(DateTime.now().add(Duration(days: 1)));
  String get formattedDate => '${date.year}/${date.month}/${date.day}';

  @override
  String toString() {
    return 'RoutineDayModel{qdid: $qdid, date: $formattedDate, mission: $mission}';
  }

  static MissionDifficulty toDifficulty(String? difficulty) {
    switch (difficulty) {
      case 'easy': return MissionDifficulty.easy;
      case 'medium': return MissionDifficulty.medium;
      case 'hard': return MissionDifficulty.hard;
      default: return MissionDifficulty.medium;
    }
  }
}
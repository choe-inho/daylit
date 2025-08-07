// 열거형들
enum RoutineStatus {
  creating('creating'),    // AI 생성 중
  active('active'),       // 진행 중
  paused('paused'),       // 일시 정지
  completed('completed'), // 완료
  failed('failed');       // 실패

  const RoutineStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case RoutineStatus.creating: return '생성 중';
      case RoutineStatus.active: return '진행 중';
      case RoutineStatus.paused: return '일시 정지';
      case RoutineStatus.completed: return '완료';
      case RoutineStatus.failed: return '실패';
    }
  }
}

enum MissionDifficulty {
  easy('easy'),
  medium('medium'),
  hard('hard');

  const MissionDifficulty(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case MissionDifficulty.easy: return '쉬움';
      case MissionDifficulty.medium: return '보통';
      case MissionDifficulty.hard: return '어려움';
    }
  }
}

enum RecordStatus {
  success('success'),     // 성공
  failed('failed'),       // 실패
  skipped('skipped'),     // 건너뜀
  partial('partial');     // 부분 완료

  const RecordStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case RecordStatus.success: return '성공';
      case RecordStatus.failed: return '실패';
      case RecordStatus.skipped: return '건너뜀';
      case RecordStatus.partial: return '부분 완료';
    }
  }
}
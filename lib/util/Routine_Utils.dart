import 'package:hive/hive.dart'; // 🚀 Hive 추가

part 'Routine_Utils.g.dart'; // 🚀 build_runner로 생성될 파일

// ==================== 🚀 루틴 상태 enum (Hive 캐시 지원) ====================
/// 루틴 상태 enum
@HiveType(typeId: 1) // 🚀 Hive 타입 어노테이션 (QuestModel은 0번이므로 1번 사용)
enum RoutineStatus {
  @HiveField(0)
  creating('creating'),     // AI 생성 중

  @HiveField(1)
  active('active'),         // 활성 상태

  @HiveField(2)
  paused('paused'),         // 일시정지

  @HiveField(3)
  completed('completed'),   // 완료

  @HiveField(4)
  failed('failed'),         // 실패

  @HiveField(5)
  cancelled('cancelled');   // 취소

  const RoutineStatus(this.value);
  final String value;

  /// 문자열에서 RoutineStatus 변환
  static RoutineStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'creating':
        return RoutineStatus.creating;
      case 'active':
        return RoutineStatus.active;
      case 'paused':
        return RoutineStatus.paused;
      case 'completed':
        return RoutineStatus.completed;
      case 'failed':
        return RoutineStatus.failed;
      case 'cancelled':
        return RoutineStatus.cancelled;
      default:
        return RoutineStatus.active; // 기본값
    }
  }

  /// 표시용 문자열
  String get displayName {
    switch (this) {
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

  /// 상태에 따른 색상 (UI용)
  String get colorHex {
    switch (this) {
      case RoutineStatus.creating:
        return '#FFA500'; // 주황색
      case RoutineStatus.active:
        return '#4CAF50'; // 초록색
      case RoutineStatus.paused:
        return '#FF9800'; // 노란색
      case RoutineStatus.completed:
        return '#2196F3'; // 파란색
      case RoutineStatus.failed:
        return '#F44336'; // 빨간색
      case RoutineStatus.cancelled:
        return '#9E9E9E'; // 회색
    }
  }

  /// 상태 아이콘 (UI용)
  String get iconName {
    switch (this) {
      case RoutineStatus.creating:
        return 'auto_awesome'; // AI 생성 중
      case RoutineStatus.active:
        return 'play_circle'; // 진행 중
      case RoutineStatus.paused:
        return 'pause_circle'; // 일시정지
      case RoutineStatus.completed:
        return 'check_circle'; // 완료
      case RoutineStatus.failed:
        return 'error'; // 실패
      case RoutineStatus.cancelled:
        return 'cancel'; // 취소
    }
  }

  /// 상태가 활성 상태인지 확인
  bool get isActive => this == RoutineStatus.active;

  /// 상태가 완료 상태인지 확인
  bool get isCompleted => this == RoutineStatus.completed;

  /// 상태가 진행 중인지 확인 (creating, active, paused)
  bool get isInProgress =>
      this == RoutineStatus.creating ||
          this == RoutineStatus.active ||
          this == RoutineStatus.paused;

  /// 상태가 종료된 상태인지 확인 (completed, failed, cancelled)
  bool get isFinished =>
      this == RoutineStatus.completed ||
          this == RoutineStatus.failed ||
          this == RoutineStatus.cancelled;
}

// ==================== 🚀 퀘스트 기록 상태 enum ====================
/// 퀘스트 실행 기록 상태
@HiveType(typeId: 2)
enum RecordStatus {
  @HiveField(0)
  success('success'),       // 성공

  @HiveField(1)
  failed('failed'),         // 실패

  @HiveField(2)
  skipped('skipped'),       // 건너뜀

  @HiveField(3)
  partial('partial');       // 부분 완료

  const RecordStatus(this.value);
  final String value;

  /// 문자열에서 RecordStatus 변환
  static RecordStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'success':
        return RecordStatus.success;
      case 'failed':
        return RecordStatus.failed;
      case 'skipped':
        return RecordStatus.skipped;
      case 'partial':
        return RecordStatus.partial;
      default:
        return RecordStatus.failed; // 기본값
    }
  }

  /// 표시용 문자열
  String get displayName {
    switch (this) {
      case RecordStatus.success:
        return '성공';
      case RecordStatus.failed:
        return '실패';
      case RecordStatus.skipped:
        return '건너뜀';
      case RecordStatus.partial:
        return '부분 완료';
    }
  }

  /// 상태에 따른 색상 (UI용)
  String get colorHex {
    switch (this) {
      case RecordStatus.success:
        return '#4CAF50'; // 초록색
      case RecordStatus.partial:
        return '#FF9800'; // 주황색
      case RecordStatus.skipped:
        return '#9E9E9E'; // 회색
      case RecordStatus.failed:
        return '#F44336'; // 빨간색
    }
  }

  /// 상태 아이콘 (UI용)
  String get iconName {
    switch (this) {
      case RecordStatus.success:
        return 'check_circle';
      case RecordStatus.partial:
        return 'radio_button_checked';
      case RecordStatus.skipped:
        return 'skip_next';
      case RecordStatus.failed:
        return 'cancel';
    }
  }

  /// 성공한 기록인지 확인
  bool get isSuccess => this == RecordStatus.success;

  /// 실패한 기록인지 확인
  bool get isFailed => this == RecordStatus.failed;

  /// 건너뛴 기록인지 확인
  bool get isSkipped => this == RecordStatus.skipped;

  /// 부분 완료 기록인지 확인
  bool get isPartial => this == RecordStatus.partial;

  /// 점수 계산용 가중치
  double get scoreWeight {
    switch (this) {
      case RecordStatus.success:
        return 1.0;
      case RecordStatus.partial:
        return 0.5;
      case RecordStatus.skipped:
        return 0.0;
      case RecordStatus.failed:
        return 0.0;
    }
  }
}

// ==================== 🚀 미션 난이도 enum ====================
/// 미션 난이도
@HiveType(typeId: 3)
enum MissionDifficulty {
  @HiveField(0)
  easy('easy'),       // 쉬움

  @HiveField(1)
  medium('medium'),   // 보통

  @HiveField(2)
  hard('hard');       // 어려움

  const MissionDifficulty(this.value);
  final String value;

  /// 문자열에서 MissionDifficulty 변환
  static MissionDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'easy':
        return MissionDifficulty.easy;
      case 'medium':
        return MissionDifficulty.medium;
      case 'hard':
        return MissionDifficulty.hard;
      default:
        return MissionDifficulty.medium; // 기본값
    }
  }

  /// 표시용 문자열
  String get displayName {
    switch (this) {
      case MissionDifficulty.easy:
        return '쉬움';
      case MissionDifficulty.medium:
        return '보통';
      case MissionDifficulty.hard:
        return '어려움';
    }
  }

  /// 난이도별 색상
  String get colorHex {
    switch (this) {
      case MissionDifficulty.easy:
        return '#4CAF50'; // 초록색
      case MissionDifficulty.medium:
        return '#FF9800'; // 주황색
      case MissionDifficulty.hard:
        return '#F44336'; // 빨간색
    }
  }

  /// 난이도별 예상 시간 (분)
  int get estimatedMinutes {
    switch (this) {
      case MissionDifficulty.easy:
        return 15;
      case MissionDifficulty.medium:
        return 30;
      case MissionDifficulty.hard:
        return 60;
    }
  }
}

// ==================== 헬퍼 함수들 ====================
/// 문자열을 RoutineStatus로 변환하는 헬퍼 함수
RoutineStatus toRoutineStatus(String? value) {
  if (value == null) return RoutineStatus.active;
  return RoutineStatus.fromString(value);
}

/// 문자열을 RecordStatus로 변환하는 헬퍼 함수
RecordStatus toRecordStatus(String? value) {
  if (value == null) return RecordStatus.failed;
  return RecordStatus.fromString(value);
}

/// 문자열을 MissionDifficulty로 변환하는 헬퍼 함수
MissionDifficulty toMissionDifficulty(String? value) {
  if (value == null) return MissionDifficulty.medium;
  return MissionDifficulty.fromString(value);
}

/// RoutineStatus를 문자열로 변환하는 헬퍼 함수
String routineStatusToString(RoutineStatus status) {
  return status.value;
}

/// RecordStatus를 문자열로 변환하는 헬퍼 함수
String recordStatusToString(RecordStatus status) {
  return status.value;
}

/// 모든 RoutineStatus 목록 반환
List<RoutineStatus> getAllRoutineStatuses() {
  return RoutineStatus.values;
}

/// 모든 RecordStatus 목록 반환
List<RecordStatus> getAllRecordStatuses() {
  return RecordStatus.values;
}

/// 진행 중인 상태들만 반환
List<RoutineStatus> getInProgressStatuses() {
  return RoutineStatus.values.where((status) => status.isInProgress).toList();
}

/// 완료된 상태들만 반환
List<RoutineStatus> getFinishedStatuses() {
  return RoutineStatus.values.where((status) => status.isFinished).toList();
}

// ==================== 기타 유틸리티 함수들 ====================
/// 상태 변경 가능 여부 확인
bool canChangeStatus(RoutineStatus from, RoutineStatus to) {
  // 완료된 상태에서는 변경 불가
  if (from.isFinished && to != RoutineStatus.active) {
    return false;
  }

  // 생성 중에서는 활성 또는 취소만 가능
  if (from == RoutineStatus.creating) {
    return to == RoutineStatus.active || to == RoutineStatus.cancelled;
  }

  return true;
}

/// 다음 가능한 상태들 반환
List<RoutineStatus> getNextPossibleStatuses(RoutineStatus current) {
  switch (current) {
    case RoutineStatus.creating:
      return [RoutineStatus.active, RoutineStatus.cancelled];
    case RoutineStatus.active:
      return [RoutineStatus.paused, RoutineStatus.completed, RoutineStatus.failed, RoutineStatus.cancelled];
    case RoutineStatus.paused:
      return [RoutineStatus.active, RoutineStatus.cancelled];
    case RoutineStatus.completed:
    case RoutineStatus.failed:
    case RoutineStatus.cancelled:
      return [RoutineStatus.active]; // 재시작만 가능
  }
}
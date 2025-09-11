// ==================== 열거형들 ====================

/// 루틴 상태 (SQL 스키마와 일치)
enum RoutineStatus {
  creating('creating'),    // AI 생성 중
  active('active'),       // 진행 중
  paused('paused'),       // 일시 정지
  completed('completed'), // 완료
  failed('failed'),       // 실패
  cancelled('cancelled'); // 취소됨

  const RoutineStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case RoutineStatus.creating: return 'AI 생성 중';
      case RoutineStatus.active: return '진행 중';
      case RoutineStatus.paused: return '일시정지';
      case RoutineStatus.completed: return '완료';
      case RoutineStatus.failed: return '실패';
      case RoutineStatus.cancelled: return '취소됨';
    }
  }

  /// 상태 아이콘
  String get icon {
    switch (this) {
      case RoutineStatus.creating: return '🔄';
      case RoutineStatus.active: return '🎯';
      case RoutineStatus.paused: return '⏸️';
      case RoutineStatus.completed: return '✅';
      case RoutineStatus.failed: return '❌';
      case RoutineStatus.cancelled: return '🚫';
    }
  }

  /// 상태별 색상 (Material Colors)
  String get colorHex {
    switch (this) {
      case RoutineStatus.creating: return '#FF9800'; // Orange
      case RoutineStatus.active: return '#4CAF50';   // Green
      case RoutineStatus.paused: return '#FFC107';   // Amber
      case RoutineStatus.completed: return '#2196F3'; // Blue
      case RoutineStatus.failed: return '#F44336';   // Red
      case RoutineStatus.cancelled: return '#9E9E9E'; // Grey
    }
  }

  /// 완료 상태인지 확인
  bool get isFinished => this == RoutineStatus.completed ||
      this == RoutineStatus.failed ||
      this == RoutineStatus.cancelled;

  /// 진행 가능한 상태인지 확인
  bool get isProgressive => this == RoutineStatus.active;

  /// 수정 가능한 상태인지 확인
  bool get isEditable => this == RoutineStatus.creating ||
      this == RoutineStatus.paused;
}

/// 미션 난이도
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

  /// 난이도별 아이콘
  String get icon {
    switch (this) {
      case MissionDifficulty.easy: return '🟢';
      case MissionDifficulty.medium: return '🟡';
      case MissionDifficulty.hard: return '🔴';
    }
  }

  /// 난이도별 색상
  String get colorHex {
    switch (this) {
      case MissionDifficulty.easy: return '#4CAF50';   // Green
      case MissionDifficulty.medium: return '#FF9800'; // Orange
      case MissionDifficulty.hard: return '#F44336';   // Red
    }
  }

  /// 예상 소요 시간 배수
  double get timeMultiplier {
    switch (this) {
      case MissionDifficulty.easy: return 0.8;
      case MissionDifficulty.medium: return 1.0;
      case MissionDifficulty.hard: return 1.5;
    }
  }
}

/// 실행 기록 상태
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

  /// 기록별 아이콘
  String get icon {
    switch (this) {
      case RecordStatus.success: return '✅';
      case RecordStatus.failed: return '❌';
      case RecordStatus.skipped: return '⏭️';
      case RecordStatus.partial: return '🔶';
    }
  }

  /// 기록별 색상
  String get colorHex {
    switch (this) {
      case RecordStatus.success: return '#4CAF50';   // Green
      case RecordStatus.failed: return '#F44336';    // Red
      case RecordStatus.skipped: return '#9E9E9E';   // Grey
      case RecordStatus.partial: return '#FF9800';   // Orange
    }
  }

  /// 성공적인 기록인지 확인
  bool get isSuccessful => this == RecordStatus.success ||
      this == RecordStatus.partial;
}

// ==================== 변환 유틸리티 함수들 ====================

/// 문자열을 RoutineStatus로 변환
RoutineStatus toRoutineStatus(String? status) {
  switch (status) {
    case 'creating': return RoutineStatus.creating;
    case 'active': return RoutineStatus.active;
    case 'paused': return RoutineStatus.paused;
    case 'completed': return RoutineStatus.completed;
    case 'failed': return RoutineStatus.failed;
    case 'cancelled': return RoutineStatus.cancelled;
    default: return RoutineStatus.creating;
  }
}

/// 문자열을 MissionDifficulty로 변환
MissionDifficulty toDifficulty(String? difficulty) {
  switch (difficulty) {
    case 'easy': return MissionDifficulty.easy;
    case 'medium': return MissionDifficulty.medium;
    case 'hard': return MissionDifficulty.hard;
    default: return MissionDifficulty.medium;
  }
}

/// 문자열을 RecordStatus로 변환
RecordStatus toRecordStatus(String? status) {
  switch (status) {
    case 'success': return RecordStatus.success;
    case 'failed': return RecordStatus.failed;
    case 'skipped': return RecordStatus.skipped;
    case 'partial': return RecordStatus.partial;
    default: return RecordStatus.failed;
  }
}

// ==================== 유틸리티 클래스 ====================

/// 루틴 관련 유틸리티 함수들
class RoutineUtils {
  RoutineUtils._(); // private constructor

  /// 루틴 상태별 진행률 계산
  static double calculateProgress({
    required RoutineStatus status,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? completedAt,
  }) {
    final now = DateTime.now();

    switch (status) {
      case RoutineStatus.completed:
        return 1.0;
      case RoutineStatus.failed:
      case RoutineStatus.cancelled:
        return 0.0;
      case RoutineStatus.creating:
        return 0.0;
      case RoutineStatus.active:
      case RoutineStatus.paused:
        if (now.isBefore(startDate)) return 0.0;
        if (now.isAfter(endDate)) return 1.0;

        final totalDays = endDate.difference(startDate).inDays + 1;
        final elapsedDays = now.difference(startDate).inDays + 1;
        return (elapsedDays / totalDays).clamp(0.0, 1.0);
    }
  }

  /// 루틴 비용 계산 (하루당 10릿 기본)
  static int calculateCost(int days, {int dailyRate = 10}) {
    return days * dailyRate;
  }

  /// 루틴 기간 검증
  static bool isValidDuration(int days) {
    return days > 0 && days <= 365; // 1일 ~ 1년
  }

  /// 루틴 시작일 검증 (오늘 이후만 가능)
  static bool isValidStartDate(DateTime startDate) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);

    return startDateOnly.isAfter(todayStart) || startDateOnly.isAtSameMomentAs(todayStart);
  }

  /// 추천 루틴 기간 (목적별)
  static int getRecommendedDays(String purpose) {
    final lowerPurpose = purpose.toLowerCase();

    // 운동 관련
    if (lowerPurpose.contains('운동') || lowerPurpose.contains('조깅') ||
        lowerPurpose.contains('헬스') || lowerPurpose.contains('요가')) {
      return 30;
    }

    // 학습 관련
    if (lowerPurpose.contains('공부') || lowerPurpose.contains('학습') ||
        lowerPurpose.contains('독서') || lowerPurpose.contains('영어')) {
      return 60;
    }

    // 습관 개선 관련
    if (lowerPurpose.contains('금연') || lowerPurpose.contains('금주') ||
        lowerPurpose.contains('다이어트')) {
      return 90;
    }

    // 기본값
    return 21; // 21일 법칙
  }

  /// 상태 변경 가능성 검증
  static bool canChangeStatus(RoutineStatus from, RoutineStatus to) {
    switch (from) {
      case RoutineStatus.creating:
        return to == RoutineStatus.active || to == RoutineStatus.cancelled;

      case RoutineStatus.active:
        return to == RoutineStatus.paused ||
            to == RoutineStatus.completed ||
            to == RoutineStatus.failed ||
            to == RoutineStatus.cancelled;

      case RoutineStatus.paused:
        return to == RoutineStatus.active ||
            to == RoutineStatus.cancelled;

      case RoutineStatus.completed:
      case RoutineStatus.failed:
      case RoutineStatus.cancelled:
        return false; // 완료된 상태는 변경 불가
    }
  }
}
import 'package:flutter/material.dart';
import 'picker/DateTime_Picker.dart';

/// 앱 전체에서 사용되는 피커들을 관리하는 핸들러
///
/// 다양한 피커(DateTime, Color, File 등)들의 표준화된 인터페이스를 제공합니다.
/// 모든 피커는 일관된 디자인과 동작을 보장합니다.
class PickerHandler {
  PickerHandler._();

  // ==================== DateTime 피커 ====================

  /// 날짜 선택 피커 표시
  ///
  /// [context] BuildContext
  /// [initialDate] 초기 선택 날짜 (기본값: 오늘)
  /// [firstDate] 선택 가능한 최소 날짜 (기본값: 100년 전)
  /// [lastDate] 선택 가능한 최대 날짜 (기본값: 100년 후)
  /// [title] 피커 제목 (기본값: '날짜 선택')
  /// [confirmText] 확인 버튼 텍스트 (기본값: '완료')
  /// [cancelText] 취소 버튼 텍스트 (기본값: '취소')
  /// [isDismissible] 외부 터치로 닫기 가능 여부 (기본값: true)
  ///
  /// Returns: 선택된 날짜 (취소시 null)
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
    String? confirmText,
    String? cancelText,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => DateTimePicker(
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 36500)), // 100년 전
        lastDate: lastDate ?? DateTime.now().add(const Duration(days: 36500)), // 100년 후
        title: title,
        confirmText: confirmText,
        cancelText: cancelText,
        mode: DateTimePickerMode.date,
      ),
    );
  }

  /// 시간 선택 피커 표시
  ///
  /// [context] BuildContext
  /// [initialTime] 초기 선택 시간 (기본값: 현재 시간)
  /// [title] 피커 제목 (기본값: '시간 선택')
  /// [confirmText] 확인 버튼 텍스트 (기본값: '완료')
  /// [cancelText] 취소 버튼 텍스트 (기본값: '취소')
  /// [isDismissible] 외부 터치로 닫기 가능 여부 (기본값: true)
  /// [use24HourFormat] 24시간 형식 사용 여부 (기본값: true)
  ///
  /// Returns: 선택된 시간 (취소시 null)
  static Future<TimeOfDay?> showTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
    String? title,
    String? confirmText,
    String? cancelText,
    bool isDismissible = true,
    bool use24HourFormat = true,
  }) {
    final now = DateTime.now();
    final initialDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      initialTime?.hour ?? now.hour,
      initialTime?.minute ?? now.minute,
    );

    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => DateTimePicker(
        initialDate: initialDateTime,
        firstDate: initialDateTime,
        lastDate: initialDateTime,
        title: title,
        confirmText: confirmText,
        cancelText: cancelText,
        mode: DateTimePickerMode.time,
        use24HourFormat: use24HourFormat,
      ),
    );
  }

  /// 날짜와 시간 선택 피커 표시
  ///
  /// [context] BuildContext
  /// [initialDateTime] 초기 선택 날짜시간 (기본값: 현재)
  /// [firstDate] 선택 가능한 최소 날짜 (기본값: 100년 전)
  /// [lastDate] 선택 가능한 최대 날짜 (기본값: 100년 후)
  /// [title] 피커 제목 (기본값: '날짜 시간 선택')
  /// [confirmText] 확인 버튼 텍스트 (기본값: '완료')
  /// [cancelText] 취소 버튼 텍스트 (기본값: '취소')
  /// [isDismissible] 외부 터치로 닫기 가능 여부 (기본값: true)
  /// [use24HourFormat] 24시간 형식 사용 여부 (기본값: true)
  ///
  /// Returns: 선택된 날짜시간 (취소시 null)
  static Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
    String? confirmText,
    String? cancelText,
    bool isDismissible = true,
    bool use24HourFormat = true,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => DateTimePicker(
        initialDate: initialDateTime ?? DateTime.now(),
        firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 36500)),
        lastDate: lastDate ?? DateTime.now().add(const Duration(days: 36500)),
        title: title,
        confirmText: confirmText,
        cancelText: cancelText,
        mode: DateTimePickerMode.dateTime,
        use24HourFormat: use24HourFormat,
      ),
    );
  }

  /// 기간 선택 피커 표시
  ///
  /// [context] BuildContext
  /// [initialStartDate] 초기 시작 날짜
  /// [initialEndDate] 초기 종료 날짜
  /// [firstDate] 선택 가능한 최소 날짜
  /// [lastDate] 선택 가능한 최대 날짜
  /// [maxRangeDays] 최대 선택 가능 기간 (일 단위, 기본값: 365일)
  /// [title] 피커 제목 (기본값: '기간 선택')
  /// [confirmText] 확인 버튼 텍스트 (기본값: '완료')
  /// [cancelText] 취소 버튼 텍스트 (기본값: '취소')
  /// [isDismissible] 외부 터치로 닫기 가능 여부 (기본값: true)
  ///
  /// Returns: 선택된 기간 {start, end} (취소시 null)
  static Future<DateRange?> showDateRangePicker({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DateTime? firstDate,
    DateTime? lastDate,
    int maxRangeDays = 365,
    String? title,
    String? confirmText,
    String? cancelText,
    bool isDismissible = true,
  }) {
    // 초기 종료 날짜가 최대 기간을 넘지 않도록 조정
    final startDate = initialStartDate ?? DateTime.now();
    final maxEndDate = startDate.add(Duration(days: maxRangeDays));
    final adjustedEndDate = initialEndDate != null && initialEndDate.isAfter(maxEndDate)
        ? maxEndDate
        : initialEndDate;

    return showModalBottomSheet<DateRange>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => DateTimePicker(
        initialDate: startDate,
        secondaryDate: adjustedEndDate,
        firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 36500)),
        lastDate: lastDate ?? DateTime.now().add(const Duration(days: 36500)),
        maxRangeDays: maxRangeDays,
        title: title,
        confirmText: confirmText,
        cancelText: cancelText,
        mode: DateTimePickerMode.dateRange,
      ),
    );
  }

  // ==================== 편의 함수들 ====================

  /// 퀘스트 종료일 선택 피커
  ///
  /// 퀘스트 생성 시 사용하는 특화된 날짜 선택 피커
  /// 최대 1년(365일) 기간으로 제한됩니다.
  static Future<DateTime?> showQuestEndDatePicker({
    required BuildContext context,
    DateTime? currentEndDate,
    int? questDuration,
  }) {
    final startDate = DateTime.now();
    final maxDate = startDate.add(const Duration(days: 365)); // 1년 제한
    final suggestedEndDate = questDuration != null
        ? startDate.add(Duration(days: questDuration - 1))
        : currentEndDate;

    // 제안된 종료일이 1년을 넘으면 조정
    final finalSuggestedDate = suggestedEndDate != null && suggestedEndDate.isAfter(maxDate)
        ? maxDate
        : suggestedEndDate ?? startDate.add(const Duration(days: 30));

    return showDatePicker(
      context: context,
      initialDate: finalSuggestedDate,
      firstDate: startDate,
      lastDate: maxDate, // 1년 후까지만
      title: '퀘스트 종료일 선택 (최대 1년)',
      confirmText: '완료',
      cancelText: '취소',
    );
  }

  /// 루틴 시작 시간 선택 피커
  ///
  /// 루틴 설정 시 사용하는 특화된 시간 선택 피커
  static Future<TimeOfDay?> showRoutineTimePicker({
    required BuildContext context,
    TimeOfDay? currentTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: currentTime ?? const TimeOfDay(hour: 9, minute: 0),
      title: '루틴 시작 시간',
      confirmText: '완료',
      cancelText: '취소',
      use24HourFormat: false, // 루틴은 12시간 형식이 더 직관적
    );
  }

  /// 목표 달성 기한 선택 피커
  ///
  /// 목표 설정 시 사용하는 특화된 날짜 선택 피커
  static Future<DateTime?> showGoalDeadlinePicker({
    required BuildContext context,
    DateTime? currentDeadline,
  }) {
    final today = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: currentDeadline ?? today.add(const Duration(days: 30)),
      firstDate: today.add(const Duration(days: 1)), // 내일부터
      lastDate: today.add(const Duration(days: 365 * 2)), // 2년 후까지
      title: '목표 달성 기한',
      confirmText: '설정',
      cancelText: '취소',
    );
  }

  // ==================== 유틸리티 함수들 ====================

  /// 날짜 범위가 유효한지 확인
  static bool isValidDateRange(DateTime startDate, DateTime endDate) {
    return startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);
  }

  /// 두 날짜 사이의 일수 계산
  static int daysBetween(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  /// 날짜 범위가 최대 기간 내에 있는지 확인
  static bool isWithinMaxRange(DateTime startDate, DateTime endDate, int maxDays) {
    final daysDifference = daysBetween(startDate, endDate);
    return daysDifference <= maxDays;
  }

  /// 날짜가 범위 내에 있는지 확인
  static bool isDateInRange(DateTime date, DateTime firstDate, DateTime lastDate) {
    return (date.isAfter(firstDate) || date.isAtSameMomentAs(firstDate)) &&
        (date.isBefore(lastDate) || date.isAtSameMomentAs(lastDate));
  }

  /// 디버그 로깅
  static void _logInfo(String message) {
    debugPrint('📅 [PickerHandler] $message');
  }
}

/// 날짜 범위 데이터 클래스
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  /// 기간 일수 계산
  int get days => end.difference(start).inDays + 1;

  /// 범위가 유효한지 확인
  bool get isValid => start.isBefore(end) || start.isAtSameMomentAs(end);

  /// 지정된 최대 일수 내에 있는지 확인
  bool isWithinMaxDays(int maxDays) => days <= maxDays;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange(start: $start, end: $end)';

  /// 범위를 문자열로 포맷
  String format([String separator = ' ~ ']) {
    return '${_formatDate(start)}$separator${_formatDate(end)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
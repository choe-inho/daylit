// DateTimeUtils와 DateUtils 클래스 (이전에 정의한 것 사용)
class DateTimeUtils {
  static String toUtcString(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  static DateTime? fromUtcString(String? dateTimeString) {
    if (dateTimeString == null) return null;
    final utcDateTime = DateTime.tryParse(dateTimeString);
    return utcDateTime?.toLocal();
  }
}

class DateUtils {
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
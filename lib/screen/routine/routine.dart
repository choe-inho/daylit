import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../util/daylitColors.dart';
import '../../widget/daylitIconButton.dart';

class Routine extends StatefulWidget {
  const Routine({super.key});

  @override
  State<Routine> createState() => _RoutineState();
}

class _RoutineState extends State<Routine> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  DateTime _selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);
    final theme = Theme.of(context);
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 상단 앱바
        SliverAppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          pinned: false,
          floating: true,
          snap: false,
          title: Text(
            '루틴',
            style: theme.textTheme.headlineSmall),
          centerTitle: false,
          actions: [
            DaylitIconButton(
              onPressed: () => _showCalendarOptions(context),
              iconData: LucideIcons.calendar,
            ),
            DaylitIconButton(
              onPressed: () => _showRoutineSettings(context),
              iconData: LucideIcons.settings,
            ),
          ],
        ),

        // 동적 달력 (pinned)
        SliverPersistentHeader(
          pinned: true,
          delegate: CalendarHeaderDelegate(
            minHeight: 80.h,
            maxHeight: 320.h,
            selectedDate: _selectedDate,
            scrollOffset: _scrollOffset,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ),

        // 선택된 날짜 정보
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          sliver: SliverToBoxAdapter(
            child: _buildDateInfo(colors),
          ),
        ),

        // 달성 목록 또는 빈 상태
        _buildRoutineList(colors),
        
        //바텀네비게이션 여백
        SliverPadding(padding: EdgeInsetsGeometry.only(bottom: 150))
      ],
    );
  }

  Widget _buildDateInfo(dynamic colors) {
    final dateStr = '${_selectedDate.month}월 ${_selectedDate.day}일';
    final dayOfWeek = ['월', '화', '수', '목', '금', '토', '일'][_selectedDate.weekday - 1];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.calendar,
            color: DaylitColors.brandPrimary,
            size: 20.r,
          ),
          SizedBox(width: 8.w),
          Text(
            '$dateStr ($dayOfWeek)',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              fontFamily: 'pre',
            ),
          ),
          const Spacer(),
          _buildCompletionBadge(colors),
        ],
      ),
    );
  }

  Widget _buildCompletionBadge(dynamic colors) {
    final completedCount = _getCompletedRoutines(_selectedDate).length;
    final totalCount = _getTotalRoutines(_selectedDate).length;
    final completionRate = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    Color badgeColor;
    String badgeText;

    if (completionRate == 1.0) {
      badgeColor = DaylitColors.success;
      badgeText = '완료';
    } else if (completionRate >= 0.5) {
      badgeColor = DaylitColors.warning;
      badgeText = '진행중';
    } else {
      badgeColor = colors.textSecondary;
      badgeText = '시작전';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        '$completedCount/$totalCount $badgeText',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: badgeColor,
          fontFamily: 'pre',
        ),
      ),
    );
  }

  Widget _buildRoutineList(dynamic colors) {
    final routines = _getRoutinesForDate(_selectedDate);

    if (routines.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyRoutineWidget(
          selectedDate: _selectedDate,
          onAddRoutine: _showAddRoutineDialog,
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList.builder(
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: RoutineAchievementCard(
              routine: routine,
              onToggleComplete: () => _toggleRoutineComplete(routine.id),
            ),
          );
        },
      ),
    );
  }

  void _showCalendarOptions(BuildContext context) {
    // 달력 옵션 (월간/주간 보기 등)
  }

  void _showRoutineSettings(BuildContext context) {
    // 루틴 설정
  }

  void _showAddRoutineDialog() {
    // 루틴 추가 다이얼로그
  }

  void _toggleRoutineComplete(String routineId) {
    setState(() {
      // 루틴 완료 상태 토글 로직
    });
  }

  // 더미 데이터 함수들
  List<RoutineItem> _getRoutinesForDate(DateTime date) {
    // 실제로는 데이터베이스나 상태 관리에서 가져올 데이터
    return _mockRoutines;
  }

  List<RoutineItem> _getCompletedRoutines(DateTime date) {
    return _getRoutinesForDate(date).where((r) => r.isCompleted).toList();
  }

  List<RoutineItem> _getTotalRoutines(DateTime date) {
    return _getRoutinesForDate(date);
  }

  // 더미 데이터
  final List<RoutineItem> _mockRoutines = [
    RoutineItem(
      id: '1',
      title: '30분 러닝',
      description: '아침 운동으로 하루를 시작해보세요',
      time: '오전 7:30',
      isCompleted: true,
      category: RoutineCategory.exercise,
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    RoutineItem(
      id: '2',
      title: '물 8잔 마시기',
      description: '하루 권장 수분 섭취량을 채워보세요',
      time: '하루 종일',
      isCompleted: false,
      category: RoutineCategory.health,
    ),
    RoutineItem(
      id: '3',
      title: '독서 30분',
      description: '새로운 지식을 습득하는 시간',
      time: '오후 9:00',
      isCompleted: false,
      category: RoutineCategory.learning,
    ),
  ];
}

// 달력 타입 열거형
enum CalendarType { monthly, biweekly, weekly }

// 루틴 카테고리
enum RoutineCategory { exercise, health, learning, work, lifestyle }

// 루틴 아이템 모델
class RoutineItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isCompleted;
  final RoutineCategory category;
  final DateTime? completedAt;

  RoutineItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isCompleted,
    required this.category,
    this.completedAt,
  });
}

// 달력 헤더 델리게이트
class CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final DateTime selectedDate;
  final double scrollOffset;
  final Function(DateTime) onDateSelected;

  CalendarHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.selectedDate,
    required this.scrollOffset,
    required this.onDateSelected,
  });

  CalendarType get _calendarType {
    if (scrollOffset < 100) {
      return CalendarType.monthly;
    } else if (scrollOffset < 200) {
      return CalendarType.biweekly;
    } else {
      return CalendarType.weekly;
    }
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxHeight - minHeight)).clamp(0.0, 1.0);
    final colors = DaylitColors.of(context);

    // 현재 높이 계산
    final currentHeight = maxHeight - shrinkOffset;
    final clampedHeight = currentHeight.clamp(minHeight, maxHeight);

    return Container(
      height: clampedHeight,
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: progress > 0.5 ? [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildCalendar(context, progress),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, double progress) {
    final calendarType = _calendarType;

    switch (calendarType) {
      case CalendarType.monthly:
        return MonthlyCalendar(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
          progress: progress,
        );
      case CalendarType.biweekly:
        return BiweeklyCalendar(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
          progress: progress,
        );
      case CalendarType.weekly:
        return WeeklyCalendar(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
          progress: progress,
        );
    }
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant CalendarHeaderDelegate oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.selectedDate != selectedDate;
  }
}

// 루틴 달성 카드 위젯
class RoutineAchievementCard extends StatelessWidget {
  final RoutineItem routine;
  final VoidCallback onToggleComplete;

  const RoutineAchievementCard({
    super.key,
    required this.routine,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽 타임라인
          Column(
            children: [
              // 시간 표시
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: routine.isCompleted
                      ? DaylitColors.brandPrimary.withValues(alpha: 0.1)
                      : colors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  routine.time,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: routine.isCompleted
                        ? DaylitColors.brandPrimary
                        : colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              // 타임라인 점
              GestureDetector(
                onTap: onToggleComplete,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: routine.isCompleted
                        ? DaylitColors.brandPrimary
                        : colors.surface,
                    border: Border.all(
                      color: routine.isCompleted
                          ? DaylitColors.brandPrimary
                          : colors.border,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: routine.isCompleted ? [
                      BoxShadow(
                        color: DaylitColors.brandPrimary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: routine.isCompleted
                      ? Icon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 12.r,
                  )
                      : null,
                ),
              ),
              // 타임라인 선
              Container(
                width: 2.w,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      routine.isCompleted
                          ? DaylitColors.brandPrimary
                          : colors.textSecondary,
                      (routine.isCompleted
                          ? DaylitColors.brandPrimary
                          : colors.textSecondary).withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          // 오른쪽 콘텐츠
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: routine.isCompleted
                      ? DaylitColors.brandPrimary.withValues(alpha: 0.3)
                      : colors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: routine.isCompleted
                        ? DaylitColors.brandPrimary.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(routine.category),
                        color: _getCategoryColor(routine.category),
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          routine.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: colors.textPrimary,
                            decoration: routine.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontFamily: 'pre',
                          ),
                        ),
                      ),
                      if (routine.isCompleted && routine.completedAt != null)
                        Text(
                          '완료됨',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: DaylitColors.success,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'pre',
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    routine.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colors.textSecondary,
                      fontFamily: 'pre',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(RoutineCategory category) {
    switch (category) {
      case RoutineCategory.exercise:
        return LucideIcons.activity;
      case RoutineCategory.health:
        return LucideIcons.heart;
      case RoutineCategory.learning:
        return LucideIcons.bookOpen;
      case RoutineCategory.work:
        return LucideIcons.briefcase;
      case RoutineCategory.lifestyle:
        return LucideIcons.house;
    }
  }

  Color _getCategoryColor(RoutineCategory category) {
    switch (category) {
      case RoutineCategory.exercise:
        return DaylitColors.success;
      case RoutineCategory.health:
        return DaylitColors.error;
      case RoutineCategory.learning:
        return DaylitColors.brandPrimary;
      case RoutineCategory.work:
        return DaylitColors.warning;
      case RoutineCategory.lifestyle:
        return DaylitColors.brandSecondary;
    }
  }
}

// 빈 루틴 상태 위젯
class EmptyRoutineWidget extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onAddRoutine;

  const EmptyRoutineWidget({
    super.key,
    required this.selectedDate,
    required this.onAddRoutine,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);
    final isToday = DateTime.now().day == selectedDate.day &&
        DateTime.now().month == selectedDate.month &&
        DateTime.now().year == selectedDate.year;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.calendar,
              color: DaylitColors.brandPrimary,
              size: 40.r,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            isToday ? '오늘의 루틴이 없습니다' : '이 날의 루틴이 없습니다',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
              fontFamily: 'pre',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isToday
                ? '새로운 루틴을 추가하여 건강한 하루를 시작해보세요!'
                : '이 날짜에는 설정된 루틴이 없습니다.',
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.textSecondary,
              fontFamily: 'pre',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          if (isToday)
            ElevatedButton.icon(
              onPressed: onAddRoutine,
              style: ElevatedButton.styleFrom(
                backgroundColor: DaylitColors.brandPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(LucideIcons.plus, size: 20.r),
              label: Text(
                '루틴 추가하기',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'pre',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 달력 위젯들
class MonthlyCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final double progress;

  const MonthlyCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // 헤더 (년월 표시)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    final prevMonth = DateTime(selectedDate.year, selectedDate.month - 1);
                    onDateSelected(prevMonth);
                  },
                  icon: Icon(LucideIcons.chevronLeft, color: colors.textSecondary),
                ),
                Text(
                  '${selectedDate.year}년 ${selectedDate.month}월',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    fontFamily: 'pre',
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final nextMonth = DateTime(selectedDate.year, selectedDate.month + 1);
                    onDateSelected(nextMonth);
                  },
                  icon: Icon(LucideIcons.chevronRight, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          // 요일 헤더
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) =>
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                        fontFamily: 'pre',
                      ),
                    ),
                  ),
                ),
            ).toList(),
          ),
          SizedBox(height: 8.h),
          // 달력 그리드
          Expanded(
            child: _buildCalendarGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final colors = DaylitColors.of(context);
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final firstDayWeekday = DateTime(selectedDate.year, selectedDate.month, 1).weekday;
    final today = DateTime.now();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: 35, // 5주 표시
      itemBuilder: (context, index) {
        final dayIndex = index - (firstDayWeekday % 7) + 1;

        if (dayIndex < 1 || dayIndex > daysInMonth) {
          return const SizedBox(); // 빈 날짜
        }

        final date = DateTime(selectedDate.year, selectedDate.month, dayIndex);
        final isSelected = date.day == selectedDate.day &&
            date.month == selectedDate.month &&
            date.year == selectedDate.year;
        final isToday = date.day == today.day &&
            date.month == today.month &&
            date.year == today.year;

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? DaylitColors.brandPrimary
                  : isToday
                  ? DaylitColors.brandPrimary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: isToday && !isSelected
                  ? Border.all(color: DaylitColors.brandPrimary, width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                '$dayIndex',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? DaylitColors.brandPrimary
                      : colors.textPrimary,
                  fontFamily: 'pre',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BiweeklyCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final double progress;

  const BiweeklyCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            '${selectedDate.month}월 ${_getWeekRange()}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              fontFamily: 'pre',
            ),
          ),
          SizedBox(height: 12.h),
          // 2주간 날짜 표시
          Expanded(
            child: Column(
              children: [
                _buildWeekRow(context, 0),
                SizedBox(height: 8.h),
                _buildWeekRow(context, 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekRow(BuildContext context, int weekOffset) {
    final colors = DaylitColors.of(context);
    final startOfWeek = _getStartOfWeek(selectedDate).add(Duration(days: weekOffset * 7));

    return Row(
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isSelected = date.day == selectedDate.day &&
            date.month == selectedDate.month &&
            date.year == selectedDate.year;
        final isToday = _isToday(date);

        return Expanded(
          child: GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              height: 50.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? DaylitColors.brandPrimary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: isToday && !isSelected
                    ? Border.all(color: DaylitColors.brandPrimary)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['일', '월', '화', '수', '목', '금', '토'][index],
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSelected ? Colors.white : colors.textSecondary,
                      fontFamily: 'pre',
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? DaylitColors.brandPrimary
                          : colors.textPrimary,
                      fontFamily: 'pre',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  String _getWeekRange() {
    final start = _getStartOfWeek(selectedDate);
    final end = start.add(const Duration(days: 13));
    return '${start.day}일 - ${end.day}일';
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;
  }
}

class WeeklyCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final double progress;

  const WeeklyCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final startOfWeek = _getStartOfWeek(selectedDate);
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;
          final isToday = _isToday(date);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 40.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: isSelected ? DaylitColors.brandPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: isToday && !isSelected
                    ? Border.all(color: DaylitColors.brandPrimary)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['일', '월', '화', '수', '목', '금', '토'][index],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected ? Colors.white : colors.textSecondary,
                      fontFamily: 'pre',
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? DaylitColors.brandPrimary
                          : colors.textPrimary,
                      fontFamily: 'pre',
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;
  }
}
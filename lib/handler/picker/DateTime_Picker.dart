import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../../util/Daylit_Colors.dart';
import '../Picker_Handler.dart';

/// DateTime 피커 모드
enum DateTimePickerMode {
  date,        // 날짜만
  time,        // 시간만
  dateTime,    // 날짜 + 시간
  dateRange,   // 날짜 범위
}

/// DayLit 스타일의 DateTime 피커 위젯
///
/// 현대적인 디자인과 부드러운 애니메이션을 제공하는 날짜/시간 선택 위젯입니다.
/// iOS 스타일의 휠 피커를 사용하여 직관적인 사용자 경험을 제공합니다.
class DateTimePicker extends StatefulWidget {
  const DateTimePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.secondaryDate,
    this.maxRangeDays = 365,
    this.title,
    this.confirmText,
    this.cancelText,
    this.mode = DateTimePickerMode.date,
    this.use24HourFormat = true,
  });

  /// 초기 선택 날짜
  final DateTime initialDate;

  /// 선택 가능한 최소 날짜
  final DateTime firstDate;

  /// 선택 가능한 최대 날짜
  final DateTime lastDate;

  /// 보조 날짜 (범위 선택시 종료 날짜)
  final DateTime? secondaryDate;

  /// 최대 선택 가능 기간 (일 단위, 기본값: 365일)
  final int maxRangeDays;

  /// 피커 제목
  final String? title;

  /// 확인 버튼 텍스트
  final String? confirmText;

  /// 취소 버튼 텍스트
  final String? cancelText;

  /// 피커 모드
  final DateTimePickerMode mode;

  /// 24시간 형식 사용 여부
  final bool use24HourFormat;

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker>
    with TickerProviderStateMixin {

  // ==================== 상태 변수들 ====================

  late DateTime _selectedDate;
  late DateTime _selectedEndDate;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // 휠 피커 컨트롤러들
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController; // AM/PM

  // 범위 선택 관련
  bool _isSelectingStart = true;
  int _currentTabIndex = 0;

  // 날짜 범위 데이터
  List<int> _years = [];
  List<int> _months = [];
  List<int> _days = [];
  List<int> _hours = [];
  List<int> _minutes = [];

  @override
  void initState() {
    super.initState();
    _initializeState();
    _initializeAnimations();
    _initializeControllers();
  }

  /// 초기 상태 설정
  void _initializeState() {
    _selectedDate = widget.initialDate;
    _selectedEndDate = widget.secondaryDate ?? widget.initialDate.add(const Duration(days: 7));
    _generateDateRanges();
  }

  /// 애니메이션 초기화
  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  /// 피커 컨트롤러들 초기화
  void _initializeControllers() {
    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedDate.year),
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedDate.month - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: _selectedDate.day - 1,
    );

    if (widget.mode == DateTimePickerMode.time ||
        widget.mode == DateTimePickerMode.dateTime) {
      if (widget.use24HourFormat) {
        _hourController = FixedExtentScrollController(
          initialItem: _selectedDate.hour,
        );
      } else {
        _hourController = FixedExtentScrollController(
          initialItem: _selectedDate.hour == 0 ? 11 :
          _selectedDate.hour > 12 ? _selectedDate.hour - 13 : _selectedDate.hour - 1,
        );
        _periodController = FixedExtentScrollController(
          initialItem: _selectedDate.hour < 12 ? 0 : 1,
        );
      }
      _minuteController = FixedExtentScrollController(
        initialItem: _selectedDate.minute,
      );
    }
  }

  /// 날짜 범위 데이터 생성
  void _generateDateRanges() {
    _years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
          (index) => widget.firstDate.year + index,
    );
    _months = List.generate(12, (index) => index + 1);
    _days = List.generate(31, (index) => index + 1);
    _hours = widget.use24HourFormat
        ? List.generate(24, (index) => index)
        : List.generate(12, (index) => index + 1);
    _minutes = List.generate(60, (index) => index);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    if (widget.mode == DateTimePickerMode.time ||
        widget.mode == DateTimePickerMode.dateTime) {
      _hourController.dispose();
      _minuteController.dispose();
      if (!widget.use24HourFormat) {
        _periodController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(colors),
            _buildHeader(context, colors, l10n),
            if (widget.mode == DateTimePickerMode.dateRange)
              _buildRangeTabBar(context, colors, l10n),
            _buildPickerContent(context, colors, l10n),
            _buildActionButtons(context, colors, l10n),
          ],
        ),
      ),
    );
  }

  /// 핸들 바 생성
  Widget _buildHandle(dynamic colors) {
    return Container(
      width: 40.w,
      height: 4.h,
      margin: EdgeInsets.only(top: 12.h),
      decoration: BoxDecoration(
        color: colors.textHint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  /// 헤더 생성
  Widget _buildHeader(BuildContext context, dynamic colors, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              gradient: DaylitColors.brandGradient,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getHeaderIcon(),
              size: 20.r,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? _getDefaultTitle(l10n),
                  style: DaylitColors.heading3(color: colors.textPrimary).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.mode == DateTimePickerMode.dateRange) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '${_formatSelectedRange()} (${_selectedEndDate.difference(_selectedDate).inDays + 1}일)',
                    style: DaylitColors.bodySmall(color: colors.textSecondary),
                  ),
                  if (widget.maxRangeDays < 365) ...[
                    SizedBox(height: 2.h),
                    Text(
                      '최대 ${widget.maxRangeDays}일까지 선택 가능',
                      style: DaylitColors.bodySmall(color: DaylitColors.warning).copyWith(
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 범위 선택 탭바 생성
  Widget _buildRangeTabBar(BuildContext context, dynamic colors, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _buildRangeTab(
            context,
            colors,
            '시작일',
            0,
            _formatDate(_selectedDate),
            _currentTabIndex == 0,
          ),
          _buildRangeTab(
            context,
            colors,
            '종료일',
            1,
            _formatDate(_selectedEndDate),
            _currentTabIndex == 1,
          ),
        ],
      ),
    );
  }

  /// 범위 선택 탭 생성
  Widget _buildRangeTab(
      BuildContext context,
      dynamic colors,
      String title,
      int index,
      String date,
      bool isSelected,
      ) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTabIndex = index),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            gradient: isSelected ? DaylitColors.brandGradient : null,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: DaylitColors.bodySmall(
                  color: isSelected ? Colors.white : colors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                date,
                style: DaylitColors.bodyMedium(
                  color: isSelected ? Colors.white : colors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 피커 컨텐츠 생성
  Widget _buildPickerContent(BuildContext context, dynamic colors, AppLocalizations l10n) {
    return Container(
      height: 200.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      child: _buildPickerByMode(colors),
    );
  }

  /// 모드별 피커 생성
  Widget _buildPickerByMode(dynamic colors) {
    switch (widget.mode) {
      case DateTimePickerMode.date:
      case DateTimePickerMode.dateRange:
        return _buildDatePicker(colors);
      case DateTimePickerMode.time:
        return _buildTimePicker(colors);
      case DateTimePickerMode.dateTime:
        return _buildDateTimePicker(colors);
    }
  }

  /// 날짜 피커 생성
  Widget _buildDatePicker(dynamic colors) {
    return Row(
      children: [
        // 년도
        Expanded(
          flex: 2,
          child: _buildWheelPicker(
            controller: _yearController,
            items: _years.map((year) => '$year년').toList(),
            onSelectedItemChanged: (index) {
              setState(() {
                final newDate = _getTargetDate().copyWith(year: _years[index]);
                _setTargetDate(newDate);
                _updateDayController();
              });
            },
            colors: colors,
          ),
        ),
        SizedBox(width: 8.w),

        // 월
        Expanded(
          child: _buildWheelPicker(
            controller: _monthController,
            items: _months.map((month) => '${month}월').toList(),
            onSelectedItemChanged: (index) {
              setState(() {
                final newDate = _getTargetDate().copyWith(month: _months[index]);
                _setTargetDate(newDate);
                _updateDayController();
              });
            },
            colors: colors,
          ),
        ),
        SizedBox(width: 8.w),

        // 일
        Expanded(
          child: _buildWheelPicker(
            controller: _dayController,
            items: _getAvailableDays().map((day) => '${day}일').toList(),
            onSelectedItemChanged: (index) {
              setState(() {
                final availableDays = _getAvailableDays();
                final newDate = _getTargetDate().copyWith(day: availableDays[index]);
                _setTargetDate(newDate);
              });
            },
            colors: colors,
          ),
        ),
      ],
    );
  }

  /// 시간 피커 생성
  Widget _buildTimePicker(dynamic colors) {
    return Row(
      children: [
        // 시간
        Expanded(
          child: _buildWheelPicker(
            controller: _hourController,
            items: widget.use24HourFormat
                ? _hours.map((hour) => '${hour.toString().padLeft(2, '0')}시').toList()
                : _hours.map((hour) => '${hour}시').toList(),
            onSelectedItemChanged: (index) {
              setState(() {
                int hour = widget.use24HourFormat ? _hours[index] : _hours[index];
                if (!widget.use24HourFormat && _periodController.selectedItem == 1) {
                  hour += 12;
                }
                final newDate = _getTargetDate().copyWith(hour: hour);
                _setTargetDate(newDate);
              });
            },
            colors: colors,
          ),
        ),
        SizedBox(width: 8.w),

        // 분
        Expanded(
          child: _buildWheelPicker(
            controller: _minuteController,
            items: _minutes.map((minute) => '${minute.toString().padLeft(2, '0')}분').toList(),
            onSelectedItemChanged: (index) {
              setState(() {
                final newDate = _getTargetDate().copyWith(minute: _minutes[index]);
                _setTargetDate(newDate);
              });
            },
            colors: colors,
          ),
        ),

        // AM/PM (12시간 형식일 때만)
        if (!widget.use24HourFormat) ...[
          SizedBox(width: 8.w),
          Expanded(
            child: _buildWheelPicker(
              controller: _periodController,
              items: ['오전', '오후'],
              onSelectedItemChanged: (index) {
                setState(() {
                  final currentHour = _getTargetDate().hour;
                  int newHour = currentHour;
                  if (index == 0 && currentHour >= 12) {
                    newHour = currentHour - 12;
                  } else if (index == 1 && currentHour < 12) {
                    newHour = currentHour + 12;
                  }
                  final newDate = _getTargetDate().copyWith(hour: newHour);
                  _setTargetDate(newDate);
                });
              },
              colors: colors,
            ),
          ),
        ],
      ],
    );
  }

  /// 날짜+시간 피커 생성
  Widget _buildDateTimePicker(dynamic colors) {
    return Column(
      children: [
        // 날짜 부분
        Expanded(
          child: _buildDatePicker(colors),
        ),

        SizedBox(height: 16.h),

        // 시간 부분
        Expanded(
          child: _buildTimePicker(colors),
        ),
      ],
    );
  }

  /// 휠 피커 위젯 생성
  Widget _buildWheelPicker({
    required FixedExtentScrollController controller,
    required List<String> items,
    required ValueChanged<int> onSelectedItemChanged,
    required dynamic colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 40.h,
        onSelectedItemChanged: onSelectedItemChanged,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DaylitColors.brandSecondary.withValues(alpha: 0.1),
                DaylitColors.brandPrimary.withValues(alpha: 0.1),
                DaylitColors.brandAccent.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: DaylitColors.brandPrimary.withValues(alpha: 0.3),
            ),
          ),
        ),
        children: items.map((item) => Center(
          child: Text(
            item,
            style: DaylitColors.bodyLarge(color: colors.textPrimary).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  /// 액션 버튼들 생성
  Widget _buildActionButtons(BuildContext context, dynamic colors, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          // 취소 버튼
          Expanded(
            child: SizedBox(
              height: 50.h,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  backgroundColor: colors.surface,
                  foregroundColor: colors.textSecondary,
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  widget.cancelText ?? l10n.cancel,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'pre',
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // 확인 버튼
          Expanded(
            child: SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => _handleConfirm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DaylitColors.brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  widget.confirmText ?? l10n.done,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'pre',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 헬퍼 함수들 ====================

  /// 헤더 아이콘 반환
  IconData _getHeaderIcon() {
    switch (widget.mode) {
      case DateTimePickerMode.date:
        return LucideIcons.calendar;
      case DateTimePickerMode.time:
        return LucideIcons.clock;
      case DateTimePickerMode.dateTime:
        return LucideIcons.calendarClock;
      case DateTimePickerMode.dateRange:
        return LucideIcons.calendarRange;
    }
  }

  /// 기본 제목 반환
  String _getDefaultTitle(AppLocalizations l10n) {
    switch (widget.mode) {
      case DateTimePickerMode.date:
        return '날짜 선택';
      case DateTimePickerMode.time:
        return '시간 선택';
      case DateTimePickerMode.dateTime:
        return '날짜 시간 선택';
      case DateTimePickerMode.dateRange:
        return '기간 선택';
    }
  }

  /// 현재 대상 날짜 반환
  DateTime _getTargetDate() {
    if (widget.mode == DateTimePickerMode.dateRange) {
      return _currentTabIndex == 0 ? _selectedDate : _selectedEndDate;
    }
    return _selectedDate;
  }

  /// 대상 날짜 설정
  void _setTargetDate(DateTime date) {
    if (widget.mode == DateTimePickerMode.dateRange) {
      if (_currentTabIndex == 0) {
        // 시작일 설정
        _selectedDate = date;

        // 시작일이 종료일보다 늦으면 종료일을 시작일 + 1일로 설정
        if (_selectedDate.isAfter(_selectedEndDate)) {
          _selectedEndDate = _selectedDate.add(const Duration(days: 1));
        }

        // 최대 기간 체크 (시작일 기준으로 종료일 조정)
        final maxEndDate = _selectedDate.add(Duration(days: widget.maxRangeDays));
        if (_selectedEndDate.isAfter(maxEndDate)) {
          _selectedEndDate = maxEndDate;
        }
      } else {
        // 종료일 설정
        final proposedEndDate = date;

        // 종료일이 시작일보다 빠르면 시작일을 종료일 - 1일로 설정
        if (proposedEndDate.isBefore(_selectedDate)) {
          _selectedDate = proposedEndDate.subtract(const Duration(days: 1));
        }

        // 최대 기간 체크 (종료일 기준으로 시작일 조정)
        final daysDifference = proposedEndDate.difference(_selectedDate).inDays;
        if (daysDifference > widget.maxRangeDays) {
          _selectedDate = proposedEndDate.subtract(Duration(days: widget.maxRangeDays));
        }

        _selectedEndDate = proposedEndDate;
      }

      // 최종 검증: 기간이 여전히 최대값을 넘지 않는지 확인
      final finalDaysDifference = _selectedEndDate.difference(_selectedDate).inDays;
      if (finalDaysDifference > widget.maxRangeDays) {
        if (_currentTabIndex == 0) {
          // 시작일을 조정한 경우 종료일 재조정
          _selectedEndDate = _selectedDate.add(Duration(days: widget.maxRangeDays));
        } else {
          // 종료일을 조정한 경우 시작일 재조정
          _selectedDate = _selectedEndDate.subtract(Duration(days: widget.maxRangeDays));
        }
      }
    } else {
      _selectedDate = date;
    }
  }

  /// 사용 가능한 일수 목록 반환
  List<int> _getAvailableDays() {
    final targetDate = _getTargetDate();
    final daysInMonth = DateTime(targetDate.year, targetDate.month + 1, 0).day;
    return List.generate(daysInMonth, (index) => index + 1);
  }

  /// 일 컨트롤러 업데이트
  void _updateDayController() {
    final availableDays = _getAvailableDays();
    final targetDate = _getTargetDate();
    final currentDay = targetDate.day;

    if (currentDay > availableDays.length) {
      final newDate = targetDate.copyWith(day: availableDays.last);
      _setTargetDate(newDate);
      _dayController.jumpToItem(availableDays.length - 1);
    }
  }

  /// 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  /// 선택된 범위 포맷
  String _formatSelectedRange() {
    return '${_formatDate(_selectedDate)} ~ ${_formatDate(_selectedEndDate)}';
  }

  /// 확인 버튼 처리
  void _handleConfirm(BuildContext context) {
    switch (widget.mode) {
      case DateTimePickerMode.date:
        Navigator.of(context).pop(_selectedDate);
        break;
      case DateTimePickerMode.time:
        Navigator.of(context).pop(TimeOfDay.fromDateTime(_selectedDate));
        break;
      case DateTimePickerMode.dateTime:
        Navigator.of(context).pop(_selectedDate);
        break;
      case DateTimePickerMode.dateRange:
        Navigator.of(context).pop(DateRange(
          start: _selectedDate,
          end: _selectedEndDate,
        ));
        break;
    }
  }
}
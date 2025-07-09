import 'package:daylit/widget/daylitClassicLogo.dart';
import 'package:daylit/widget/daylitIconButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daylit/router/routerProvider.dart';
import '../../util/daylitColors.dart';
import '../../controller/auth/authProvider.dart';
import '../../util/daylitLoading.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _confettiController;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // 초기화 및 루틴 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    final userProfile = ref.read(userProfileProvider);

    if (userProfile == null) {
      context.go('/login');
      return;
    }

    try {
      // 루틴 데이터 로드
      await ref.read(routineProvider.notifier).loadRoutines(userProfile.id);

      // 루틴이 없으면 AI 추천 페이지로 이동
      final hasRoutines = ref.read(hasRoutinesProvider);
      if (!hasRoutines && mounted) {
        await Future.delayed(Duration(milliseconds: 500)); // 잠깐 대기
        context.go('/ai-routine-setup');
        return;
      }

      // 진행도 애니메이션 시작
      _progressAnimationController.forward();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('앱 초기화 중 오류 발생: $e'),
            backgroundColor: DaylitColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);
    final routineState = ref.watch(routineProvider);
    final todayInfo = ref.watch(todayRoutineInfoProvider);
    final userProfile = ref.watch(userProfileProvider);

    // 로딩 상태
    if (routineState.isLoading || !_hasInitialized) {
      return _buildLoadingScreen(colors);
    }

    // 루틴이 없는 경우 (리다이렉트 전 화면)
    if (todayInfo.totalCount == 0) {
      return _buildEmptyRoutineScreen(colors);
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (고정)
            _buildHeader(colors, userProfile),

            // 메인 컨텐츠 (스크롤 가능)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),

                    // 오늘의 진행도 카드
                    _buildProgressCard(todayInfo, colors),

                    SizedBox(height: 24.h),

                    // 오늘의 루틴 리스트
                    _buildRoutineList(todayInfo.routines, colors),

                    SizedBox(height: 20.h),

                    // 격려 메시지 (완료된 루틴이 있을 때만)
                    if (todayInfo.completedCount > 0)
                      _buildEncouragementSection(todayInfo.completedCount, colors),

                    SizedBox(height: 20.h),

                    // 루틴 추가 버튼
                    _buildAddRoutineSection(colors, userProfile),

                    SizedBox(height: 100.h), // 하단 네비게이션 여백
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(dynamic colors) {
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DayLitLogo.medium(),
            SizedBox(height: 32.h),
            CircularProgressIndicator(color: DaylitColors.brandPrimary),
            SizedBox(height: 16.h),
            Text(
              '루틴을 준비하고 있어요...',
              style: TextStyle(
                fontSize: 16.sp,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRoutineScreen(dynamic colors) {
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                gradient: colors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.sparkles,
                size: 50.r,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'AI 루틴 추천으로 이동 중...',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '맞춤형 루틴을 준비해드릴게요!',
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic colors, UserProfile? userProfile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          // 로고와 날짜
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DayLitLogo.small(showSun: false),
                SizedBox(height: 6.h),
                Text(
                  _getTodayString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 프리미엄 정보 (무료 사용자만)
          if (userProfile != null && !userProfile.isPremium)
            Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: DaylitColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: DaylitColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.zap,
                    size: 14.r,
                    color: DaylitColors.warning,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'AI ${userProfile.remainingAICount}회',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: DaylitColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // 설정 버튼
          DaylitIconButton(
            onPressed: () => context.go('/settings'),
            iconData: LucideIcons.settings,
            size: 20.r,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(TodayRoutineInfo todayInfo, dynamic colors) {
    final progress = todayInfo.completionRate;
    final isCompleted = progress >= 1.0;

    return AnimatedBuilder(
      animation: _progressAnimationController,
      builder: (context, child) {
        final animatedProgress = progress * _progressAnimationController.value;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: isCompleted
                ? LinearGradient(
              colors: [DaylitColors.success, DaylitColors.success.withValues(alpha: 0.8)],
            )
                : colors.primaryGradient,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: (isCompleted ? DaylitColors.success : DaylitColors.brandPrimary)
                    .withValues(alpha: 0.3),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // 상단 정보
              Row(
                children: [
                  Icon(
                    isCompleted ? LucideIcons.trophy : LucideIcons.target,
                    color: Colors.white,
                    size: 28.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompleted ? '🎉 오늘 목표 달성!' : '오늘의 목표',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${todayInfo.completedCount}/${todayInfo.totalCount} 완료',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 원형 프로그레스
                  SizedBox(
                    width: 60.w,
                    height: 60.w,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: animatedProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 6,
                        ),
                        Center(
                          child: Text(
                            '${(animatedProgress * 100).round()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 하단 메시지
              if (!isCompleted) ...[
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${todayInfo.totalCount - todayInfo.completedCount}개 더 하면 완료! 💪',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoutineList(List<Routine> routines, dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 루틴',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),

        // 루틴 카드들
        ...routines.asMap().entries.map((entry) {
          final index = entry.key;
          final routine = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            child: _buildRoutineCard(routine, colors, index),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRoutineCard(Routine routine, dynamic colors, int index) {
    final todayInfo = ref.watch(todayRoutineInfoProvider);
    final isCompleted = todayInfo.isCompleted(routine.id);
    final userProfile = ref.read(userProfileProvider);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCompleted
              ? DaylitColors.success.withValues(alpha: 0.5)
              : colors.border,
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? DaylitColors.success.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleRoutine(routine.id, userProfile?.id),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                // 체크박스
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: isCompleted ? DaylitColors.success : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? DaylitColors.success : colors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: isCompleted
                      ? Icon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 18.r,
                  )
                      : null,
                ),

                SizedBox(width: 16.w),

                // 루틴 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? colors.textSecondary
                              : colors.textPrimary,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),

                      if (routine.description != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          routine.description!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],

                      // 메타 정보
                      if (routine.timeSlot != null || routine.aiGenerated) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            if (routine.timeSlot != null) ...[
                              Icon(
                                LucideIcons.clock,
                                size: 12.r,
                                color: colors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                routine.timeSlot!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],

                            if (routine.aiGenerated) ...[
                              if (routine.timeSlot != null) SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.sparkles,
                                      size: 10.r,
                                      color: DaylitColors.brandPrimary,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'AI',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: DaylitColors.brandPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // 완료 상태 아이콘
                if (isCompleted)
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: DaylitColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.check,
                      color: DaylitColors.success,
                      size: 16.r,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEncouragementSection(int completedCount, dynamic colors) {
    final messages = [
      "좋은 시작! 계속해보세요 🌟",
      "잘하고 있어요! 💪",
      "대단해요! 거의 다 했어요 🔥",
      "완벽해요! 오늘도 성공! 🎉",
    ];

    final messageIndex = (completedCount - 1).clamp(0, messages.length - 1);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: DaylitColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: DaylitColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: DaylitColors.success,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.heart,
              color: Colors.white,
              size: 24.r,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              messages[messageIndex],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRoutineSection(dynamic colors, UserProfile? userProfile) {
    final canAddMore = ref.watch(canAddRoutineProvider);

    return Column(
      children: [
        // AI 추천 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/ai-routine-setup'),
            icon: Icon(LucideIcons.sparkles, size: 20.r),
            label: Text('AI 루틴 추천받기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DaylitColors.brandPrimary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // 수동 추가 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: canAddMore ? () => _showAddRoutineDialog() : null,
            icon: Icon(LucideIcons.plus, size: 18.r),
            label: Text('직접 루틴 만들기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: canAddMore ? DaylitColors.brandPrimary : colors.textSecondary,
              side: BorderSide(
                color: canAddMore ? DaylitColors.brandPrimary : colors.border,
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        // 제한 안내 (무료 사용자)
        if (userProfile != null && !userProfile.isPremium) ...[
          SizedBox(height: 12.h),
          Text(
            canAddMore
                ? '무료: ${3 - ref.watch(routineProvider).routines.length}개 더 만들 수 있어요'
                : '무료 계정은 최대 3개까지 가능해요',
            style: TextStyle(
              fontSize: 12.sp,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Future<void> _toggleRoutine(String routineId, String? userId) async {
    if (userId == null) return;

    try {
      await ref.read(routineProvider.notifier)
          .toggleRoutineCompletion(routineId, userId);

      // 완료 시 햅틱 피드백
      final todayInfo = ref.read(todayRoutineInfoProvider);
      if (todayInfo.isCompleted(routineId)) {
        // 완료 애니메이션 트리거
        HapticFeedback.lightImpact();

        // 모든 루틴 완료 시 축하 애니메이션
        if (todayInfo.completionRate >= 1.0) {
          _confettiController.forward().then((_) {
            _confettiController.reset();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('루틴 업데이트 실패: $e'),
          backgroundColor: DaylitColors.error,
        ),
      );
    }
  }

  void _showAddRoutineDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedTimeSlot = '언제든지';
    String selectedCategory = '일반';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: DaylitColors.of(context).surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 핸들바
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: DaylitColors.of(context).border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                Text(
                  '새 루틴 만들기',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),

                // 루틴 이름
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: '루틴 이름',
                    hintText: '예: 30분 운동하기',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // 설명
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: '설명 (선택사항)',
                    hintText: '루틴에 대한 간단한 설명',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // 시간대와 카테고리
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedTimeSlot,
                        decoration: InputDecoration(
                          labelText: '시간대',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        items: ['오전', '오후', '저녁', '언제든지'].map((time) =>
                            DropdownMenuItem(value: time, child: Text(time))
                        ).toList(),
                        onChanged: (value) => setState(() => selectedTimeSlot = value!),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: '카테고리',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        items: ['운동', '학습', '건강', '취미', '일반'].map((category) =>
                            DropdownMenuItem(value: category, child: Text(category))
                        ).toList(),
                        onChanged: (value) => setState(() => selectedCategory = value!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text('취소'),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: titleController.text.isNotEmpty
                            ? () => _saveNewRoutine(
                          titleController.text,
                          descriptionController.text,
                          selectedTimeSlot,
                          selectedCategory,
                        )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DaylitColors.brandPrimary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text('만들기'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveNewRoutine(
      String title,
      String description,
      String timeSlot,
      String category,
      ) async {
    final userProfile = ref.read(userProfileProvider);
    if (userProfile == null) return;

    try {
      await ref.read(routineProvider.notifier).addRoutine(
        userId: userProfile.id,
        title: title,
        description: description.isNotEmpty ? description : null,
        timeSlot: timeSlot,
        category: category,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('새 루틴이 추가되었습니다! 🎉'),
          backgroundColor: DaylitColors.success,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('루틴 추가 실패: $e'),
          backgroundColor: DaylitColors.error,
        ),
      );
    }
  }

  String _getTodayString() {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${now.month}월 ${now.day}일 ${weekdays[now.weekday - 1]}요일';
  }
}
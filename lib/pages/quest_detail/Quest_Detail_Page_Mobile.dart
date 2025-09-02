import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../model/quest/Quest_Day_Model.dart';
import '../../model/quest/Quest_Model.dart';
import '../../provider/Quest_Provider.dart';
import '../../provider/Router_Provider.dart';
import '../../util/Daylit_Colors.dart';
import '../../util/Routine_Utils.dart';

class QuestDetailPageMobile extends StatefulWidget {
  final String qid;

  const QuestDetailPageMobile({super.key, required this.qid});

  @override
  State<QuestDetailPageMobile> createState() => _QuestDetailPageMobileState();
}

class _QuestDetailPageMobileState extends State<QuestDetailPageMobile> {
  QuestModel? _quest;
  List<QuestDayModel> _dailyMissions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestData();
  }

  void _loadQuestData() {
    final questProvider = context.read<QuestProvider>();

    // 해당 qid로 퀘스트 찾기
    _quest = questProvider.getQuestById(widget.qid);

    if (_quest != null) {
      // 일자별 미션 데이터 생성 (테스트용)
      _generateDailyMissions();
    }

    setState(() {});
  }

  // 테스트용 일자별 미션 생성
  void _generateDailyMissions() {
    if (_quest == null) return;

    _dailyMissions = List.generate(_quest!.totalDays, (index) {
      final missionDate = _quest!.startDate.add(Duration(days: index));

      return QuestDayModel(
        qdid: '${widget.qid}_day_${index + 1}',
        qid: widget.qid,
        date: missionDate,
        dayNumber: index + 1,
        mission: _getMissionForDay(index + 1),
        description: _getDescriptionForDay(index + 1),
        difficulty: _getDifficultyForDay(index + 1),
        estimatedMinutes: _getEstimatedMinutesForDay(index + 1),
        tips: _getTipsForDay(index + 1),
        createdAt: _quest!.createdAt,
      );
    });
  }

  // 일자별 미션 내용 생성 (퀘스트 목적에 맞춰)
  String _getMissionForDay(int dayNumber) {
    if (_quest == null) return '미션 $dayNumber';

    final purpose = _quest!.purpose.toLowerCase();

    if (purpose.contains('조깅') || purpose.contains('운동')) {
      final missions = [
        '30분 가벼운 조깅하기',
        '35분 조깅 + 스트레칭',
        '30분 조깅 (속도 조금 올리기)',
        '40분 조깅 + 코어 운동',
        '30분 인터벌 런닝',
      ];
      return missions[dayNumber % missions.length];
    } else if (purpose.contains('영어') || purpose.contains('공부')) {
      final missions = [
        '영어 단어 50개 암기',
        '영어 뉴스 기사 1개 읽기',
        'TED 영상 1개 시청하고 요약',
        '영어 일기 3문장 쓰기',
        '영어 팟캐스트 20분 듣기',
      ];
      return missions[dayNumber % missions.length];
    } else if (purpose.contains('금연')) {
      final missions = [
        '금연 다짐 메모 작성하기',
        '스트레스 받을 때 심호흡 10회',
        '금연 성공 사례 1개 읽기',
        '대체 활동 3가지 실천하기',
        '금연 일기 작성하기',
      ];
      return missions[dayNumber % missions.length];
    } else if (purpose.contains('독서')) {
      final missions = [
        '책 30분 읽고 감상 메모',
        '읽은 내용 중 인상깊은 구절 기록',
        '책 내용 요약 3줄 작성',
        '다른 사람에게 책 내용 설명',
        '독서 노트 정리하기',
      ];
      return missions[dayNumber % missions.length];
    }

    return '${_quest!.purpose} 실천하기 (Day $dayNumber)';
  }

  String? _getDescriptionForDay(int dayNumber) {
    return '오늘의 미션을 완료하고 인증 사진이나 일기를 작성해주세요.';
  }

  MissionDifficulty _getDifficultyForDay(int dayNumber) {
    // 초반에는 쉽게, 점점 어려워지게
    if (dayNumber <= 7) return MissionDifficulty.easy;
    if (dayNumber <= 14) return MissionDifficulty.medium;
    return MissionDifficulty.hard;
  }

  int _getEstimatedMinutesForDay(int dayNumber) {
    final purpose = _quest?.purpose.toLowerCase() ?? '';

    if (purpose.contains('조깅') || purpose.contains('운동')) {
      return 30 + (dayNumber ~/ 7) * 5; // 주차별로 5분씩 증가
    } else if (purpose.contains('영어') || purpose.contains('공부')) {
      return 60; // 1시간 고정
    } else if (purpose.contains('독서')) {
      return 30; // 30분 고정
    }

    return 20 + (dayNumber % 3) * 10; // 기본 20-40분
  }

  List<String> _getTipsForDay(int dayNumber) {
    final purpose = _quest?.purpose.toLowerCase() ?? '';

    if (purpose.contains('조깅') || purpose.contains('운동')) {
      return [
        '운동 전 5분 워밍업은 필수입니다',
        '무리하지 말고 본인 페이스를 유지하세요',
        '운동 후 충분한 수분 섭취하세요',
      ];
    } else if (purpose.contains('영어')) {
      return [
        '모르는 단어는 바로 찾아보세요',
        '소리내어 읽으면 더 효과적입니다',
        '반복 학습이 가장 중요합니다',
      ];
    } else if (purpose.contains('독서')) {
      return [
        '집중할 수 있는 조용한 환경을 만드세요',
        '이해되지 않는 부분은 천천히 다시 읽어보세요',
        '중요한 내용은 메모하며 읽으세요',
      ];
    }

    return ['꾸준함이 가장 중요합니다', '작은 성취도 축하하세요'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = DaylitColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_quest == null) {
      return _buildErrorPage(context);
    }

    return _buildBody(context, theme, colors);
  }

  Widget _buildBody(BuildContext context, ThemeData theme, dynamic colors) {
    return CustomScrollView(
      slivers: [
        // 퀘스트 헤더 정보
        SliverToBoxAdapter(
          child: _buildQuestHeader(context, theme, colors),
        ),

        // 진행률 표시
        SliverToBoxAdapter(
          child: _buildProgressSection(context, theme, colors),
        ),

        // 퀘스트 정보 버튼
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: OutlinedButton.icon(
              onPressed: () => _showQuestInfo(context),
              icon: Icon(LucideIcons.info, size: 16.w),
              label: Text('퀘스트 정보'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(color: colors.border),
              ),
            ),
          ),
        ),

        // 일자별 미션 리스트
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 24.h, 0, 8.h),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: DaylitColors.brandPrimary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '일별 미션',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${_dailyMissions.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: DaylitColors.brandPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 미션 리스트
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final mission = _dailyMissions[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: _buildMissionCard(context, mission, theme, colors),
              );
            },
            childCount: _dailyMissions.length,
          ),
        ),

        // 하단 여백
        SliverToBoxAdapter(
          child: SizedBox(height: 100.h),
        ),
      ],
    );
  }

  Widget _buildQuestHeader(BuildContext context, ThemeData theme, dynamic colors) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  LucideIcons.target,
                  color: DaylitColors.brandPrimary,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _quest!.purpose,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          color: colors.textSecondary,
                          size: 14.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${_quest!.totalDays}일 챌린지',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_quest!.constraints.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    color: DaylitColors.warning,
                    size: 16.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _quest!.constraints,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, ThemeData theme, dynamic colors) {
    final completedDays = _quest!.daysElapsed.clamp(0, _quest!.totalDays);
    final progressPercent = _quest!.progressPercent;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '진행률',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '${progressPercent.toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: DaylitColors.brandPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 진행률 바
          Container(
            width: double.infinity,
            height: 8.h,
            decoration: BoxDecoration(
              color: colors.border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercent / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: DaylitColors.brandGradient,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedDays일 완료',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '총 ${_quest!.totalDays}일',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, QuestDayModel mission, ThemeData theme, dynamic colors) {
    final isToday = mission.isToday;
    final isPast = mission.isPast;
    final isFuture = mission.isFuture;

    // TODO: 실제 완료 상태는 QuestRecordModel에서 가져와야 함
    final isCompleted = isPast; // 임시로 과거 미션은 모두 완료로 처리

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: isToday ? Border.all(
          color: DaylitColors.brandPrimary,
          width: 2,
        ) : Border.all(
          color: colors.border.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onMissionTap(context, mission),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // 날짜와 상태 아이콘
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: _getMissionStatusColor(isCompleted, isToday, isFuture)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${mission.dayNumber}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _getMissionStatusColor(isCompleted, isToday, isFuture),
                        ),
                      ),
                      Icon(
                        _getMissionStatusIcon(isCompleted, isToday, isFuture),
                        color: _getMissionStatusColor(isCompleted, isToday, isFuture),
                        size: 12.w,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16.w),

                // 미션 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.mission,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 6.h),

                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            color: colors.textSecondary,
                            size: 12.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${mission.estimatedMinutes}분',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          _buildDifficultyBadge(mission.difficulty, theme, colors),
                        ],
                      ),
                    ],
                  ),
                ),

                // 상태 표시
                if (isCompleted) ...[
                  Icon(
                    LucideIcons.circleCheck,
                    color: DaylitColors.success,
                    size: 20.w,
                  ),
                ] else if (isToday) ...[
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      LucideIcons.play,
                      color: DaylitColors.brandPrimary,
                      size: 16.w,
                    ),
                  ),
                ] else ...[
                  Icon(
                    LucideIcons.chevronRight,
                    color: colors.textSecondary,
                    size: 16.w,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(MissionDifficulty difficulty, ThemeData theme, dynamic colors) {
    Color badgeColor;
    String text;

    switch (difficulty) {
      case MissionDifficulty.easy:
        badgeColor = DaylitColors.success;
        text = '쉬움';
        break;
      case MissionDifficulty.medium:
        badgeColor = DaylitColors.warning;
        text = '보통';
        break;
      case MissionDifficulty.hard:
        badgeColor = DaylitColors.error;
        text = '어려움';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getMissionStatusColor(bool isCompleted, bool isToday, bool isFuture) {
    if (isCompleted) return DaylitColors.success;
    if (isToday) return DaylitColors.brandPrimary;
    if (isFuture) return DaylitColors.info.withValues(alpha: 0.6);
    return DaylitColors.error; // 놓친 미션
  }

  IconData _getMissionStatusIcon(bool isCompleted, bool isToday, bool isFuture) {
    if (isCompleted) return LucideIcons.check;
    if (isToday) return LucideIcons.play;
    if (isFuture) return LucideIcons.clock;
    return LucideIcons.x; // 놓친 미션
  }

  void _onMissionTap(BuildContext context, QuestDayModel mission) {
    final isToday = mission.isToday;
    final isPast = mission.isPast;

    if (isPast) {
      // 완료된 미션 - 기록 보기
      _showCompletedMissionRecord(context, mission);
    } else if (isToday) {
      // 오늘 미션 - 완료 처리 (사진/일기 작성)
      _showMissionCompletionDialog(context, mission);
    } else {
      // 미래 미션 - 정보만 보기
      _showMissionInfo(context, mission);
    }
  }

  void _showCompletedMissionRecord(BuildContext context, QuestDayModel mission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: DaylitColors.of(context).surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.circleCheck,
                    color: DaylitColors.success,
                    size: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '완료된 미션',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                mission.mission,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              Text(
                '완료 기록을 조회하는 기능은 추후 구현 예정입니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionCompletionDialog(BuildContext context, QuestDayModel mission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: DaylitColors.of(context).surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.target,
                    color: DaylitColors.brandPrimary,
                    size: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '오늘의 미션',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                mission.mission,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              Text(
                '미션 완료 인증을 위해 사진을 찍거나 일기를 작성해주세요.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: 사진 촬영 기능
                        _showComingSoonMessage('사진 촬영');
                      },
                      icon: Icon(LucideIcons.camera),
                      label: Text('사진 촬영'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: 일기 작성 기능
                        _showComingSoonMessage('일기 작성');
                      },
                      icon: Icon(LucideIcons.pencil),
                      label: Text('일기 작성'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionInfo(BuildContext context, QuestDayModel mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${mission.dayNumber}일차 미션'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mission.mission),
            SizedBox(height: 12.h),
            if (mission.description != null) ...[
              Text(
                '설명:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(mission.description!),
              SizedBox(height: 12.h),
            ],
            Text('예상 소요시간: ${mission.estimatedMinutes}분'),
            if (mission.tips.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                '팁:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              ...mission.tips.map((tip) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text('• $tip'),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonMessage(String feature) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature 기능은 곧 출시 예정입니다'),
          backgroundColor: DaylitColors.warning,
        ),
      );
    }
  }

  void _showQuestInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.info, color: DaylitColors.brandPrimary),
            SizedBox(width: 12.w),
            Text('퀘스트 정보'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('시작일', _quest!.startDate.toString().split(' ')[0]),
            _buildInfoRow('종료일', _quest!.endDate.toString().split(' ')[0]),
            _buildInfoRow('총 비용', '${_quest!.totalCost}릿'),
            _buildInfoRow('상태', _quest!.isActive ? '진행중' : '완료'),
            if (_quest!.constraints.isNotEmpty)
              _buildInfoRow('제약사항', _quest!.constraints),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.triangleAlert,
            size: 48.w,
            color: DaylitColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            '퀘스트를 찾을 수 없습니다',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            'QID: ${widget.qid}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.read<RouterProvider>().goBack(context),
            child: Text('돌아가기'),
          ),
        ],
      ),
    );
  }
}
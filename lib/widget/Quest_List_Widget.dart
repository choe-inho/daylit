import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../l10n/app_localizations.dart';
import '../model/quest/Quest_Model.dart';
import '../util/Daylit_Colors.dart';
import '../util/Routine_Utils.dart';

class QuestListWidget extends StatelessWidget {
  final List<QuestModel> quests;
  final Function(QuestModel)? onQuestTap;

  const QuestListWidget({
    super.key,
    required this.quests,
    this.onQuestTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final quest = quests[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: _QuestCard(
              quest: quest,
              onTap: onQuestTap != null ? () => onQuestTap!(quest) : null,
            ),
          );
        },
        childCount: quests.length,
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final QuestModel quest;
  final VoidCallback? onTap;

  const _QuestCard({
    required this.quest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = DaylitColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 영역 (아이콘 + 제목 + 상태)
              Row(
                children: [
                  // 퀘스트 아이콘
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: _getStatusColor(quest.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      _getQuestIcon(quest.status),
                      color: _getStatusColor(quest.status),
                      size: 20.w,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 제목과 상태 배지
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.purpose,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 2.h),

                        Row(
                          children: [
                            // 상태 배지
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(quest.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                _getStatusText(quest.status, l10n),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getStatusColor(quest.status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            SizedBox(width: 8.w),

                            // 기간 정보
                            Text(
                              '${quest.totalDays}일',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 진행률 또는 화살표
                  if (quest.isActive) ...[
                    Column(
                      children: [
                        Text(
                          '${quest.progressPercent.toInt()}%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: DaylitColors.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: colors.border.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: quest.progressPercent / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: DaylitColors.brandPrimary,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ),
                      ],
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

              // 제약사항 (있는 경우)
              if (quest.constraints.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        color: colors.textSecondary,
                        size: 14.w,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          quest.constraints,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 하단 정보 (시작일, 종료일, 비용)
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 날짜 정보
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        color: colors.textSecondary,
                        size: 14.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        quest.isActive
                            ? '${quest.daysElapsed}/${quest.totalDays}일'
                            : _formatDateRange(quest.startDate, quest.endDate),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // 비용 정보
                  Row(
                    children: [
                      Icon(
                        LucideIcons.coins,
                        color: DaylitColors.warning,
                        size: 14.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${quest.totalCost}릿',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: DaylitColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 상태에 따른 아이콘 반환
  IconData _getQuestIcon(RoutineStatus status) {
    switch (status) {
      case RoutineStatus.active:
        return LucideIcons.play;
      case RoutineStatus.completed:
        return LucideIcons.circleCheck;
      case RoutineStatus.creating:
        return LucideIcons.loader;
      default:
        return LucideIcons.circle;
    }
  }

  // 상태에 따른 색상 반환
  Color _getStatusColor(RoutineStatus status) {
    switch (status) {
      case RoutineStatus.active:
        return DaylitColors.brandPrimary;
      case RoutineStatus.completed:
        return DaylitColors.success;
      case RoutineStatus.creating:
        return DaylitColors.warning;
      default:
        return DaylitColors.info;
    }
  }

  // 상태에 따른 텍스트 반환
  String _getStatusText(RoutineStatus status, AppLocalizations l10n) {
    switch (status) {
      case RoutineStatus.active:
        return '진행중';
      case RoutineStatus.completed:
        return '완료';
      case RoutineStatus.creating:
        return '생성중';
      default:
        return '대기중';
    }
  }

  // 날짜 범위 포맷팅
  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.month}/${start.day} - ${end.month}/${end.day}';
  }
}
import 'package:daylit/provider/Quest_Create_Provider.dart';
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class QuestResultPageMobile extends StatelessWidget {
  const QuestResultPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestCreateProvider>(context);
    final theme = Theme.of(context);
    final colors = DaylitColors.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // 상단 간격
                SliverPadding(padding: EdgeInsets.only(top: 16.h)),

                // 상단에 입력한 목표와 제한 사항등이 정리되서 출력됨
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: colors.border.withValues(alpha:0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha:0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 목표 섹션
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: BoxDecoration(
                                color: DaylitColors.brandPrimary.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                LucideIcons.target,
                                size: 16.r,
                                color: DaylitColors.brandPrimary,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '목표',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    provider.purpose,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // 제한 사항 섹션 (있는 경우에만)
                        if (provider.constraints.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28.r,
                                height: 28.r,
                                decoration: BoxDecoration(
                                  color: DaylitColors.warning.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Icon(
                                  LucideIcons.shieldAlert,
                                  size: 16.r,
                                  color: DaylitColors.warning,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '제한사항',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      provider.constraints,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // 간격
                SliverPadding(padding: EdgeInsets.only(top: 32.h)),

                // 퀘스트 제목
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          gradient: DaylitColors.brandGradient,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 18.r,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: ()=> provider.createQuest('123456789', context),
                        child: Text(
                          '${provider.quests.length}일간의 퀘스트',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 간격
                SliverPadding(padding: EdgeInsets.only(top: 20.h)),

                // 퀘스트 리스트
                SliverList.builder(
                  itemCount: provider.quests.length,
                  itemBuilder: (context, index) {
                    final item = provider.quests[index];
                    final isLast = index == provider.quests.length - 1;

                    return Container(
                      margin: EdgeInsets.only(bottom: isLast ? 24.h : 16.h),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: colors.border.withValues(alpha:0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha:0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 헤더: 날짜와 상태
                            Row(
                              children: [
                                // 날짜 아이콘
                                Container(
                                  width: 32.r,
                                  height: 32.r,
                                  decoration: BoxDecoration(
                                    color: DaylitColors.brandSecondary.withValues(alpha:0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: DaylitColors.brandSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                // 날짜 정보
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Day ${index + 1}',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(item.date),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 상태 표시 (완료 여부)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.textHint.withValues(alpha:0.1),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    '대기중',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colors.textHint,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // 퀘스트 내용
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: colors.border.withValues(alpha:0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 퀘스트 미션
                                  Text(
                                    item.mission,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                  ),

                                  // 퀘스트 설명
                                  if (item.description != null) ...[
                                    SizedBox(height: 8.h),
                                    Text(
                                      item.description!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],

                                  SizedBox(height: 12.h),

                                  // 난이도와 예상 시간
                                  Row(
                                    children: [
                                      // 난이도 표시
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getDifficultyColor(item.difficulty).withValues(alpha:0.1),
                                          borderRadius: BorderRadius.circular(6.r),
                                          border: Border.all(
                                            color: _getDifficultyColor(item.difficulty).withValues(alpha:0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getDifficultyIcon(item.difficulty),
                                              size: 12.r,
                                              color: _getDifficultyColor(item.difficulty),
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              _getDifficultyText(item.difficulty),
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: _getDifficultyColor(item.difficulty),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 8.w),

                                      // 예상 시간
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: DaylitColors.brandSecondary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              LucideIcons.clock,
                                              size: 12.r,
                                              color: DaylitColors.brandSecondary,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              '${item.estimatedMinutes}분',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: DaylitColors.brandSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 팁이 있다면 표시
                                  if (item.tips.isNotEmpty) ...[
                                    SizedBox(height: 12.h),
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: colors.border.withValues(alpha:0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                LucideIcons.lightbulb,
                                                size: 14.r,
                                                color: DaylitColors.warning,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                '도움말',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6.h),
                                          ...item.tips.map((tip) => Padding(
                                            padding: EdgeInsets.only(bottom: 2.h),
                                            child: Text(
                                              '• $tip',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: colors.textSecondary,
                                                height: 1.3,
                                              ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(top: 12.h, bottom: 24.h),
            child: GestureDetector(
              onTap: (){
                //등록 후 프로바이더 초기화,
              },
              child: Container(
                height: 46.h,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: DaylitColors.brandGradient,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AI 아이콘 추가
                    SizedBox(
                      height: 20.r, width: 20.r,
                      child: Image.asset('assets/icon/lit.png', color: const Color(0xffffffff),),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${provider.quests.length * 10}릿 사용하기',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:const Color(0xffffffff),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 헬퍼 메서드들
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Color _getDifficultyColor(dynamic difficulty) {
    switch (difficulty.toString()) {
      case 'MissionDifficulty.easy':
        return DaylitColors.success;
      case 'MissionDifficulty.medium':
        return DaylitColors.warning;
      case 'MissionDifficulty.hard':
        return DaylitColors.error;
      default:
        return DaylitColors.warning;
    }
  }

  IconData _getDifficultyIcon(dynamic difficulty) {
    switch (difficulty.toString()) {
      case 'MissionDifficulty.easy':
        return LucideIcons.circleCheck;
      case 'MissionDifficulty.medium':
        return LucideIcons.circleAlert;
      case 'MissionDifficulty.hard':
        return LucideIcons.triangleAlert;
      default:
        return LucideIcons.circleAlert ;
    }
  }

  String _getDifficultyText(dynamic difficulty) {
    switch (difficulty.toString()) {
      case 'MissionDifficulty.easy':
        return '쉬움';
      case 'MissionDifficulty.medium':
        return '보통';
      case 'MissionDifficulty.hard':
        return '어려움';
      default:
        return '보통';
    }
  }
}
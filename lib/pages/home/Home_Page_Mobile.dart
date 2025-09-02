import 'package:daylit/pages/single/Empty_Quest.dart';
import 'package:daylit/provider/Quest_Provider.dart';
import 'package:daylit/widget/Quest_List_Widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../provider/Router_Provider.dart';
import '../../util/Daylit_Colors.dart';

class HomePageMobile extends StatefulWidget {
  const HomePageMobile({super.key, required this.questProvider});
  final QuestProvider questProvider;

  @override
  State<HomePageMobile> createState() => _HomePageMobileState();
}

class _HomePageMobileState extends State<HomePageMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.questProvider.initializeTestQuests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = DaylitColors.of(context);

    return Consumer<QuestProvider>(
      builder: (context, questProvider, child) {
        // 퀘스트가 없는 경우
        if (questProvider.quests.isEmpty) {
          return const EmptyQuest();
        }

        // 활성 퀘스트와 완료된 퀘스트 분리
        final activeQuests = questProvider.activeQuests;
        final completedQuests = questProvider.completedQuests;

        return CustomScrollView(
          slivers: [
            // 페이지 제목
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20.h, 0, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quest,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${activeQuests.length}개의 활성 퀘스트',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 활성 퀘스트 섹션
            if (activeQuests.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 16.h, 0, 8.h),
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
                        '진행 중인 퀘스트',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 활성 퀘스트 리스트
              QuestListWidget(
                quests: activeQuests,
                onQuestTap: (quest) {
                  _onQuestTap(context, quest);
                },
              ),
            ],

            // 완료된 퀘스트 섹션
            if (completedQuests.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 24.h, 0, 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: DaylitColors.success,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '완료된 퀘스트',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: DaylitColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${completedQuests.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: DaylitColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 완료된 퀘스트 리스트
              QuestListWidget(
                quests: completedQuests,
                onQuestTap: (quest) {
                  _onQuestTap(context, quest);
                },
              ),
            ],

            // 하단 여백
            SliverToBoxAdapter(
              child: SizedBox(height: 100.h),
            ),
          ],
        );
      },
    );
  }

  // 퀘스트 탭 핸들러
  void _onQuestTap(BuildContext context, quest) {
    context.read<RouterProvider>().pushTo(context,'/quest-detail');
  }
}
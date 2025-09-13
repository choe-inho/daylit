import 'package:daylit/pages/single/Empty_Quest.dart';
import 'package:daylit/provider/Quest_Provider.dart';
import 'package:daylit/widget/Quest_List_Widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuests();
    });
  }

  /// 퀘스트 초기화 - Supabase 연결
  Future<void> _initializeQuests() async {
    if (_isInitialized) return;

    try {
      // QuestProvider 초기화 (Supabase 연결)
      await widget.questProvider.initialize();
      _isInitialized = true;
    } catch (e) {
      // 에러 처리는 QuestProvider에서 담당
      debugPrint('퀘스트 초기화 실패: $e');
    }
  }

  /// 새로고침
  Future<void> _onRefresh() async {
    await widget.questProvider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = DaylitColors.of(context);

    return Consumer<QuestProvider>(
      builder: (context, questProvider, child) {
        // 로딩 상태
        if (questProvider.isLoading && !questProvider.hasQuests) {
          return _buildLoadingState(context);
        }

        // 에러 상태
        if (questProvider.error != null) {
          return _buildErrorState(context, questProvider);
        }

        // 퀘스트가 없는 경우
        if (!questProvider.hasQuests) {
          return const EmptyQuest();
        }

        // 활성 퀘스트와 완료된 퀘스트 분리
        final activeQuests = questProvider.activeQuests;
        final completedQuests = questProvider.completedQuests;

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: colors.primary,
          child: CustomScrollView(
            slivers: [
              // 페이지 제목과 통계
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 20.h, 0, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        l10n.quest,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // 통계 정보
                      Row(
                        children: [
                          Text(
                            '${activeQuests.length}개의 활성 퀘스트',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          if (completedQuests.isNotEmpty) ...[
                            Text(' • ', style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.textSecondary,
                            )),
                            Text(
                              '${completedQuests.length}개 완료',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: DaylitColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // 진행률 표시 (선택적)
                      if (questProvider.hasQuests) ...[
                        SizedBox(height: 12.h),
                        _buildProgressIndicator(context, questProvider),
                      ]
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
                        Icon(
                          LucideIcons.target,
                          size: 20.w,
                          color: colors.textPrimary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '활성 퀘스트',
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
                            color: colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${activeQuests.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
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
                    _onQuestTap(context, quest.qid);
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
                        Icon(
                          LucideIcons.circleCheck,
                          size: 20.w,
                          color: colors.success,
                        ),
                        SizedBox(width: 8.w),
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
                            color: colors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${completedQuests.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.success,
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
                    _onQuestTap(context, quest.qid);
                  },
                ),
              ],

              // 일시정지된 퀘스트 섹션 (있는 경우)
              if (questProvider.pausedQuests.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 24.h, 0, 8.h),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.pause,
                          size: 20.w,
                          color: colors.warning,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '일시정지된 퀘스트',
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
                            color: colors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${questProvider.pausedQuests.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 일시정지된 퀘스트 리스트
                QuestListWidget(
                  quests: questProvider.pausedQuests,
                  onQuestTap: (quest) {
                    _onQuestTap(context, quest.qid);
                  },
                ),
              ],

              // 하단 여백 (FloatingActionButton을 위한 공간)
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 로딩 상태 위젯
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: DaylitColors.brandPrimary,
          ),
          SizedBox(height: 16.h),
          Text(
            '퀘스트를 불러오는 중...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// 에러 상태 위젯
  Widget _buildErrorState(BuildContext context, QuestProvider questProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.circleAlert,
              size: 48.w,
              color: DaylitColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              '퀘스트를 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              questProvider.error ?? '알 수 없는 오류가 발생했습니다',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () async {
                questProvider.clearError();
                await _initializeQuests();
              },
              icon: Icon(LucideIcons.refreshCw, size: 18.w),
              label: Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DaylitColors.brandPrimary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 진행률 표시
  Widget _buildProgressIndicator(BuildContext context, QuestProvider questProvider) {
    final progress = questProvider.getOverallProgress();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '전체 진행률',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: DaylitColors.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            valueColor: AlwaysStoppedAnimation<Color>(DaylitColors.brandPrimary),
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }

  /// 퀘스트 탭 핸들러
  void _onQuestTap(BuildContext context, String qid) {
    context.read<RouterProvider>().pushToQuestDetail(context, qid);
  }
}
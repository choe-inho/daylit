import 'package:daylit/l10n/app_localizations.dart';
import 'package:daylit/provider/Quest_Create_Provider.dart';
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// AI 로딩 오버레이 임포트 (실제 파일 경로에 맞게 수정)
import '../../handler/Dialog_Handler.dart';
import '../../handler/Picker_Handler.dart';
import '../single/Quest_AI_Loading_Overlay.dart';

class QuestPageMobile extends StatefulWidget {
  const QuestPageMobile({super.key, required this.provider});
  final QuestCreateProvider provider;

  @override
  State<QuestPageMobile> createState() => _QuestPageMobileState();
}

class _QuestPageMobileState extends State<QuestPageMobile> {
  // 텍스트 컨트롤러 추가
  late TextEditingController _purposeController;
  // 텍스트 컨트롤러 추가
  late TextEditingController _constraintsController;

  @override
  void initState() {
    super.initState();
    _purposeController = TextEditingController(text: widget.provider.purpose);
    _constraintsController = TextEditingController(text: widget.provider.constraints);
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final provider = widget.provider;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              _infoText('어떤 목표를 세워볼까요?', '최소 20자 이상 작성해주세요',context),
              SliverToBoxAdapter(
                child: TextField(
                  controller: _purposeController,
                  maxLines: null,
                  style: theme.textTheme.bodyMedium,
                  onChanged: (value) {
                    // provider에 목표 텍스트 업데이트
                    provider.setPurpose(value);
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.3)
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary
                          )
                      ),
                      hintText: '목표를 자세하게 얘기해주시면 더 맞춤화된 계획을 짤 수 있어요\n\n예시) 내 키가 160cm, 몸무게가 60KG인데 체지방 감량과 근력 증가를 목표로 다이어트를 하고싶어',
                      hintStyle: theme.textTheme.bodySmall
                  ),
                ),
              ),
              SliverPadding(padding: EdgeInsetsGeometry.only(top: 12.h)),
              _infoText('퀘스트를 몇일로 진행할까요?', '7 - 365일까지 생성이 가능해요',context),
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Flexible(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => provider.setAutoEndDate(true),
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: provider.autoEndDate ? DaylitColors.brandGradient : null,
                              color: provider.autoEndDate ? null : theme.dividerColor.withValues(alpha: 0.1),
                              border: Border.all(
                                color: provider.autoEndDate ? theme.colorScheme.primary.withValues(alpha: 0.7) : theme.dividerColor.withValues(alpha: 0.3),
                              )
                          ),
                          alignment: Alignment.center,
                          child: Text('자동설정', style: theme.textTheme.bodyMedium?.copyWith(
                              color: provider.autoEndDate ? theme.colorScheme.onPrimary : theme.dividerColor
                          ),),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w,),
                    Flexible(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async{
                          final date = await PickerHandler.showDatePicker(
                              context: context,
                              initialDate: provider.endDate,
                              firstDate: DateTime.now().add(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 365)));
                          if(date != null){
                            if(date.difference(DateTime.now()).inDays < 7){
                              DialogHandler.showWarning(context: context, message: '최소 7일 이상의 퀘스트를 생성할 수 있습니다');
                            }else{
                              provider.setEndDate(date);
                            }
                          }
                          provider.setAutoEndDate(false);
                        },
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: !provider.autoEndDate ? DaylitColors.brandGradient : null,
                              color: !provider.autoEndDate ? null : theme.dividerColor.withValues(alpha: 0.1),
                              border: Border.all(
                                color: !provider.autoEndDate ? theme.colorScheme.primary.withValues(alpha: 0.7) : theme.dividerColor.withValues(alpha: 0.3),
                              )
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 24.w),
                          child:
                          provider.autoEndDate == true ?
                          Text('직접설정', style: theme.textTheme.bodyMedium,)
                              : Text('${provider.totalDate}일 ', style: theme.textTheme.bodyMedium?.copyWith(
                              color: !provider.autoEndDate ? theme.colorScheme.onPrimary : theme.dividerColor
                          ),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(padding: EdgeInsetsGeometry.only(top: 12.h)),
              _infoText('제한되는 사항이있나요?', '해당 내용은 선택사항입니다',context),
              SliverToBoxAdapter(
                child: TextField(
                  controller: _constraintsController,
                  maxLines: null,
                  style: theme.textTheme.bodyMedium,
                  onChanged: (value) {
                    // provider에 목표 텍스트 업데이트
                    provider.setPurpose(value);
                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.3)
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary
                          )
                      ),
                      hintText: '장소적 제한, 시간적 제한 등을 입력해주시면 더 정확하게 계획을 짤게요.\n\n예시) 밤에 할 수 있고 여유시간이 2시간 정도 밖에없고 아파트라 쿵쿵 거릴 수 없어',
                      hintStyle: theme.textTheme.bodySmall
                  ),
                ),
              ),
            ],
          ),
        ),

        // 완료 버튼 (AI 로딩 오버레이 연결)
        Padding(
          padding: EdgeInsetsGeometry.only(bottom: 24.h, top: 12.h),
          child: InkWell(
            onTap: () async {
              // AI 퀘스트 생성 시작
              await QuestAIGenerationHelper.startGeneration(
                context: context,
                provider: provider,
              );
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: provider.purpose.length >= 10 ? DaylitColors.brandGradient : null,
                  color: provider.purpose.length < 10 ? theme.dividerColor.withValues(alpha: 0.1) : null,
                  border: provider.purpose.length < 10 ? Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.3)
                  ) : null
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AI 아이콘 추가
                  if (provider.purpose.length >= 10) ...[
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    l10n.done,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: provider.purpose.length >= 10
                          ? const Color(0xffffffff)
                          : const Color(0xff8d8d8d),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _infoText(String text, String? subTitle, context){
    return SliverToBoxAdapter(child:
    Padding(
        padding: EdgeInsetsGeometry.only(top: 12.h, bottom: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            if(subTitle != null)...[
              SizedBox(height: 2.h,),
              Row(
                children: [
                  Icon(LucideIcons.circleAlert, size: 14.r, color: Theme.of(context).dividerColor.withValues(alpha: 0.8),),
                  SizedBox(width: 4.w,),
                  Text(subTitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400, color: Theme.of(context).dividerColor.withValues(alpha: 0.8))),
                ],
              ),
            ]
          ],
        )));
  }
}
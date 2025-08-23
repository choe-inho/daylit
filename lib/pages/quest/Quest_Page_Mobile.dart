import 'package:daylit/l10n/app_localizations.dart';
import 'package:daylit/provider/Quest_Create_Provider.dart';
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class QuestPageMobile extends StatelessWidget {
  const QuestPageMobile({super.key, required this.provider});
  final QuestCreateProvider provider;
  @override
  Widget build(BuildContext context) {
    final theme =  Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              _infoText('어떤 목표를 세워볼까요?', context),
              SliverToBoxAdapter(
                child: TextField(
                  maxLines: null,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: theme.colorScheme.shadow.withValues(alpha: 0.2)
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
              _infoText('퀘스트를 몇일로 진행활까요?', context),
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Flexible(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: ()=> provider.setAutoEndDate(true),
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: provider.autoEndDate ? DaylitColors.brandGradient : null,
                              color: provider.autoEndDate ? null : theme.colorScheme.shadow.withValues(alpha: 0.1),
                              border: Border.all(
                                color: provider.autoEndDate ? theme.colorScheme.primary.withValues(alpha: 0.7) : theme.colorScheme.shadow.withValues(alpha: 0.2),
                              )
                          ),
                          alignment: Alignment.center,
                          child: Text('자동설정', style: theme.textTheme.bodyMedium?.copyWith(
                            color: provider.autoEndDate ? theme.colorScheme.onPrimary : theme.colorScheme.shadow.withValues(alpha: 0.5)
                          ),),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w,),
                    Flexible(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: ()=> provider.setAutoEndDate(false),
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: !provider.autoEndDate ? DaylitColors.brandGradient : null,
                              color: !provider.autoEndDate ? null : theme.colorScheme.shadow.withValues(alpha: 0.1),
                              border: Border.all(
                                color: !provider.autoEndDate ? theme.colorScheme.primary.withValues(alpha: 0.7) : theme.colorScheme.shadow.withValues(alpha: 0.2),
                              )
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 24.w),
                          child:
                          provider.autoEndDate == true ?
                           Text('직접설정', style: theme.textTheme.bodyMedium,)
                          : Text('${provider.totalDate}일 ', style: theme.textTheme.bodyMedium?.copyWith(
                              color: !provider.autoEndDate ? theme.colorScheme.onPrimary : theme.colorScheme.shadow.withValues(alpha: 0.5)
                          ),),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(padding: EdgeInsetsGeometry.only(bottom: 24.h, top: 12.h),
          child: Container(
            height: 46.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.circular(15),
              gradient: DaylitColors.brandGradient
            ),
            alignment: Alignment.center,
            child: Text(l10n.done, style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xffffffff)),),
          ),
        )
      ],
    );
  }

  Widget _infoText(String text, context){
    return SliverToBoxAdapter(child:
    Padding(
        padding: EdgeInsetsGeometry.only(top: 12.h, bottom: 6.h),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))));
  }
}

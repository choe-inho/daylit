import 'package:daylit/handler/Dialog_Handler.dart';
import 'package:daylit/handler/Picker_Handler.dart';
import 'package:daylit/l10n/app_localizations.dart';
import 'package:daylit/provider/Quest_Create_Provider.dart';
import 'package:daylit/routes/App_Routes.dart';
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              _infoText('어떤 목표를 세워볼까요? (최소 20자)', context),
              SliverToBoxAdapter(
                child: TextField(
                  onChanged: (value){
                    provider.setPurpose(value);
                  },
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
              SliverToBoxAdapter(
                child: SizedBox(height: 12.h,),
              ),
              _infoText('퀘스트를 몇일로 진행활까요? (7-365 일)', context),
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
              SliverToBoxAdapter(
                child: SizedBox(height: 12.h,),
              ),
              _infoText('추가해야할 제약사항이 있나요? (선택)', context),
              SliverToBoxAdapter(
                child: TextField(
                  onChanged: (value){
                    provider.setConstraints(value);
                  },
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
                      hintText: '제약 사항을 추가하면 더 상황에 맞게 계획을 짤 수 있어요\n\n예시) 집에서만 운동 할 수있고, 아파트라 시끄러운 운동은 불가능해',
                      hintStyle: theme.textTheme.bodySmall
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(padding: EdgeInsetsGeometry.only(bottom: 24.h, top: 12.h),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () async{
              if(provider.purpose.length >= 20){

              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 46.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadiusGeometry.circular(15),
                gradient: provider.purpose.length >= 20 ? DaylitColors.brandGradient : null,
                color: provider.purpose.length < 20 ? theme.dividerColor.withValues(alpha: 0.1) : null,
                border: provider.purpose.length < 20 ? Border.all(
                  color:  theme.dividerColor.withValues(alpha: 0.3)
                ) : null
              ),
              alignment: Alignment.center,
              child: Text(l10n.done, style: theme.textTheme.titleMedium?.copyWith(color:  provider.purpose.length > 20 ? const Color(0xffffffff) : const Color(0xff8d8d8d)),),
            ),
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

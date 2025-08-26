import 'package:daylit/provider/Quest_Create_Provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class QuestResultPageMobile extends StatelessWidget {
  const QuestResultPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestCreateProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          //상단에 입력한 목표와 제한 사항등이 정리되서 출력됨
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3))
              ),
              padding: EdgeInsetsGeometry.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('목표 - ${provider.purpose}', style: theme.textTheme.bodyMedium,),
                  if(provider.constraints.isNotEmpty)
                  Text('제한 - ${provider.constraints}', style: theme.textTheme.bodyMedium,)
                ],
              ),
            ),
          ),
          //아래 리스트 형식으로 나타남
          SliverPadding(padding: EdgeInsetsGeometry.only(top: 24.h)),
          SliverToBoxAdapter(
            child: Text('${provider.totalDate}일간의 퀘스트', style: theme.textTheme.titleMedium,),
          ),
          SliverPadding(padding: EdgeInsetsGeometry.only(top: 24.h)),
          SliverList.builder(
              itemCount: provider.quests.length,
              itemBuilder: (context, index){
                final item = provider.quests[index];
                return Container(

                );
              })
        ],
      ),
    );
  }
}

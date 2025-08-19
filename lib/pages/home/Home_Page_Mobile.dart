import 'package:daylit/pages/single/Empty_Quest.dart';
import 'package:daylit/provider/Quest_Provider.dart';
import 'package:flutter/material.dart';

class HomePageMobile extends StatefulWidget {
  const HomePageMobile({super.key, required this.questProvider});
  final QuestProvider questProvider;

  @override
  State<HomePageMobile> createState() => _HomePageMobileState();
}

class _HomePageMobileState extends State<HomePageMobile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if(widget.questProvider.quests.isEmpty){
      return EmptyQuest();
    }else{
      return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Text('퀘스트', style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w600)) ,
            ),
          ],
        );
    }
  }
}

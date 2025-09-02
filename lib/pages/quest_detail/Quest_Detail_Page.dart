import 'package:daylit/pages/quest_detail/Quest_Detail_Page_Mobile.dart';
import 'package:daylit/pages/quest_detail/Quest_Detail_Page_Tablet.dart';
import 'package:flutter/material.dart';

import '../../responsive/Responsive_Layout_Extensions.dart';
import '../../widget/Auto_Back_Button.dart';

class QuestDetailPage extends StatelessWidget {
  const QuestDetailPage({super.key, required this.qid});
  final String qid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          leading: const AutoBackButton(),
          surfaceTintColor: Colors.transparent,
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            '퀘스트 상세',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: ResponsiveLayoutExtensions.detail(
            mobileLayout: QuestDetailPageMobile(qid: qid),
            tabletLayout: QuestDetailPageTablet()
        )
    );
  }
}
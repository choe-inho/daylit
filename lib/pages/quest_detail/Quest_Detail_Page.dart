import 'package:daylit/pages/quest/Quest_Page_Tablet.dart';
import 'package:daylit/pages/quest_detail/Quest_Detail_Page_Mobile.dart';
import 'package:flutter/material.dart';

import '../../responsive/Responsive_Layout_Extensions.dart';
import '../../widget/Auto_Back_Button.dart';

class QuestDetailPage extends StatelessWidget {
  const QuestDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          leading: AutoBackButton(),
          surfaceTintColor: Colors.transparent,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: ResponsiveLayoutExtensions.detail(
            mobileLayout: QuestDetailPageMobile(),
            tabletLayout: QuestPageTablet()
        )
    );
  }
}

import 'package:daylit/pages/quest_result/Quest_Result_Page_Mobile.dart';
import 'package:daylit/pages/quest_result/Quest_Result_Page_Tablet.dart';
import 'package:daylit/widget/Auto_Back_Button.dart';
import 'package:flutter/material.dart';

import '../../responsive/Responsive_Layout_Extensions.dart';

class QuestResultPage extends StatelessWidget {
  const QuestResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AutoBackButton(),
      ),
      body: ResponsiveLayoutExtensions.result(
          mobileLayout: QuestResultPageMobile(),
          tabletLayout: QuestResultPageTablet()
      ),
    );
  }
}

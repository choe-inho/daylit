import 'package:daylit/pages/quest_result/Quest_Result_Page_Mobile.dart';
import 'package:daylit/pages/quest_result/Quest_Result_Page_Tablet.dart';
import 'package:daylit/widget/Auto_Back_Button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../responsive/Responsive_Layout_Extensions.dart';
import '../../widget/Wallet_Widget.dart';

class QuestResultPage extends StatelessWidget {
  const QuestResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: AutoBackButton(),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: WalletWidget(),
          ),
        ],
      ),
      body: ResponsiveLayoutExtensions.result(
          mobileLayout: QuestResultPageMobile(),
          tabletLayout: QuestResultPageTablet()
      ),
    );
  }
}

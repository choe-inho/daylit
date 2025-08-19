import 'package:daylit/widget/Daylit_Logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyQuest extends StatelessWidget {
  const EmptyQuest({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 150.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DayLitLogo.medium(showSun: true),
          SizedBox(height: 8.h,),
          Text('어떤 목표를 세우고\n진행해볼까요?', style: theme.textTheme.titleLarge, textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}

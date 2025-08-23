import 'package:daylit/widget/Daylit_Logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../l10n/app_localizations.dart';

class EmptyQuest extends StatelessWidget {
  const EmptyQuest({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!; // 추가
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 150.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DayLitLogo.medium(showSun: true),
          SizedBox(height: 8.h,),
          Text(l10n.emptyQuestTitle, style: theme.textTheme.titleLarge, textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}

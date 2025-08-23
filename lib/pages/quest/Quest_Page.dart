import 'package:daylit/l10n/app_localizations.dart';
import 'package:daylit/pages/quest/Quest_Page_Mobile.dart';
import 'package:daylit/pages/quest/Quest_Page_Tablet.dart';
import 'package:daylit/provider/Quest_Create_Provider.dart';
import 'package:daylit/widget/Auto_Back_Button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../responsive/Responsive_Layout_Extensions.dart';

class QuestPage extends StatelessWidget {
  const QuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            leading: AutoBackButton(),
            surfaceTintColor: Colors.transparent,
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Text(l10n.quest, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),),
          ),
          body: ChangeNotifierProvider(
              create: (_)=> QuestCreateProvider(),
            builder: (context, child){
                final provider = Provider.of<QuestCreateProvider>(context);
              return ResponsiveLayoutExtensions.quest(
                  mobileLayout: QuestPageMobile(provider: provider,),
                  tabletLayout: QuestPageTablet()
              );
            },
          )
      ),
    );
  }
}

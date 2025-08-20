import 'package:daylit/pages/settings/Settings_Page_Mobile.dart';
import 'package:daylit/pages/settings/Settings_Page_Tablet.dart';
import 'package:daylit/provider/User_Provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../responsive/Responsive_Layout_Extensions.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('설정', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),),
      ),
      body: ResponsiveLayoutExtensions.settings(
          mobileLayout: SettingsPageMobile(),
          tabletLayout: SettingsPageTablet()
      ),
    );
  }
}

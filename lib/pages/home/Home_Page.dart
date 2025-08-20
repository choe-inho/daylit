import 'package:daylit/pages/home/Home_Page_Mobile.dart';
import 'package:daylit/pages/home/Home_Page_Tablet.dart';
import 'package:daylit/provider/Router_Provider.dart';
import 'package:daylit/provider/User_Provider.dart';
import 'package:daylit/widget/Profile_Avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../provider/Quest_Provider.dart';
import '../../responsive/Responsive_Layout_Extensions.dart';
import '../../util/Daylit_Device.dart';
import '../../widget/Daylit_Icon_Button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserProvider userProvider;
  late QuestProvider questProvider;
  late RouterProvider routerProvider;
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    questProvider = Provider.of<QuestProvider>(context);
    routerProvider = Provider.of<RouterProvider>(context);
    final theme = Theme.of(context);
    final isMobile = DaylitDevice.isMobile(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 38.h,
        surfaceTintColor: Colors.transparent,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          DaylitIconButton(onPressed: (){},
              iconData: LucideIcons.search300
          ),
          Padding(
              padding: EdgeInsetsGeometry.only(right: isMobile ? 8.w : 12.w),
              child: InkWell(
                  onTap: (){
                      routerProvider.pushTo(context, '/settings');
                  },
                  child: ProfileAvatar()))
        ],
      ),
      body: ResponsiveLayoutExtensions.home(
          mobileLayout: HomePageMobile(questProvider: questProvider,),
          tabletLayout: HomePageTablet()
      ),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(100)),
          onPressed: (){},
          label: Row(
            children: [
              Icon(LucideIcons.messageCirclePlus400, size: 22.r,),
              SizedBox(width: 8.w,),
              Text('새 목표', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700),)
            ],
          )),
    );
  }
}

import 'package:daylit/provider/Router_Provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../util/Daylit_Device.dart';

class AutoBackButton extends StatelessWidget {
  const AutoBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = DaylitDevice.isMobile(context);
    final RouterProvider routerProvider = Provider.of<RouterProvider>(context);
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: isMobile ? 8.r : 12.r),
      child: IconButton(onPressed: (){
          routerProvider.goBack(context);
      }, icon: Icon(LucideIcons.chevronLeft, color: Theme.of(context).colorScheme.shadow), iconSize: isMobile ? 24.r : 36.r),
    );
  }
}

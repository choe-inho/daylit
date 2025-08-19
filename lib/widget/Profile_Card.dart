import 'package:daylit/util/Daylit_Device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = DaylitDevice.isMobile(context);
    final theme = Theme.of(context);
    if(isMobile){
      return Container(
        padding: EdgeInsetsGeometry.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.secondary,),
          borderRadius: BorderRadiusGeometry.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('test@gmail.com', style: theme.textTheme.bodyMedium,),

          ],
        ),
      );
    }else{
      return Container();
    }
  }
}

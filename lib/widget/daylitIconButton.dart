import 'package:daylit/util/deviceUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DaylitIconButton extends StatelessWidget {
  const DaylitIconButton({super.key, required this.onPressed, required this.iconData, this.size, this.color});
  final VoidCallback onPressed;
  final IconData iconData;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUtils.isMobile(context);

    return Padding(
        padding: EdgeInsetsGeometry.all(isMobile ? 8.r : 12.r),
        child: IconButton(onPressed: onPressed, icon: Icon(iconData, color: color), iconSize: size ?? (isMobile ? 24.r : 36.r),),
    );
  }
}

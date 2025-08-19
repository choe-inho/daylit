import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../util/Daylit_Device.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key, required this.profileUrl, required this.name});
  final String? profileUrl;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DaylitDevice.isMobile(context);

    return Container(
      height: isMobile ? 30.r : 36.r,
      width: isMobile ? 30.r : 36.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary
      ),
      alignment: Alignment.center,
      child: Visibility(
          visible: profileUrl == null,
          child: Text(name?.substring(1) ?? 'Na', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimary),)

      ),
    );
  }
}

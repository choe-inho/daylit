import 'package:daylit/provider/User_Provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../util/Daylit_Colors.dart';
import '../util/Daylit_Device.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key, this.size});
  final double? size;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  late double size;
  late bool isMobile;

  @override
  void initState() {
    if(mounted){
      isMobile = DaylitDevice.isMobile(context);
      if(widget.size == null){
        size = isMobile ? 33.r : 40.r;
      }else{
        size = widget.size!;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).daylitUser;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: user?.profileUrl != null
            ? null
            : DaylitColors.brandGradient,
        border: Border.all(
          color: DaylitColors.brandPrimary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: DaylitColors.brandPrimary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: user?.profileUrl != null
          ? ClipOval(
        child: Image.network(
          user!.profileUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(user, context),
        ),
      )
          : _buildDefaultAvatar(user, context),
    );
  }

  /// 기본 아바타 (이름 이니셜)
  Widget _buildDefaultAvatar(user, context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsetsGeometry.all(size > 60.r ? 12.r : 8.r),
      child: FittedBox(
        child: Text(
          (user?.id?.isNotEmpty == true ? user!.id!.substring(0, 1).toUpperCase() : 'U'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xffffffff))
        ),
      ),
    );
  }
}

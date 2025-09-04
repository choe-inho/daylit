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
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    final isMobile = DaylitDevice.isMobile(context);
    final size = widget.size ?? (isMobile ? 33.r : 40.r);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: userProvider.profileImageUrl != null
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
      child: userProvider.profileImageUrl != null
          ? ClipOval(
        child: Image.network(
          userProvider.profileImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(context, size),
        ),
      )
          : _buildDefaultAvatar(context, size),
    );
  }

  /// 기본 아바타 (이름 이니셜)
  Widget _buildDefaultAvatar(BuildContext context, double size) {
    final fontSize = size * 0.42;
    return Container(
      alignment: Alignment.center,
      child: Text(
        (userProvider.userId!.isNotEmpty == true ? userProvider.userId!.substring(0, 1).toUpperCase() : 'U'),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: fontSize,
          color: const Color(0xffffffff),
        ),
      ),
    );
  }
}
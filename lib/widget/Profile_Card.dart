import 'package:daylit/model/Wallet_Model.dart';
import 'package:daylit/provider/User_Provider.dart';
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:daylit/util/Daylit_Device.dart';
import 'package:daylit/util/Daylit_Social.dart';
import 'package:daylit/widget/Profile_Avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileCard extends StatelessWidget {
  final WalletModel? wallet;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    this.wallet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DaylitDevice.isMobile(context);
    final colors = DaylitColors.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.daylitUser;

    if (isMobile) {
      return _buildMobileCard(context, colors, user);
    } else {
      return _buildTabletCard(context, colors, user);
    }
  }

  /// 모바일용 프로필 카드
  Widget _buildMobileCard(BuildContext context, dynamic colors, user) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surface,
              colors.surface.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: DaylitColors.brandPrimary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.05),
              blurRadius: 40,
              offset: Offset(0, 16),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 프로필 이미지, 이름, 레벨
            _buildProfileHeader(context, colors, user),

            SizedBox(height: 16.h),

            // 구분선
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.divider.withValues(alpha: 0.2),
                    colors.divider,
                    colors.divider.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // 사용자 정보들
            _buildUserInfoSection(context, colors, user),

            if (wallet != null) ...[
              SizedBox(height: 16.h),

              // 구분선
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.divider.withValues(alpha: 0.2),
                      colors.divider,
                      colors.divider.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // 지갑 정보
              _buildWalletSection(context, colors, wallet!),
            ],
          ],
        ),
      ),
    );
  }

  /// 태블릿용 프로필 카드
  Widget _buildTabletCard(BuildContext context, dynamic colors, user) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surface,
              colors.surface.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: DaylitColors.brandPrimary.withValues(alpha: 0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: Offset(0, 12),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // 좌측: 프로필 이미지와 기본 정보
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context, colors, user),
                  SizedBox(height: 20.h),
                  _buildUserInfoSection(context, colors, user),
                ],
              ),
            ),

            if (wallet != null) ...[
              SizedBox(width: 32.w),

              // 우측: 지갑 정보
              Expanded(
                flex: 1,
                child: _buildWalletSection(context, colors, wallet!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 프로필 헤더 (이미지, 이름, 레벨)
  Widget _buildProfileHeader(BuildContext context, dynamic colors, user) {
    return Row(
      children: [
        // 프로필 이미지
        ProfileAvatar(),

        SizedBox(width: 16.w),

        // 이름과 레벨
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 이름
              Text(
                user?.id ?? '사용자',
                style: DaylitColors.heading3(color: colors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 4.h),

              // 레벨과 소셜 타입
              Row(
                children: [
                  // 레벨 배지
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: DaylitColors.brandGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Lv.${user?.level ?? 1}',
                      style: DaylitColors.bodySmall(color: Colors.white).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // 소셜 타입 아이콘
                  if (user?.socialType != null)
                    Container(
                      width: 20.r,
                      height: 20.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user!.socialType.mainColor,
                        border: Border.all(
                          color: colors.border,
                          width: 0.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          user.socialType.path,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }



  /// 사용자 정보 섹션
  Widget _buildUserInfoSection(BuildContext context, dynamic colors, user) {
    return Column(
      children: [
        // 이메일
        _buildInfoRow(
          context,
          colors,
          Icons.email_outlined,
          '이메일',
          user?.email ?? '이메일 없음',
        ),

        SizedBox(height: 12.h),

        // 성별
        _buildInfoRow(
          context,
          colors,
          user?.gender == 'male' ? Icons.man : user?.gender == 'female' ? Icons.woman : Icons.person_outline,
          '성별',
          _getGenderText(user?.gender),
        ),

        SizedBox(height: 12.h),

        // 가입일
        _buildInfoRow(
          context,
          colors,
          Icons.calendar_today_outlined,
          '가입일',
          _getJoinDateText(user?.createAt),
        ),
      ],
    );
  }

  /// 지갑 정보 섹션
  Widget _buildWalletSection(BuildContext context, dynamic colors, WalletModel wallet) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DaylitColors.brandPrimary.withValues(alpha: 0.05),
            DaylitColors.brandSecondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: DaylitColors.brandPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지갑 헤더
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: DaylitColors.brandPrimary,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                '내 지갑',
                style: DaylitColors.bodyMedium(color: colors.textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 총 릿
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '보유 릿',
                style: DaylitColors.bodySmall(color: colors.textSecondary),
              ),
              Row(
                children: [
                  Text(
                    '${wallet.totalLit}',
                    style: DaylitColors.bodyLarge(color: DaylitColors.brandPrimary).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '릿',
                    style: DaylitColors.bodySmall(color: colors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // 보너스 릿 (있을 경우만)
          if (wallet.bonusLit > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '보너스 릿',
                  style: DaylitColors.bodySmall(color: colors.textSecondary),
                ),
                Row(
                  children: [
                    Text(
                      '${wallet.bonusLit}',
                      style: DaylitColors.bodyMedium(color: DaylitColors.success).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '릿',
                      style: DaylitColors.bodySmall(color: colors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],

          // 원화 환산
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                '≈ ${wallet.totalValueInWon.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 상당',
                style: DaylitColors.bodySmall(color: colors.textSecondary).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 행 위젯
  Widget _buildInfoRow(BuildContext context, dynamic colors, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.r,
          color: colors.textSecondary,
        ),
        SizedBox(width: 12.w),
        Text(
          label,
          style: DaylitColors.bodySmall(color: colors.textSecondary).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            value,
            style: DaylitColors.bodyMedium(color: colors.textPrimary).copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// 성별 텍스트 변환
  String _getGenderText(String? gender) {
    switch (gender) {
      case 'male':
        return '남성';
      case 'female':
        return '여성';
      default:
        return '미설정';
    }
  }

  /// 가입일 텍스트 변환
  String _getJoinDateText(DateTime? createAt) {
    if (createAt == null) return '정보 없음';

    final now = DateTime.now();
    final difference = now.difference(createAt).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference < 7) {
      return '$difference일 전';
    } else if (difference < 30) {
      return '${(difference / 7).floor()}주 전';
    } else if (difference < 365) {
      return '${(difference / 30).floor()}개월 전';
    } else {
      return '${createAt.year}.${createAt.month.toString().padLeft(2, '0')}.${createAt.day.toString().padLeft(2, '0')}';
    }
  }
}
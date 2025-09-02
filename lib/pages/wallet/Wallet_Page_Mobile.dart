import 'package:daylit/provider/Wallet_Provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../util/Daylit_Colors.dart';

class WalletPageMobile extends StatelessWidget {
  const WalletPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);
    final theme = Theme.of(context);

    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        final wallet = walletProvider.wallet;
        final walletBalance = wallet?.balanceValueInWon ?? 0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 지갑 잔액 표시 카드
              _buildWalletBalanceCard(context, colors, theme, walletBalance),

              SizedBox(height: 32.h),

              // 지갑 관련 기능 리스트
              _buildWalletActionsList(context, colors, theme),
            ],
          ),
        );
      },
    );
  }

  /// 지갑 잔액 표시 카드
  Widget _buildWalletBalanceCard(
      BuildContext context,
      dynamic colors,
      ThemeData theme,
      int balance,
      ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DaylitColors.brandPrimary,
            DaylitColors.brandPrimary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: DaylitColors.brandPrimary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재 보유 릿',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                LucideIcons.wallet,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20.w,
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                ),
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  'LIT',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 지갑 액션 리스트
  Widget _buildWalletActionsList(
      BuildContext context,
      dynamic colors,
      ThemeData theme,
      ) {
    final actions = [
      {
        'title': '릿 충전',
        'subtitle': '릿을 충전하여 더 많은 기능을 이용해보세요',
        'icon': LucideIcons.diamondPlus,
        'color': Colors.green,
        'onTap': () {
          // TODO: 릿 충전 페이지로 네비게이션
        },
      },
      {
        'title': '릿 사용내역',
        'subtitle': '릿 사용 기록을 확인해보세요',
        'icon': LucideIcons.listCheck,
        'color': Colors.orange,
        'onTap': () {
          // TODO: 릿 사용내역 페이지로 네비게이션
        },
      },
      {
        'title': '충전 내역',
        'subtitle': '릿 충전 기록을 확인해보세요',
        'icon': LucideIcons.walletCards,
        'color': Colors.blue,
        'onTap': () {
          // TODO: 충전 내역 페이지로 네비게이션
        },
      },
      {
        'title': '지갑 설정',
        'subtitle': '지갑 관련 설정을 변경해보세요',
        'icon': LucideIcons.settings,
        'color': Colors.grey,
        'onTap': () {
          // TODO: 지갑 설정 페이지로 네비게이션
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지갑 관리',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),

        SizedBox(height: 16.h),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionListItem(
              context,
              colors,
              theme,
              title: action['title'] as String,
              subtitle: action['subtitle'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
            );
          },
        ),
      ],
    );
  }

  /// 액션 리스트 아이템
  Widget _buildActionListItem(
      BuildContext context,
      dynamic colors,
      ThemeData theme, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colors.divider.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘 컨테이너
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.w,
              ),
            ),

            SizedBox(width: 16.w),

            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 화살표 아이콘
            Icon(
              LucideIcons.chevronRight,
              color: colors.textHint,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:daylit/provider/Router_Provider.dart';
import 'package:daylit/provider/Wallet_Provider.dart';
import 'package:daylit/util/Daylit_Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class WalletWidget extends StatelessWidget {
  const WalletWidget({super.key, this.showPlusButton = true});
  final bool showPlusButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = DaylitColors.of(context);
    final routerProvider = Provider.of<RouterProvider>(context);
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: ()=> routerProvider.pushTo(context, '/wallet'),
          child: Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: colors.border.withValues(alpha:0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha:0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 리트 크리스탈 아이콘
                _buildLitIcon(),

                SizedBox(width: 6.w),

                // 릿 수량 표시
                _buildLitAmount(context, provider, theme, colors),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 리트 크리스탈 아이콘 (SVG를 간소화한 버전)
  Widget _buildLitIcon() {
    return Container(
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: DaylitColors.brandGradient,
        border: Border.all(
          color: DaylitColors.brandPrimary.withValues(alpha:0.3),
          width: 0.5,
        ),
      ),
      padding: EdgeInsets.all(2.r),
      child: Image.asset('assets/icon/lit.png', color: const Color(0xffffffff),)
    );
  }

  /// 릿 수량 텍스트
  Widget _buildLitAmount(BuildContext context, WalletProvider provider, ThemeData theme, dynamic colors) {
    if (provider.isLoading) {
      return SizedBox(
        width: 12.w,
        height: 12.h,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(colors.textSecondary),
        ),
      );
    }

    if (provider.error != null) {
      return Icon(
        Icons.error_outline,
        size: 14.r,
        color: DaylitColors.error,
      );
    }

    // 큰 수는 간소화해서 표시 (예: 1500 -> 1.5K)
    final String displayAmount = _formatLitAmount(provider.totalLit);

    return Container(
      constraints: BoxConstraints(
        minWidth: 33.w
      ),
      alignment: Alignment.centerRight,
      child: Text(
        displayAmount,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  /// 릿 수량 포맷팅
  String _formatLitAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toString();
    }
  }
}


/// 컴팩트한 버전 (숫자만)
class WalletWidgetCompact extends StatelessWidget {
  const WalletWidgetCompact({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              gradient: DaylitColors.brandGradient,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: DaylitColors.brandPrimary.withValues(alpha:0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14.r,
                  color: Colors.white,
                ),
                SizedBox(width: 4.w),
                Text(
                  provider.isLoading ? '...' : provider.totalLit.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

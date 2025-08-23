import 'package:daylit/provider/App_State.dart';
import 'package:daylit/widget/Profile_Card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../handler/Dialog_Handler.dart';
import '../../l10n/app_localizations.dart';
import '../../util/Daylit_Colors.dart';

class SettingsPageMobile extends StatelessWidget {
  const SettingsPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);
    final l10n = AppLocalizations.of(context)!; // 추가

    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CustomScrollView(
          slivers: [
            // 사용자 카드
            SliverToBoxAdapter(
              child: ProfileCard(),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: 24.h),
            ),

            // 메뉴 리스트
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // 계정 & 결제 섹션
                  _buildMenuSection(
                    context,
                    colors,
                    l10n.settingsAccountPayment,
                    [
                      _MenuItemData(
                        icon: LucideIcons.wallet,
                        title: l10n.litCharge,
                        subtitle: l10n.litChargeDesc,
                        onTap: () {},
                        iconColor: DaylitColors.brandPrimary,
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // 앱 설정 섹션
                  _buildMenuSection(
                    context,
                    colors,
                    l10n.settingsAppSettings,
                    [
                      _MenuItemData(
                        icon: LucideIcons.languages,
                        title: l10n.language,
                        subtitle: appState.currentLanguageDisplayName, // 수정된 부분
                        onTap: () {
                          DialogHandler.showLanguageSheet(context: context); // 수정된 부분
                        },
                      ),
                      _MenuItemData(
                        icon: LucideIcons.palette,
                        title: l10n.colorMode,
                        subtitle: _getColorModeDisplayName(context, appState.colorMode),
                        onTap: () {
                          DialogHandler.showColorModeSheet(context: context);
                        },
                      ),
                      _MenuItemData(
                        icon: LucideIcons.bellRing,
                        title: l10n.notifications,
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // 정보 & 정책 섹션
                  _buildMenuSection(
                    context,
                    colors,
                    l10n.settingsInfoPolicy,
                    [
                      _MenuItemData(
                        icon: LucideIcons.fileArchive,
                        title: l10n.termsOfService,
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: LucideIcons.shieldCheck,
                        title: l10n.privacyPolicy,
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: LucideIcons.scrollText,
                        title: l10n.usagePolicy,
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: LucideIcons.copyright,
                        title: l10n.licenses,
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: LucideIcons.badgeInfo,
                        title: l10n.versionInfo,
                        subtitle:'v${appState.version}',
                        onTap: () {},
                        showArrow: false,
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // 계정 관리 섹션
                  _buildMenuSection(
                    context,
                    colors,
                    l10n.settingsAccountManagement,
                    [
                      _MenuItemData(
                        icon: LucideIcons.logOut,
                        title: l10n.logout,
                        onTap: () {},
                        iconColor: DaylitColors.error,
                        titleColor: DaylitColors.error,
                        showArrow: false,
                      ),
                    ],
                  ),

                  SizedBox(height: 80.h), // 하단 여백
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  /// 메뉴 섹션 빌드
  Widget _buildMenuSection(
      BuildContext context,
      dynamic colors,
      String sectionTitle,
      List<_MenuItemData> menuItems,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            sectionTitle,
            style: DaylitColors.heading3(color: colors.textPrimary).copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // 메뉴 컨테이너
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: menuItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == menuItems.length - 1;

              return _buildMenuItem(context, colors, item, isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 메뉴 아이템 빌드
  Widget _buildMenuItem(
      BuildContext context,
      dynamic colors,
      _MenuItemData item,
      bool isLast,
      ) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(
              color: colors.divider.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: (item.iconColor ?? colors.textSecondary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                item.icon,
                size: 20.r,
                color: item.iconColor ?? colors.textSecondary,
              ),
            ),

            SizedBox(width: 16.w),

            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: DaylitColors.bodyLarge(
                      color: item.titleColor ?? colors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle!,
                      style: DaylitColors.bodySmall(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 화살표 (필요한 경우)
            if (item.showArrow) ...[
              SizedBox(width: 8.w),
              Icon(
                LucideIcons.chevronRight,
                size: 16.r,
                color: colors.textHint,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 색상 모드 표시명 반환 (다국어 적용)
  String _getColorModeDisplayName(BuildContext context, String colorMode) {
    final l10n = AppLocalizations.of(context)!;
    switch (colorMode) {
      case 'system':
        return l10n.systemMode;
      case 'light':
        return l10n.lightMode;
      case 'dark':
        return l10n.darkMode;
      default:
        return l10n.systemMode;
    }
  }
}

/// 메뉴 아이템 데이터 클래스
class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showArrow;

  const _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.showArrow = true,
  });
}
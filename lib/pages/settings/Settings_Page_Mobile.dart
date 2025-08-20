import 'package:daylit/provider/App_State.dart';
import 'package:daylit/widget/Profile_Card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../handler/Dialog_Handler.dart';
import '../../util/Daylit_Colors.dart';

class SettingsPageMobile extends StatelessWidget {
  const SettingsPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

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
                    '계정 & 결제',
                    [
                      _MenuItemData(
                        icon: LucideIcons.wallet,
                        title: '릿 충전',
                        subtitle: '릿을 충전하고 새로운 목표를 만들어보세요',
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
                    '앱 설정',
                    [
                      _MenuItemData(
                        icon: LucideIcons.languages,
                        title: '언어',
                        subtitle: appState.currentLanguageDisplayName, // 수정된 부분
                        onTap: () {
                          DialogHandler.showLanguageSheet(context: context); // 수정된 부분
                        },
                      ),
                      _MenuItemData(
                        icon: LucideIcons.palette,
                        title: '색상 모드',
                        subtitle: _getColorModeDisplayName(appState.colorMode),
                        onTap: () {
                          DialogHandler.showColorModeSheet(context: context);
                        },
                      ),
                      _MenuItemData(
                        icon: LucideIcons.bellRing,
                        title: '알림',
                        subtitle: '푸시 알림 및 소리 설정',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // 정보 & 정책 섹션
                  _buildMenuSection(
                    context,
                    colors,
                    '정보 & 정책',
                    [
                      _MenuItemData(
                        icon: LucideIcons.fileArchive,
                        title: '이용약관',
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: LucideIcons.shieldCheck,
                        title: '개인정보처리방침',
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: LucideIcons.scrollText,
                        title: '이용정책',
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: LucideIcons.copyright,
                        title: '라이선스',
                        onTap: () {},
                      ),
                      _MenuItemData(
                        icon: LucideIcons.badgeInfo,
                        title: '버전 정보',
                        subtitle: 'v1.0.0 (최신)',
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
                    '계정 관리',
                    [
                      _MenuItemData(
                        icon: LucideIcons.logOut,
                        title: '로그아웃',
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

  /// 색상 모드 표시명 반환
  String _getColorModeDisplayName(String colorMode) {
    switch (colorMode) {
      case 'system':
        return '시스템 설정 따르기';
      case 'light':
        return '라이트 모드';
      case 'dark':
        return '다크 모드';
      default:
        return '시스템 설정 따르기';
    }
  }

  /// 언어 표시명 반환
  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      default:
        return '한국어';
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
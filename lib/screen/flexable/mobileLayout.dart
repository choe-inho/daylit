import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../router/routerProvider.dart';
import '../../util/daylitColors.dart';

class MobileLayout extends ConsumerWidget {
  final Widget child;

  const MobileLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = DaylitColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: child,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: BottomAppBar(
            color: colors.surface,
            shape: const CircularNotchedRectangle(),
            notchMargin: 4.0,
            child: SizedBox(
              height: 58.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    ref,
                    icon: LucideIcons.house,
                    route: AppRoutes.home,
                  ),
                  SizedBox(width: 55.w), // 중앙 플로팅 버튼 공간
                  _buildNavItem(
                    context,
                    ref,
                    icon: LucideIcons.circleUser,
                    route: AppRoutes.profile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildCenterButton(context, ref),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      WidgetRef ref, {
        required IconData icon,
        required String route,
      }) {
    final colors = DaylitColors.of(context);

    // 현재 라우트 직접 확인
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final isSelected = currentRoute == route;

    return InkWell(
      onTap: () {
        // 직접 GoRouter 사용
        if (currentRoute != route) {
          context.go(route);
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Icon(
          icon,
          color: isSelected ? DaylitColors.brandPrimary : colors.textSecondary,
          size: 20.r,
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context, WidgetRef ref) {
    final colors = DaylitColors.of(context);

    // 현재 라우트 직접 확인
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final isSelected = currentRoute == AppRoutes.routine;

    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        gradient: isSelected
            ? colors.primaryGradient
            : LinearGradient(
          colors: [
            DaylitColors.brandPrimary.withValues(alpha: 0.8),
            DaylitColors.brandSecondary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: DaylitColors.brandPrimary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (currentRoute != AppRoutes.routine) {
              context.go(AppRoutes.routine);
            }
          },
          borderRadius: BorderRadius.circular(30.r),
          child: Icon(
            LucideIcons.calendarCheck2,
            color: Colors.white,
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}
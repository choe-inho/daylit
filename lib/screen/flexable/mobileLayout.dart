import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../router/routerManager.dart';
import '../../util/daylitColors.dart';

class MobileLayout extends StatelessWidget {
  final Widget child;

  const MobileLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = DaylitColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: child,
      extendBody: true, // 바텀 네비게이션 뒤로 body 확장
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
            shape: const CircularNotchedRectangle(), // 센터 버튼용 홈
            notchMargin: 4.0, // 8.0 → 6.0으로 줄임
            child: SizedBox(
              height: 58.h, // 65.h → 60.h로 줄임
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 홈
                  _buildNavItem(
                    context,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: '홈',
                    route: AppRoutes.home,
                  ),
                  // 검색
                  _buildNavItem(
                    context,
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search,
                    label: '검색',
                    route: AppRoutes.search,
                  ),
                  // 센터 루틴 버튼 공간
                  SizedBox(width: 55.w), // 60.w → 55.w로 줄임
                  // 친구
                  _buildNavItem(
                    context,
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    label: '친구',
                    route: AppRoutes.friends,
                  ),
                  // 프로필
                  _buildNavItem(
                    context,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: '프로필',
                    route: AppRoutes.profile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildCenterRoutineButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // 일반 네비게이션 아이템
  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required IconData activeIcon,
        required String label,
        required String route,
      }) {
    final colors = DaylitColors.of(context);
    final isSelected = _isRouteSelected(context, route);

    return InkWell(
      onTap: () => context.routerManager.navigateTo(route),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? DaylitColors.brandPrimary : colors.textSecondary,
              size: 20.r,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? DaylitColors.brandPrimary : colors.textSecondary,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 센터 루틴 버튼 (강조)
  Widget _buildCenterRoutineButton(BuildContext context) {
    final colors = DaylitColors.of(context);
    final isSelected = _isRouteSelected(context, AppRoutes.routine);

    return Container(
      width: 60.w, // 65.w → 60.w로 줄임
      height: 60.w, // 65.w → 60.w로 줄임
      decoration: BoxDecoration(
        gradient: isSelected
            ? colors.primaryGradient
            : LinearGradient(
          colors: [
            DaylitColors.brandPrimary.withValues(alpha: 0.8),
            DaylitColors.brandSecondary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(30.r), // 32.5.r → 30.r로 줄임
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
          onTap: () => context.routerManager.navigateTo(AppRoutes.routine),
          borderRadius: BorderRadius.circular(30.r), // 32.5.r → 30.r로 줄임
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.check_circle_outline,
                color: Colors.white,
                size: 26.sp, // 28.sp → 26.sp로 줄임
              ),
              SizedBox(height: 1.h), // 2.h → 1.h로 줄임
              Text(
                '루틴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp, // 9.sp → 8.sp로 줄임
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isRouteSelected(BuildContext context, String route) {
    final currentLocation = RouterManager.instance.router.state.uri.toString();
    return currentLocation == route;
  }
}
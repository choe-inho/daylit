import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../router/routerProvider.dart';
import '../../util/daylitColors.dart';

class MobileLayout extends ConsumerWidget {
  final Widget child;

  const MobileLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = DaylitColors.of(context);
    final navigationHelper = ref.read(navigationHelperProvider);

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
                  _buildOptimizedNavItem(
                    context,
                    ref,
                    navigationHelper: navigationHelper,
                    icon: LucideIcons.house,
                    route: AppRoutes.home,
                  ),
                  _buildOptimizedNavItem(
                    context,
                    ref,
                    navigationHelper: navigationHelper,
                    icon: LucideIcons.search,
                    route: AppRoutes.search,
                  ),
                  SizedBox(width: 55.w),
                  _buildOptimizedNavItem(
                    context,
                    ref,
                    navigationHelper: navigationHelper,
                    icon: LucideIcons.users,
                    route: AppRoutes.friends,
                  ),
                  _buildOptimizedNavItem(
                    context,
                    ref,
                    navigationHelper: navigationHelper,
                    icon: LucideIcons.circleUser,
                    route: AppRoutes.profile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildOptimizedCenterButton(context, ref, navigationHelper),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildOptimizedNavItem(
      BuildContext context,
      WidgetRef ref, {
        required dynamic navigationHelper,
        required IconData icon,
        required String route,
      }) {
    final colors = DaylitColors.of(context);

    // ✅ Provider로 선택 상태만 감시 (최적화)
    final isSelected = ref.watch(isRouteSelectedProvider(route));

    return InkWell(
      onTap: () => navigationHelper.navigateTo(route),
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

  Widget _buildOptimizedCenterButton(
      BuildContext context,
      WidgetRef ref,
      dynamic navigationHelper,
      ) {
    final colors = DaylitColors.of(context);
    final isSelected = ref.watch(isRouteSelectedProvider(AppRoutes.routine));

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
          onTap: () => navigationHelper.navigateTo(AppRoutes.routine),
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

// 현재 라우트만 감시하는 Provider
final currentRouteProvider = Provider<String>((ref) {
  final router = ref.watch(routerProvider);
  try {
    return router.state.uri.toString();
  } catch (e) {
    return AppRoutes.home; // 기본값
  }
});

// 특정 라우트 선택 상태만 감시하는 Provider
final isRouteSelectedProvider = Provider.family<bool, String>((ref, route) {
  final currentRoute = ref.watch(currentRouteProvider);
  return currentRoute == route;
});
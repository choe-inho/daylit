import 'package:flutter/material.dart';

import '../../router/routerProvider.dart';

class TabletLayout extends StatelessWidget {
  final Widget child;

  const TabletLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 사이드 네비게이션
          Container(
            width: 80,
            color: Colors.grey[100],
            child: Column(
              children: [
                const SizedBox(height: 60),
                // 로고
                const Icon(Icons.sunny, color: Colors.blue, size: 32),
                const SizedBox(height: 40),
                // 네비게이션 아이템들
                _buildNavItem(context, Icons.home, AppRoutes.home),
                _buildNavItem(context, Icons.check_circle, AppRoutes.routine),
                _buildNavItem(context, Icons.people, AppRoutes.friends),
                _buildNavItem(context, Icons.person, AppRoutes.profile),
              ],
            ),
          ),
          // 메인 컨텐츠
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String route) {
    final isSelected = context.routerHelper.router.state.uri.toString() == route;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey,
          size: 28,
        ),
        onPressed: () => context.routerHelper.navigateTo(route),
      ),
    );
  }
}
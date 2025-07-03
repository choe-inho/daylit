import 'package:daylit/screen/flexable/tabletLayout.dart';
import 'package:flutter/material.dart';

import 'mobileLayout.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 화면 크기에 따라 네비게이션 방식 결정
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;

    if (isTablet) {
      return TabletLayout(child: child);
    } else {
      return MobileLayout(child: child);
    }
  }
}
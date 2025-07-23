import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet
}

class DaylitDevice {
  // 디바이스 타입 감지
  static DeviceType getDeviceType(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    // 태블릿 (일반적으로 600dp 이상)
    if (shortestSide >= 600) {
      return DeviceType.tablet;
    }

    // 모바일
    return DeviceType.mobile;
  }

  // 반응형 값 반환
  static T responsive<T>(
      BuildContext context, {
        required T mobile,
        T? tablet,
      }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  // 디바이스별 디자인 사이즈 반환
  static Size getDesignSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.tablet:
        return const Size(768, 1024); // 태블릿
      case DeviceType.mobile:
        return const Size(375, 812); // 모바일 (iPhone 기준)
    }
  }

  // 현재 디바이스가 특정 타입인지 확인
  static bool isMobile(BuildContext context) => getDeviceType(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => getDeviceType(context) == DeviceType.tablet;
}

// 반응형 레이아웃 빌더
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType)? builder;
  final Widget? mobile;
  final Widget? tablet;

  const ResponsiveBuilder({
    super.key,
    this.builder,
    this.mobile,
    this.tablet,
  }) : assert(builder != null || mobile != null, 'Either builder or mobile must be provided');

  @override
  Widget build(BuildContext context) {
    final deviceType = DaylitDevice.getDeviceType(context);

    if (builder != null) {
      return builder!(context, deviceType);
    }

    switch (deviceType) {
      case DeviceType.tablet:
        return tablet ?? mobile!;
      case DeviceType.mobile:
        return mobile!;
    }
  }
}

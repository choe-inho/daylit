import 'package:daylit/router/routerProvider.dart';
import 'package:daylit/util/daylitColors.dart';
import 'package:daylit/util/deviceUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    // ProviderScope로 앱 전체를 감싸기
    const ProviderScope(
      child: DayLitDriver(),
    ),
  );
}

class DayLitDriver extends ConsumerWidget {
  const DayLitDriver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          // 여기서 context 사용 가능
          final designSize = DeviceUtils.getDesignSize(context);

          return ScreenUtilInit(
            designSize: designSize,
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return BackPressHandler(
                child: DayLitApp(),
              );
            },
          );
        },
      ),
    );
  }
}

class DayLitApp extends ConsumerWidget {
  const DayLitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod으로 Router 가져오기
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Daylit',
      theme: DaylitColors.getLightTheme(),
      darkTheme: DaylitColors.getDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
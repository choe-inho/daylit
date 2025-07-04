import 'package:daylit/router/routerManager.dart';
import 'package:daylit/util/daylitColors.dart';
import 'package:daylit/util/deviceUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // RouterManager 초기화
  RouterManager.instance.initialize();

  runApp(const DayLitDriver());
}

class DayLitDriver extends StatelessWidget {
  const DayLitDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                child: MaterialApp.router(
                  title: 'Daylit',
                  theme: DaylitColors.getLightTheme(),
                  darkTheme: DaylitColors.getDarkTheme(),
                  themeMode: ThemeMode.system,
                  routerConfig: RouterManager.instance.router,
                  debugShowCheckedModeBanner: false,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:daylit/pages/auth/Login_Page_Mobile.dart';
import 'package:daylit/pages/auth/Login_Page_Tablet.dart';

import '../../responsive/Responsive_Layout_Extensions.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayoutExtensions.auth(
          mobileLayout: LoginPageMobile(),
          tabletLayout: LoginPageTablet()
      )
    );
  }
}

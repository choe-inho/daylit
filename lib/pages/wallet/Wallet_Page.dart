import 'package:daylit/pages/wallet/Wallet_Page_Mobile.dart';
import 'package:daylit/pages/wallet/Wallet_Page_Tablet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../responsive/Responsive_Layout_Extensions.dart';
import '../../widget/Auto_Back_Button.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          leading: AutoBackButton(),
          surfaceTintColor: Colors.transparent,
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text('지갑', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),),
        ),
        body: ResponsiveLayoutExtensions.wallet(
            mobileLayout: WalletPageMobile(),
            tabletLayout: WalletPageTablet()
        )
    );
  }
}

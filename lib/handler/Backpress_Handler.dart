import 'package:daylit/provider/Router_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackPressHandler extends StatelessWidget {
  const BackPressHandler({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = Provider.of<RouterProvider>(context);
    return PopScope(
        onPopInvokedWithResult: (canPop, result){
          router.
        },
        child: child);
  }
}

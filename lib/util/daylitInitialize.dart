import 'package:daylit/router/routerProvider.dart';
import 'package:flutter/material.dart';

class DaylitInitialize extends StatefulWidget {
  const DaylitInitialize({super.key});

  @override
  State<DaylitInitialize> createState() => _DaylitInitializeState();
}

class _DaylitInitializeState extends State<DaylitInitialize> {

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), ()=> goLogin);
    super.initState();
  }

  void goLogin() => context.routerHelper.goLogin();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

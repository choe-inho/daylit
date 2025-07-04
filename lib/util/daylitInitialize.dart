import 'package:daylit/router/routerManager.dart';
import 'package:flutter/material.dart';

class DaylitInitialize extends StatefulWidget {
  const DaylitInitialize({super.key});

  @override
  State<DaylitInitialize> createState() => _DaylitInitializeState();
}

class _DaylitInitializeState extends State<DaylitInitialize> {

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), ()=> RouterManager.instance.goLogin());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

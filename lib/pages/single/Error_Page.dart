import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.error});
  final GoException? error;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

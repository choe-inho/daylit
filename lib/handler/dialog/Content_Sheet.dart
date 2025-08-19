import 'package:flutter/material.dart';

class ContentSheet extends StatelessWidget {
  const ContentSheet({super.key, required this.title, this.subtitle, this.image, required this.showHandle});
  final String title;
  final String? subtitle;
  final String? image;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

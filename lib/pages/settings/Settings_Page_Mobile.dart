import 'package:daylit/widget/Profile_Card.dart';
import 'package:flutter/material.dart';

class SettingsPageMobile extends StatelessWidget {
  const SettingsPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        //사용자 카드
        SliverToBoxAdapter(
          child: ProfileCard(),
        )
      ],
    );
  }
}

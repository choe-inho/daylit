import 'package:daylit/provider/Router_Provider.dart';
import 'package:daylit/widget/Daylit_Icon_Button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late RouterProvider routerProvider;
  @override
  Widget build(BuildContext context){
    routerProvider = Provider.of<RouterProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: DaylitIconButton(onPressed: (){
          routerProvider.goBack(context);
        }, iconData: LucideIcons.arrowLeft500),
      ),
    );
  }
}

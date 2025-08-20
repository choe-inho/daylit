// lib/init/Initialize_App.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/App_State.dart';
import '../provider/User_Provider.dart';
import '../provider/Router_Provider.dart';

class InitializeApp extends StatefulWidget {
  const InitializeApp({super.key});

  @override
  State<InitializeApp> createState() => _InitializeAppState();
}

class _InitializeAppState extends State<InitializeApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialization();
    });
  }

  Future<void> _startInitialization() async {
    if (!mounted) return;

    final appState = context.read<AppState>();
    final userProvider = context.read<UserProvider>();
    final routerProvider = context.read<RouterProvider>();

    await appState.initializeApp(
      context: context,
      userProvider: userProvider,
      routerProvider: routerProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isInitializing) {
          return _buildLoadingScreen(appState);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingScreen(AppState appState) {
    return Scaffold();
  }
}
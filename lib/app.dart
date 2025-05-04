import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/debug_tools/debug_tools_menu.dart';

class IndoorNavigationApp extends StatelessWidget {
  const IndoorNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indoor Navigation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DebugToolsMenu(), // debug-экран
    );
  }
}

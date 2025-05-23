import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/ui/settings_screen.dart';
import 'package:navigation_diploma_client/features/debug_tools/debug_tools_menu.dart';
import 'package:navigation_diploma_client/features/ui/world_map_screen.dart';

class IndoorNavigationApp extends StatefulWidget {
  const IndoorNavigationApp({super.key});

  @override
  State<IndoorNavigationApp> createState() => _IndoorNavigationAppState();
}

class _IndoorNavigationAppState extends State<IndoorNavigationApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const WorldMapScreen(
      buildingLocation: null, // координаты будут заданы позже
      buildingName: null,
    ),
    const SettingsScreen(),
    const DebugToolsMenu(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indoor Navigation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Карта'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Настройки',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bug_report),
              label: 'Debug',
            ),
          ],
        ),
      ),
    );
  }
}

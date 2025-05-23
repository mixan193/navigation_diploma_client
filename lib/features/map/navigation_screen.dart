import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/map/map_view.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int buildingId = 1; // Пример
    return MapView(buildingId: buildingId);
  }
}
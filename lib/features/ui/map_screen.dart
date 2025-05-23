import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/map/map_view.dart';

Future<Map<String, dynamic>?> fetchUserPosition(int buildingId) async {
  // TODO: Реальный источник данных
  return null;
}

class MapScreen extends StatelessWidget {
  final int buildingId;
  const MapScreen({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context) {
    return MapView(buildingId: buildingId);
  }
}

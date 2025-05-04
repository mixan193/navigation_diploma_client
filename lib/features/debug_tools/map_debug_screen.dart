import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:navigation_diploma_client/features/map/map_controller.dart';
import 'package:navigation_diploma_client/features/map/map_repository.dart';
import 'package:navigation_diploma_client/features/map/map_view.dart';
import 'package:navigation_diploma_client/features/storage/map_dao.dart';

class MapDebugScreen extends StatelessWidget {
  const MapDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Инициализируем MapController с репозиторием и DAO.
      create: (_) => MapController(MapRepository(MapDao()))..loadMapData(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Map Debug Screen')),
        body: const MapView(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/map/map_controller.dart';
import 'package:navigation_diploma_client/features/map/map_repository.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  final int buildingId;
  final Map<String, dynamic>? userPosition;
  const MapView({super.key, required this.buildingId, this.userPosition});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapController>(
      create: (_) => MapController(MapRepository()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Map View')),
        body: Consumer<MapController>(
          builder: (context, controller, child) {
            if (controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.mapData == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    controller.loadMap(buildingId);
                  },
                  child: const Text('Load Map'),
                ),
              );
            }
            // Пример отображения userPosition (если есть)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Map loaded: \\${controller.mapData!.buildingName}'),
                  if (userPosition != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Высота: '
                        '${userPosition!['altitude'] != null ? userPosition!['altitude'].toStringAsFixed(2) : '-'} м'
                        '${userPosition!['accuracy'] != null ? ' (±${userPosition!['accuracy'].toStringAsFixed(1)} м)' : ''}',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

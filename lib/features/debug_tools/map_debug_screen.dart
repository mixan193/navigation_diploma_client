import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';
import 'package:navigation_diploma_client/features/storage/map_dao.dart';

class MapDebugScreen extends StatefulWidget {
  const MapDebugScreen({super.key});

  @override
  State<MapDebugScreen> createState() => _MapDebugScreenState();
}

class _MapDebugScreenState extends State<MapDebugScreen> {
  final MapDao _mapDao = GetIt.instance<MapDao>();
  late Future<MapResponse> _mapFuture;

  @override
  void initState() {
    super.initState();
    // Запрашиваем карту для buildingId = 1
    _mapFuture = _mapDao.fetchMap(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Map'),
      ),
      body: FutureBuilder<MapResponse>(
        future: _mapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final response = snapshot.data!;
          final floors = response.floors;

          return ListView.builder(
            itemCount: floors.length,
            itemBuilder: (context, index) {
              final floor = floors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text('Этаж ${floor.floor}'),
                  subtitle: Text(
                    'Полигона точек: ${floor.polygon.length}, '
                    'Access Point’ов: ${floor.accessPoints.length}',
                  ),
                  onTap: () {
                    // Здесь можно добавить подробный просмотр полигонов и AP
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/di/service_locator.dart';
import 'package:navigation_diploma_client/features/map/map_repository.dart';
import 'package:navigation_diploma_client/features/map/map_view.dart';

// Заглушка: функция получения текущей позиции пользователя.
// Здесь используйте свой реальный метод (например, из локального хранилища, сервера, state management и т.п.)
Future<Map<String, dynamic>?> fetchUserPosition(int buildingId) async {
  // Пример — заменить на ваш запрос к API или локальной БД
  // {'x': ..., 'y': ..., 'z': ..., 'floor': ...}
  try {
    final repo = locator<MapRepository>();
    // Предположим, repo.getLastUserPosition(buildingId) реализован вами
    return await repo.getLastUserPosition(buildingId);
  } catch (_) {
    return null;
  }
}

class MapScreen extends StatefulWidget {
  final int buildingId;
  const MapScreen({Key? key, required this.buildingId}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<String, dynamic>? userPosition;

  @override
  void initState() {
    super.initState();
    _loadUserPosition();
  }

  Future<void> _loadUserPosition() async {
    final pos = await fetchUserPosition(widget.buildingId);
    setState(() {
      userPosition = pos;
    });
  }

  // Метод, который можно вызвать после очередного скана для обновления позиции:
  void updateUserPosition(Map<String, dynamic> newPos) {
    setState(() {
      userPosition = newPos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта здания'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить позицию',
            onPressed: _loadUserPosition,
          ),
        ],
      ),
      body: MapView(
        buildingId: widget.buildingId,
        userPosition: userPosition,
      ),
    );
  }
}

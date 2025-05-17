import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/di/service_locator.dart';
import 'package:navigation_diploma_client/features/map/map_repository.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';

class MapView extends StatefulWidget {
  final int buildingId;
  final Map<String, dynamic>? userPosition; // можно передавать x, y, z, floor
  const MapView({Key? key, required this.buildingId, this.userPosition}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late Future<MapResponse> _mapFuture;

  @override
  void initState() {
    super.initState();
    _mapFuture = locator<MapRepository>().fetchMap(widget.buildingId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MapResponse>(
      future: _mapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }
        final mapData = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(8),
          children: mapData.floors
              .map((floor) => FloorCard(
                    floor: floor,
                    userPosition: widget.userPosition,
                  ))
              .toList(),
        );
      },
    );
  }
}

class FloorCard extends StatelessWidget {
  final FloorSchema floor;
  final Map<String, dynamic>? userPosition;
  const FloorCard({Key? key, required this.floor, this.userPosition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Этаж ${floor.floor}',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: FloorPainter(floor, userPosition),
            ),
          ),
        ],
      ),
    );
  }
}

class FloorPainter extends CustomPainter {
  final FloorSchema floor;
  final Map<String, dynamic>? userPosition;
  FloorPainter(this.floor, this.userPosition);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Масштабируем полигон по min/max координатам
    if (floor.polygon.isEmpty) return;

    final xs = floor.polygon.map((pt) => pt[0]).toList();
    final ys = floor.polygon.map((pt) => pt[1]).toList();
    final minX = xs.reduce((a, b) => a < b ? a : b);
    final maxX = xs.reduce((a, b) => a > b ? a : b);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);

    Offset mapPoint(double x, double y) {
      // Нормализация в 0..1, затем масштаб на размер канваса
      final nx = (x - minX) / (maxX - minX == 0 ? 1 : maxX - minX);
      final ny = (y - minY) / (maxY - minY == 0 ? 1 : maxY - minY);
      // Y инвертируем для привычной ориентации
      return Offset(nx * size.width, (1 - ny) * size.height);
    }

    // Рисуем полигон этажа
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.blue;
    final polyPoints = floor.polygon
        .map((pt) => mapPoint(pt[0], pt[1]))
        .toList();
    final path = Path()..addPolygon(polyPoints, true);
    canvas.drawPath(path, borderPaint);

    // Рисуем точки доступа
    final apPaint = Paint()..style = PaintingStyle.fill..color = Colors.red;
    for (var ap in floor.accessPoints) {
      final p = mapPoint(ap.x, ap.y);
      canvas.drawCircle(p, 5, apPaint);
    }

    // Рисуем пользователя, если есть позиция и нужный этаж
    if (userPosition != null && userPosition!['floor'] == floor.floor) {
      final double? ux = userPosition!['x']?.toDouble();
      final double? uy = userPosition!['y']?.toDouble();
      if (ux != null && uy != null) {
        final userPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.green;
        final up = mapPoint(ux, uy);
        canvas.drawCircle(up, 9, userPaint);

        // Тень/подсветка для защиты
        final haloPaint = Paint()
          ..color = Colors.green.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(up, 18, haloPaint);

        // Текст "Вы"
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'Вы',
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, up + Offset(10, -10));
      }
    }
  }

  @override
  bool shouldRepaint(covariant FloorPainter old) => true;
}

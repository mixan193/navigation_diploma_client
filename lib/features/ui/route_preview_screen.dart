import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/map/map_repository.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';
import 'package:navigation_diploma_client/features/networking/route_model.dart';
import 'package:navigation_diploma_client/features/map/map_response.dart';

class RoutePreviewScreen extends StatefulWidget {
  final int buildingId;
  final RouteModel route;
  final MapResponse mapData;

  const RoutePreviewScreen({
    Key? key,
    required this.buildingId,
    required this.route,
    required this.mapData,
  }) : super(key: key);

  @override
  State<RoutePreviewScreen> createState() => _RoutePreviewScreenState();
}

class _RoutePreviewScreenState extends State<RoutePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    final path = widget.route.path; // List<RoutePoint>
    final floor = path.isNotEmpty ? path.first.floor : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Маршрут'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 12),
            Expanded(
              child: _RouteMapView(
                mapData: widget.mapData,
                path: path,
                floor: floor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final points = widget.route.path;
    final totalLength = widget.route.length; // в метрах
    final floors = points.map((e) => e.floor).toSet().join(", ");

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Длина маршрута: ${totalLength.toStringAsFixed(1)} м",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("Этажи на маршруте: $floors"),
            const SizedBox(height: 4),
            Text("Количество точек: ${points.length}"),
          ],
        ),
      ),
    );
  }
}

class _RouteMapView extends StatelessWidget {
  final MapResponse mapData;
  final List<RoutePoint> path;
  final int? floor;

  const _RouteMapView({
    Key? key,
    required this.mapData,
    required this.path,
    required this.floor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final floorData = mapData.floors.firstWhere(
      (f) => f.floor == floor,
      orElse: () => mapData.floors.first,
    );

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RoutePainter(floorData, path),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final FloorSchema floor;
  final List<RoutePoint> path;

  _RoutePainter(this.floor, this.path);

  @override
  void paint(Canvas canvas, Size size) {
    // Вычисление масштаба полигона
    if (floor.polygon.isEmpty) return;

    final xs = floor.polygon.map((pt) => pt[0]).toList();
    final ys = floor.polygon.map((pt) => pt[1]).toList();
    final minX = xs.reduce((a, b) => a < b ? a : b);
    final maxX = xs.reduce((a, b) => a > b ? a : b);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);

    Offset mapPoint(double x, double y) {
      final nx = (x - minX) / (maxX - minX == 0 ? 1 : maxX - minX);
      final ny = (y - minY) / (maxY - minY == 0 ? 1 : maxY - minY);
      return Offset(nx * size.width, (1 - ny) * size.height);
    }

    // Рисуем полигон этажа
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.blue;
    final polyPoints = floor.polygon.map((pt) => mapPoint(pt[0], pt[1])).toList();
    final pathPoly = Path()..addPolygon(polyPoints, true);
    canvas.drawPath(pathPoly, borderPaint);

    // Рисуем маршрут
    if (path.isNotEmpty) {
      final routePaint = Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      final points = path
          .where((p) => p.floor == floor.floor)
          .map((p) => mapPoint(p.x, p.y))
          .toList();
      if (points.length > 1) {
        final routePath = Path()..moveTo(points.first.dx, points.first.dy);
        for (final pt in points.skip(1)) {
          routePath.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(routePath, routePaint);
      }
      // Отметить начало/конец
      if (points.isNotEmpty) {
        final startPaint = Paint()..color = Colors.green..style = PaintingStyle.fill;
        final endPaint = Paint()..color = Colors.red..style = PaintingStyle.fill;
        canvas.drawCircle(points.first, 9, startPaint);
        canvas.drawCircle(points.last, 9, endPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => true;
}

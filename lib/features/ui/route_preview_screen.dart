import 'dart:math';

import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';
import 'package:navigation_diploma_client/features/networking/route_model.dart';

class RoutePreviewScreen extends StatefulWidget {
  final int buildingId;
  final RouteModel route;
  final MapResponse mapData;

  const RoutePreviewScreen({
    super.key,
    required this.buildingId,
    required this.route,
    required this.mapData,
  });

  @override
  State<RoutePreviewScreen> createState() => _RoutePreviewScreenState();
}

class _RoutePreviewScreenState extends State<RoutePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    final path = widget.route.points;
    final floor =
        path.isNotEmpty ? path.first.floor : widget.mapData.floors.first.floor;
    return Scaffold(
      appBar: AppBar(title: const Text('Маршрут')),
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
    final points = widget.route.points;
    final totalLength = widget.route.length;
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
  final int floor;

  const _RouteMapView({
    required this.mapData,
    required this.path,
    required this.floor,
  });

  @override
  Widget build(BuildContext context) {
    final floorData = mapData.floors.firstWhere((f) => f.floor == floor);

    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(painter: _RoutePainter(floorData, path)),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final FloorSchema floor;
  final List<RoutePoint> path;

  _RoutePainter(this.floor, this.path);

  @override
  void paint(Canvas canvas, Size size) {
    if (floor.polygon.isEmpty) return;
    final xs = floor.polygon.map((pt) => pt[0]).toList();
    final ys = floor.polygon.map((pt) => pt[1]).toList();

    Offset mapPoint(double x, double y) {
      final nx =
          (x - xs.reduce(min)) /
          (xs.reduce(max) - xs.reduce(min) == 0
              ? 1
              : xs.reduce(max) - xs.reduce(min));
      final ny =
          (y - ys.reduce(min)) /
          (ys.reduce(max) - ys.reduce(min) == 0
              ? 1
              : ys.reduce(max) - ys.reduce(min));
      return Offset(nx * size.width, (1 - ny) * size.height);
    }

    final borderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.blue;
    final polyPoints =
        floor.polygon.map((pt) => mapPoint(pt[0], pt[1])).toList();
    final pathPoly = Path()..addPolygon(polyPoints, true);
    canvas.drawPath(pathPoly, borderPaint);

    if (path.isNotEmpty) {
      final routePaint =
          Paint()
            ..color = Colors.deepOrange
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke;
      final points =
          path
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
      if (points.isNotEmpty) {
        final startPaint =
            Paint()
              ..color = Colors.green
              ..style = PaintingStyle.fill;
        final endPaint =
            Paint()
              ..color = Colors.red
              ..style = PaintingStyle.fill;
        canvas.drawCircle(points.first, 9, startPaint);
        canvas.drawCircle(points.last, 9, endPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

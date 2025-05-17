import 'dart:math';
import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/map/map_model.dart';
import 'package:navigation_diploma_client/features/notes/poi_manager.dart';
import 'package:navigation_diploma_client/features/routing/pathfinder.dart';
import 'package:navigation_diploma_client/models/route.dart';
import 'package:navigation_diploma_client/models/room.dart';

class EvacuationSimulator extends StatefulWidget {
  final MapModel mapModel;
  final String startRoomNodeId;

  const EvacuationSimulator({
    Key? key,
    required this.mapModel,
    required this.startRoomNodeId,
  }) : super(key: key);

  @override
  State<EvacuationSimulator> createState() => _EvacuationSimulatorState();
}

class _EvacuationSimulatorState extends State<EvacuationSimulator> {
  RouteModel? routeToExit;
  POI? nearestExit;

  late final Map<String, RoomModel> roomGraph;

  @override
  void initState() {
    super.initState();
    roomGraph = _buildRoomGraph(widget.mapModel);
    _calculateEvacuationRoute();
  }

  Map<String, RoomModel> _buildRoomGraph(MapModel mapModel) {
    final Map<String, RoomModel> result = {};
    for (final floor in mapModel.floors) {
      for (final room in floor.rooms) {
        result[room.id] = room;
      }
    }
    return result;
  }

  RouteModel findShortestRoute(
    Map<String, RoomModel> graph,
    String fromNodeId,
    String toNodeId,
  ) {
    final pathfinder = Pathfinder();
    final startRoom = graph[fromNodeId];
    final endRoom = graph[toNodeId];
    if (startRoom == null || endRoom == null) {
      return RouteModel(
        id: 'empty',
        points: [],
        length: 0.0,
        z: 0.0,
        floorFrom: 0,
        floorTo: 0,
      );
    }
    return pathfinder.findRoute(startRoom, endRoom, graph);
  }

  void _calculateEvacuationRoute() {
    final exits = POIManager().pois.where((poi) => poi.type == POIType.exit).toList();

    if (exits.isEmpty) {
      setState(() {
        routeToExit = null;
        nearestExit = null;
      });
      return;
    }

    double? minLen;
    RouteModel? bestRoute;
    POI? bestExit;

    for (final exit in exits) {
      RoomModel? nearestRoom;
      double minDist = double.infinity;
      for (final room in roomGraph.values) {
        final dx = room.x - exit.x;
        final dy = room.y - exit.y;
        final dz = room.z - (exit.z ?? 0.0);
        final dist = sqrt(dx * dx + dy * dy + dz * dz);
        if (dist < minDist) {
          minDist = dist;
          nearestRoom = room;
        }
      }
      if (nearestRoom == null) continue;

      final route = findShortestRoute(roomGraph, widget.startRoomNodeId, nearestRoom.id);
      if (minLen == null || route.length < minLen) {
        minLen = route.length;
        bestRoute = route;
        bestExit = exit;
      }
    }

    setState(() {
      routeToExit = bestRoute;
      nearestExit = bestExit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Эмуляция эвакуации'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Пересчитать",
            onPressed: _calculateEvacuationRoute,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: routeToExit == null
            ? const Center(child: Text("Нет доступных выходов или маршрутов"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nearestExit != null)
                    Card(
                      child: ListTile(
                        leading: Icon(nearestExit!.type.icon),
                        title: Text("Ближайший выход: ${nearestExit!.name}"),
                        subtitle: Text(
                          "Этаж: ${nearestExit!.floor}, x: ${nearestExit!.x.toStringAsFixed(1)}, y: ${nearestExit!.y.toStringAsFixed(1)}",
                        ),
                      ),
                    ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Длина маршрута: ${routeToExit!.length.toStringAsFixed(1)} м\n"
                        "Число точек: ${routeToExit!.points.length}",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: EvacuationRouteMap(
                      mapModel: widget.mapModel,
                      route: routeToExit!,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class EvacuationRouteMap extends StatelessWidget {
  final MapModel mapModel;
  final RouteModel route;

  const EvacuationRouteMap({
    Key? key,
    required this.mapModel,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int floor = route.points.isNotEmpty ? route.points.first.floor : mapModel.floors.first.floorNumber;
    final floorModel = mapModel.floors.firstWhere((f) => f.floorNumber == floor);

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _EvacuationRoutePainter(floorModel, route),
      ),
    );
  }
}

class _EvacuationRoutePainter extends CustomPainter {
  final FloorModel floor;
  final RouteModel route;

  _EvacuationRoutePainter(this.floor, this.route);

  @override
  void paint(Canvas canvas, Size size) {
    final paintRoom = Paint()..color = Colors.blue..style = PaintingStyle.fill;
    for (final room in floor.rooms) {
      final p = Offset(room.x / 100 * size.width, (1 - room.y / 100) * size.height);
      canvas.drawCircle(p, 5, paintRoom);
      final textStyle = TextStyle(color: Colors.blue[700], fontSize: 10);
      final tp = TextPainter(
        text: TextSpan(text: room.name, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout(minWidth: 0, maxWidth: 60);
      tp.paint(canvas, p + const Offset(7, -7));
    }

    if (route.points.isNotEmpty) {
      final routePaint = Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      final points = route.points
          .where((p) => p.floor == floor.floorNumber)
          .map((p) => Offset(p.x / 100 * size.width, (1 - p.y / 100) * size.height))
          .toList();

      if (points.length > 1) {
        final routePath = Path()..moveTo(points.first.dx, points.first.dy);
        for (final pt in points.skip(1)) {
          routePath.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(routePath, routePaint);
      }
      if (points.isNotEmpty) {
        final startPaint = Paint()..color = Colors.green..style = PaintingStyle.fill;
        final endPaint = Paint()..color = Colors.red..style = PaintingStyle.fill;
        canvas.drawCircle(points.first, 9, startPaint);
        canvas.drawCircle(points.last, 9, endPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

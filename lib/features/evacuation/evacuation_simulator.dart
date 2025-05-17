import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/map/map_model.dart';
import 'package:navigation_diploma_client/features/notes/poi_manager.dart';
import 'package:navigation_diploma_client/features/routing/pathfinder.dart';
import 'package:navigation_diploma_client/features/networking/route_model.dart';

class EvacuationSimulator extends StatefulWidget {
  final MapModel mapModel;
  final int startRoomNodeId; // id текущей комнаты (GraphNode id)

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

  @override
  void initState() {
    super.initState();
    _calculateEvacuationRoute();
  }

  void _calculateEvacuationRoute() {
    final graph = widget.mapModel.toNavigationGraph();
    final exits = POIManager().pois.where((poi) => poi.type == POIType.exit).toList();

    if (exits.isEmpty) {
      setState(() {
        routeToExit = null;
        nearestExit = null;
      });
      return;
    }

    // Ищем ближайший выход (по кратчайшему маршруту)
    double? minLen;
    RouteModel? bestRoute;
    POI? bestExit;

    for (final exit in exits) {
      // Находим ближайший node (узел) к POI выхода
      final node = graph.nodes.values.reduce((a, b) =>
          ((a.x - exit.x).abs() + (a.y - exit.y).abs()).compareTo(
              (b.x - exit.x).abs() + (b.y - exit.y).abs()) < 0
              ? a
              : b);

      final route = findShortestRoute(graph, widget.startRoomNodeId, node.id);
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
                        "Число точек: ${routeToExit!.path.length}",
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
    // Для простоты показываем только этаж первого сегмента
    final int floor = route.path.isNotEmpty ? route.path.first.floor : mapModel.floors.first.floorNumber;
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
    // Рисуем "план" этажа как точки-комнаты
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

    // Рисуем маршрут до выхода
    if (route.path.isNotEmpty) {
      final routePaint = Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      final points = route.path
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
      // Старт и конец маршрута
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

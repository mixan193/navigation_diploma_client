import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/notes/poi_manager.dart';
import 'package:navigation_diploma_client/features/routing/pathfinder.dart';
import 'package:navigation_diploma_client/models/room.dart';
import 'package:navigation_diploma_client/models/route.dart' as model_route;

class EvacuationSimulator extends StatefulWidget {
  final List<RoomModel> rooms;
  final String startRoomId;

  const EvacuationSimulator({
    super.key,
    required this.rooms,
    required this.startRoomId,
  });

  @override
  State<EvacuationSimulator> createState() => _EvacuationSimulatorState();
}

class _EvacuationSimulatorState extends State<EvacuationSimulator> {
  model_route.RouteModel? routeToExit;
  POI? nearestExit;

  @override
  void initState() {
    super.initState();
    _calculateEvacuationRoute();
  }

  void _calculateEvacuationRoute() {
    final roomMap = {for (var r in widget.rooms) r.id: r};
    final exits =
        POIManager().pois.where((poi) => poi.type == POIType.exit).toList();
    if (exits.isEmpty) {
      setState(() {
        routeToExit = null;
        nearestExit = null;
      });
      return;
    }

    double? minLen;
    model_route.RouteModel? bestRoute;
    POI? bestExit;
    final pathfinder = Pathfinder();

    for (final exit in exits) {
      final exitRoom = widget.rooms.firstWhere(
        (r) => r.floorNumber == exit.floor,
        orElse: () => widget.rooms.first,
      );
      final route = pathfinder.findRoute(
        roomMap[widget.startRoomId]!,
        exitRoom,
        roomMap,
      );
      if (minLen == null || route.length < minLen) {
        minLen = route.length;
        bestRoute = route as model_route.RouteModel?;
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            routeToExit == null
                ? const Center(
                  child: Text("Нет доступных выходов или маршрутов"),
                )
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
                        rooms: widget.rooms,
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
  final List<RoomModel> rooms;
  final model_route.RouteModel route;

  const EvacuationRouteMap({
    super.key,
    required this.rooms,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final int floor =
        route.points.isNotEmpty
            ? route.points.first.floor
            : rooms.first.floorNumber;
    final roomsOnFloor = rooms.where((f) => f.floorNumber == floor).toList();

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(painter: _EvacuationRoutePainter(roomsOnFloor, route)),
    );
  }
}

class _EvacuationRoutePainter extends CustomPainter {
  final List<RoomModel> rooms;
  final model_route.RouteModel route;

  _EvacuationRoutePainter(this.rooms, this.route);

  @override
  void paint(Canvas canvas, Size size) {
    final paintRoom =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
    for (final room in rooms) {
      final p = Offset(
        room.x / 100 * size.width,
        (1 - room.y / 100) * size.height,
      );
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
      final routePaint =
          Paint()
            ..color = Colors.deepOrange
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke;

      final points =
          route.points
              .where((p) => p.floor == rooms.first.floorNumber)
              .map(
                (p) => Offset(
                  p.x / 100 * size.width,
                  (1 - p.y / 100) * size.height,
                ),
              )
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

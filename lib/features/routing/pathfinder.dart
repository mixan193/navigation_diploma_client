import 'dart:math';
import 'package:collection/collection.dart';
import 'package:navigation_diploma_client/models/room.dart';
import 'package:navigation_diploma_client/features/networking/route_model.dart';

class Pathfinder {
  RouteModel findRoute(
    RoomModel startRoom,
    RoomModel endRoom,
    Map<String, RoomModel> roomGraph,
  ) {
    final visited = <String>{};
    final queue = PriorityQueue<_Node>((a, b) => a.cost.compareTo(b.cost));
    queue.add(_Node(startRoom, 0, [startRoom]));

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      final room = node.room;
      if (visited.contains(room.id)) continue;
      visited.add(room.id);

      if (room.id == endRoom.id) {
        final points =
            node.path
                .map(
                  (r) =>
                      RoutePoint(x: r.x, y: r.y, z: r.z, floor: r.floorNumber),
                )
                .toList();
        double length = 0;
        for (int i = 1; i < points.length; i++) {
          length += _distance3d(points[i - 1], points[i]);
        }
        return RouteModel(
          id: 'route_${startRoom.id}_${endRoom.id}',
          points: points,
          length: length,
          floorFrom: points.isNotEmpty ? points.first.floor : 0,
          floorTo: points.isNotEmpty ? points.last.floor : 0,
        );
      }

      for (final neighborId in room.neighbors) {
        final neighbor = roomGraph[neighborId];
        if (neighbor != null && !visited.contains(neighbor.id)) {
          queue.add(
            _Node(
              neighbor,
              node.cost + _distance3dRoom(room, neighbor),
              List<RoomModel>.from(node.path)..add(neighbor),
            ),
          );
        }
      }
    }
    return RouteModel(
      id: 'empty',
      points: [],
      length: 0.0,
      floorFrom: 0,
      floorTo: 0,
    );
  }
}

class _Node {
  final RoomModel room;
  final double cost;
  final List<RoomModel> path;

  _Node(this.room, this.cost, this.path);
}

double _distance3d(RoutePoint a, RoutePoint b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  final dz = a.z - b.z;
  return sqrt(dx * dx + dy * dy + dz * dz);
}

double _distance3dRoom(RoomModel a, RoomModel b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  final dz = a.z - b.z;
  return sqrt(dx * dx + dy * dy + dz * dz);
}

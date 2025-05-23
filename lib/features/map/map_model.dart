import 'dart:math';
import 'package:navigation_diploma_client/models/room.dart';

class MapModel {
  final List<FloorModel> floors;

  MapModel({
    required this.floors,
  });

  BuildingGraph toNavigationGraph() {
    final Map<int, GraphNode> nodes = {};
    int nodeCounter = 0;
    final Map<String, int> roomIdToNodeId = {};

    // 1. Все комнаты -> узлы графа
    for (final floor in floors) {
      for (final room in floor.rooms) {
        nodeCounter++;
        nodes[nodeCounter] = GraphNode(
          id: nodeCounter,
          x: room.x,
          y: room.y,
          z: room.z,
          floor: floor.floorNumber,
          edges: [],
        );
        roomIdToNodeId["${floor.floorNumber}_${room.id}"] = nodeCounter;
      }
    }

    // 2. Рёбра на одном этаже (если расстояние < 20 м)
    for (final floor in floors) {
      for (int i = 0; i < floor.rooms.length; i++) {
        final roomA = floor.rooms[i];
        final nodeAId = roomIdToNodeId["${floor.floorNumber}_${roomA.id}"]!;
        final nodeA = nodes[nodeAId]!;
        for (int j = i + 1; j < floor.rooms.length; j++) {
          final roomB = floor.rooms[j];
          final nodeBId = roomIdToNodeId["${floor.floorNumber}_${roomB.id}"]!;
          final nodeB = nodes[nodeBId]!;
          final dx = nodeA.x - nodeB.x;
          final dy = nodeA.y - nodeB.y;
          final distance = sqrt(dx * dx + dy * dy);
          if (distance < 20) {
            nodeA.edges.add(GraphEdge(toNodeId: nodeB.id, weight: distance));
            nodeB.edges.add(GraphEdge(toNodeId: nodeA.id, weight: distance));
          }
        }
      }
    }

    // 3. Связи между этажами (с одинаковыми id комнат)
    for (final entry in roomIdToNodeId.entries) {
      final parts = entry.key.split('_');
      final floorNum = int.parse(parts[0]);
      final roomId = parts[1];
      for (final otherEntry in roomIdToNodeId.entries) {
        final otherParts = otherEntry.key.split('_');
        final otherFloor = int.parse(otherParts[0]);
        final otherRoomId = otherParts[1];
        if (roomId == otherRoomId && floorNum != otherFloor) {
          final nodeA = nodes[entry.value]!;
          final nodeB = nodes[otherEntry.value]!;
          final dz = (nodeA.z - nodeB.z).abs();
          final distance = sqrt(pow(nodeA.x - nodeB.x, 2) + pow(nodeA.y - nodeB.y, 2) + pow(dz, 2));
          nodeA.edges.add(GraphEdge(toNodeId: nodeB.id, weight: distance));
          nodeB.edges.add(GraphEdge(toNodeId: nodeA.id, weight: distance));
        }
      }
    }

    return BuildingGraph(nodes: nodes);
  }
}

class FloorModel {
  final int floorNumber;
  final String floorName;
  final List<RoomModel> rooms;

  FloorModel({
    required this.floorNumber,
    required this.floorName,
    required this.rooms,
  });
}

class GraphEdge {
  final int toNodeId;
  final double weight;

  GraphEdge({
    required this.toNodeId,
    required this.weight,
  });
}

class GraphNode {
  final int id;
  final double x;
  final double y;
  final double z;
  final int floor;
  final List<GraphEdge> edges;

  GraphNode({
    required this.id,
    required this.x,
    required this.y,
    required this.z,
    required this.floor,
    required this.edges,
  });
}

class BuildingGraph {
  final Map<int, GraphNode> nodes;
  BuildingGraph({required this.nodes});
}
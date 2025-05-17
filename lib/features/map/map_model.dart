/// map_model.dart
///
/// Определяет модели данных, описывающие карту здания: комнаты, этажи, переходы и т.д.
/// Теперь поддерживает генерацию навигационного графа для поиска маршрута.
/// import 'dart:math';

library;

import 'dart:math';

class MapModel {
  final List<FloorModel> floors;
  // Например, могут быть дополнительные поля, ссылки на POI, маршруты и т.п.

  MapModel({
    required this.floors,
  });

  /// Собирает полный навигационный граф здания для поиска маршрута.
  /// Каждый RoomModel становится узлом графа.
  BuildingGraph toNavigationGraph() {
    final Map<int, GraphNode> nodes = {};
    int nodeCounter = 0;
    final Map<String, int> roomIdToNodeId = {};

    // 1. Преобразуем все комнаты всех этажей в узлы графа
    for (final floor in floors) {
      for (final room in floor.rooms) {
        nodeCounter++;
        nodes[nodeCounter] = GraphNode(
          id: nodeCounter,
          x: room.x,
          y: room.y,
          floor: floor.floorNumber,
          edges: [],
        );
        roomIdToNodeId["${floor.floorNumber}_${room.id}"] = nodeCounter;
      }
    }

    // 2. Генерируем рёбра: простейшая логика — связываем соседние комнаты на этаже
    for (final floor in floors) {
      for (int i = 0; i < floor.rooms.length; i++) {
        final roomA = floor.rooms[i];
        final nodeAId = roomIdToNodeId["${floor.floorNumber}_${roomA.id}"]!;
        final nodeA = nodes[nodeAId]!;

        for (int j = i + 1; j < floor.rooms.length; j++) {
          final roomB = floor.rooms[j];
          final nodeBId = roomIdToNodeId["${floor.floorNumber}_${roomB.id}"]!;
          final nodeB = nodes[nodeBId]!;

          // Связываем только если комнаты достаточно близко друг к другу (например, < 20 метров)
          final dx = nodeA.x - nodeB.x;
          final dy = nodeA.y - nodeB.y;
          final distance = sqrt(dx * dx + dy * dy);

          if (distance < 20) {
            // Добавляем двунаправленное ребро
            nodeA.edges.add(GraphEdge(toNodeId: nodeB.id, weight: distance));
            nodeB.edges.add(GraphEdge(toNodeId: nodeA.id, weight: distance));
          }
        }
      }
    }

    // 3. Связываем одинаковые комнаты на разных этажах (например, лестницы/лифты)
    // Можно расширить по вашему сценарию

    return BuildingGraph(nodes: nodes);
  }
}

/// Модель этажа
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

/// Модель комнаты
class RoomModel {
  final String id;
  final String name;
  final double x; // Координаты комнаты на плане
  final double y;

  RoomModel({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
  });
}

// ===== Навигационный граф =====
class BuildingGraph {
  final Map<int, GraphNode> nodes; // key: node id
  BuildingGraph({required this.nodes});
  GraphNode? getNode(int id) => nodes[id];
}

class GraphNode {
  final int id;
  final double x;
  final double y;
  final int floor;
  final List<GraphEdge> edges;

  GraphNode({
    required this.id,
    required this.x,
    required this.y,
    required this.floor,
    required this.edges,
  });
}

class GraphEdge {
  final int toNodeId;
  final double weight; // длина, стоимость прохода

  GraphEdge({
    required this.toNodeId,
    required this.weight,
  });
}

// Для поиска маршрута используйте метод:
// final graph = yourMapModel.toNavigationGraph();

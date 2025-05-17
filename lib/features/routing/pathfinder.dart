import 'dart:collection';
import 'package:navigation_diploma_client/features/networking/map_response.dart';
import 'package:navigation_diploma_client/features/networking/route_model.dart';
import 'package:navigation_diploma_client/features/map/map_model.dart';

// Граф здания: узлы (точки) и рёбра (проходы между точками)
class BuildingGraph {
  final Map<int, GraphNode> nodes; // key: node id

  BuildingGraph({required this.nodes});

  GraphNode? getNode(int id) => nodes[id];

  // Для примера: построение графа из карты здания
  // (floorGraph — данные по комнатам/проходам на этаже, см. MapModel/FloorSchema)
  static BuildingGraph fromFloorGraph(List<FloorSchema> floors) {
    final nodes = <int, GraphNode>{};
    for (final floor in floors) {
      for (final node in floor.graphNodes) {
        nodes[node.id] = node;
      }
    }
    // Для связности между этажами — добавьте рёбра между лестницами/лифтами
    // (оставлено для расширения)
    return BuildingGraph(nodes: nodes);
  }
}

// Узел графа
class GraphNode {
  final int id;
  final double x;
  final double y;
  final int floor;
  final List<GraphEdge> edges; // Смежные рёбра

  GraphNode({
    required this.id,
    required this.x,
    required this.y,
    required this.floor,
    required this.edges,
  });
}

// Рёбра графа
class GraphEdge {
  final int toNodeId;
  final double weight; // длина, стоимость прохода

  GraphEdge({
    required this.toNodeId,
    required this.weight,
  });
}

/// Поиск кратчайшего пути (Dijkstra) между двумя точками (nodeId)
RouteModel findShortestRoute(
    BuildingGraph graph, int startId, int endId) {
  final dist = <int, double>{};
  final prev = <int, int?>{};
  final visited = <int>{};
  final queue = PriorityQueue<_NodeWithDist>(
      (a, b) => a.dist.compareTo(b.dist));

  // Инициализация
  for (final nodeId in graph.nodes.keys) {
    dist[nodeId] = double.infinity;
    prev[nodeId] = null;
  }
  dist[startId] = 0.0;
  queue.add(_NodeWithDist(startId, 0.0));

  // Основной цикл
  while (queue.isNotEmpty) {
    final current = queue.removeFirst();
    if (visited.contains(current.nodeId)) continue;
    visited.add(current.nodeId);

    if (current.nodeId == endId) break;

    final node = graph.getNode(current.nodeId)!;
    for (final edge in node.edges) {
      final alt = dist[node.id]! + edge.weight;
      if (alt < dist[edge.toNodeId]!) {
        dist[edge.toNodeId] = alt;
        prev[edge.toNodeId] = node.id;
        queue.add(_NodeWithDist(edge.toNodeId, alt));
      }
    }
  }

  // Восстановление пути
  List<RoutePoint> path = [];
  int? u = endId;
  while (u != null && prev[u] != null) {
    final node = graph.getNode(u)!;
    path.insert(0, RoutePoint(x: node.x, y: node.y, floor: node.floor));
    u = prev[u];
  }
  // Добавляем стартовую точку
  final startNode = graph.getNode(startId)!;
  path.insert(0, RoutePoint(x: startNode.x, y: startNode.y, floor: startNode.floor));

  final totalLength = dist[endId] ?? 0.0;

  return RouteModel(path: path, length: totalLength);
}

class _NodeWithDist {
  final int nodeId;
  final double dist;
  _NodeWithDist(this.nodeId, this.dist);
}

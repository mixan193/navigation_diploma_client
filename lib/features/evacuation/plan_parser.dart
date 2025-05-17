import 'dart:convert';
import 'package:navigation_diploma_client/features/notes/poi_manager.dart';

/// Парсер плана эвакуации из JSON (или другого формата)
/// Пример входного JSON:
/// [
///   { "name": "Выход №1", "x": 10.0, "y": 80.0, "floor": 1, "type": "exit", "description": "Главный выход" },
///   { "name": "Лестница 1", "x": 50.0, "y": 90.0, "floor": 1, "type": "stairs" }
/// ]
class PlanParser {
  /// Импорт POI из строки (JSON)
  static List<POI> parseFromJson(String jsonString) {
    final List<POI> pois = [];
    final data = jsonDecode(jsonString);
    for (final item in data) {
      final type = _parseType(item['type']);
      pois.add(POI(
        id: DateTime.now().millisecondsSinceEpoch.toString() + pois.length.toString(),
        name: item['name'] ?? "Без названия",
        x: (item['x'] as num).toDouble(),
        y: (item['y'] as num).toDouble(),
        floor: item['floor'] ?? 1,
        type: type,
        description: item['description'],
      ));
    }
    return pois;
  }

  /// Импортирует POI из JSON-строки и сразу добавляет их в POIManager
  static void importPOIFromJson(String jsonString) {
    final pois = parseFromJson(jsonString);
    for (final poi in pois) {
      POIManager().addPOI(poi);
    }
  }

  /// Можно добавить парсер для CSV, XML, DXF и других форматов по требованию

  static POIType _parseType(String? raw) {
    switch (raw) {
      case 'exit':
        return POIType.exit;
      case 'stairs':
        return POIType.stairs;
      case 'elevator':
        return POIType.elevator;
      case 'wc':
        return POIType.wc;
      default:
        return POIType.custom;
    }
  }
}

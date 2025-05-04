/// map_model.dart
///
/// Определяет модели данных, описывающие карту здания: комнаты, этажи, переходы и т.д.
class MapModel {
  final List<FloorModel> floors;
  // Например, могут быть дополнительные поля, ссылки на POI, маршруты и т.п.

  MapModel({
    required this.floors,
  });
}

/// Модель этажа
class FloorModel {
  final int floorNumber;
  final String floorName;
  final List<RoomModel> rooms;
  // Можно добавить план этажа в виде картинки, список точек, границ и т.д.

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
  final double x;  // Координаты комнаты на плане
  final double y;

  RoomModel({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
  });
}

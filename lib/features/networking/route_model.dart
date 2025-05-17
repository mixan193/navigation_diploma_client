import 'package:flutter/foundation.dart';

/// Одна точка маршрута, для построения пути на плане.
/// Использует 3D координаты (x, y, z), где z — высота или номер этажа.
/// Может быть расширен для POI, типа сегмента (лестница, лифт), и т.д.
@immutable
class RoutePoint {
  final double x;
  final double y;
  final double z;
  final int floor;
  final String? roomId;
  final String? type; // "stairs", "elevator", "corridor", и т.д.

  const RoutePoint({
    required this.x,
    required this.y,
    required this.z,
    required this.floor,
    this.roomId,
    this.type,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) => RoutePoint(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        z: (json['z'] as num).toDouble(),
        floor: json['floor'] as int,
        roomId: json['roomId'] as String?,
        type: json['type'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'z': z,
        'floor': floor,
        if (roomId != null) 'roomId': roomId,
        if (type != null) 'type': type,
      };
}

/// Маршрут по зданию: список точек, длина, описание, визуальные параметры.
/// Может содержать опционально "алгоритм построения", "тип маршрута" (эвакуация, обычный, пр.), "время" и т.д.
@immutable
class RouteModel {
  final String id;
  final List<RoutePoint> points;
  final double length; // В метрах
  final int? estimatedTime; // В секундах, если сервер рассчитывает
  final int floorFrom;
  final int floorTo;
  final String? startRoomId;
  final String? endRoomId;
  final String? algorithm; // Название используемого алгоритма ("dijkstra", "a*", "evacuation", ...)
  final String? type; // "standard", "evacuation", "maintenance", ...

  const RouteModel({
    required this.id,
    required this.points,
    required this.length,
    required this.floorFrom,
    required this.floorTo,
    this.estimatedTime,
    this.startRoomId,
    this.endRoomId,
    this.algorithm,
    this.type,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'] as String,
        points: (json['points'] as List)
            .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        length: (json['length'] as num).toDouble(),
        floorFrom: json['floorFrom'] as int,
        floorTo: json['floorTo'] as int,
        estimatedTime: json['estimatedTime'] as int?,
        startRoomId: json['startRoomId'] as String?,
        endRoomId: json['endRoomId'] as String?,
        algorithm: json['algorithm'] as String?,
        type: json['type'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'points': points.map((e) => e.toJson()).toList(),
        'length': length,
        'floorFrom': floorFrom,
        'floorTo': floorTo,
        if (estimatedTime != null) 'estimatedTime': estimatedTime,
        if (startRoomId != null) 'startRoomId': startRoomId,
        if (endRoomId != null) 'endRoomId': endRoomId,
        if (algorithm != null) 'algorithm': algorithm,
        if (type != null) 'type': type,
      };
}

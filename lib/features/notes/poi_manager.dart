import 'package:flutter/material.dart';

/// Модель точки интереса (POI)
class POI {
  final String id;
  final String name;
  final double x;
  final double y;
  final int floor;
  final POIType type;
  final String? description;

  POI({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.floor,
    required this.type,
    this.description,
  });
}

/// Типы POI (можно расширять под задачи)
enum POIType { exit, elevator, stairs, wc, custom }

extension POITypeExt on POIType {
  String get label {
    switch (this) {
      case POIType.exit: return "Выход";
      case POIType.elevator: return "Лифт";
      case POIType.stairs: return "Лестница";
      case POIType.wc: return "Туалет";
      case POIType.custom: return "Другое";
    }
  }

  IconData get icon {
    switch (this) {
      case POIType.exit: return Icons.exit_to_app;
      case POIType.elevator: return Icons.elevator;
      case POIType.stairs: return Icons.stairs;
      case POIType.wc: return Icons.wc;
      case POIType.custom: return Icons.star;
    }
  }
}

/// Менеджер для хранения и работы с POI
class POIManager extends ChangeNotifier {
  static final POIManager _instance = POIManager._internal();
  factory POIManager() => _instance;
  POIManager._internal();

  final List<POI> _pois = [];

  List<POI> get pois => List.unmodifiable(_pois);

  void addPOI(POI poi) {
    _pois.add(poi);
    notifyListeners();
  }

  void removePOI(String id) {
    _pois.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void clear() {
    _pois.clear();
    notifyListeners();
  }

  List<POI> poisOnFloor(int floor) => _pois.where((p) => p.floor == floor).toList();

  POI? findById(String id) {
    try {
      return _pois.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

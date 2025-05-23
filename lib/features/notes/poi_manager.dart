import 'package:flutter/material.dart';

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

enum POIType { exit, elevator, stairs, wc, custom }

extension POITypeIcon on POIType {
  IconData get icon {
    switch (this) {
      case POIType.exit:
        return Icons.exit_to_app;
      case POIType.elevator:
        return Icons.elevator;
      case POIType.stairs:
        return Icons.stairs;
      case POIType.wc:
        return Icons.wc;
      default:
        return Icons.place;
    }
  }
}

class POIManager extends ChangeNotifier {
  final List<POI> _pois = [];

  List<POI> get pois => List.unmodifiable(_pois);

  void addPOI(POI poi) {
    _pois.add(poi);
    notifyListeners();
  }

  void removePOI(String id) {
    _pois.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clearPOIs() {
    _pois.clear();
    notifyListeners();
  }
}

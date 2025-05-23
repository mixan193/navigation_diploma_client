import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/map/map_repository.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';

class MapController with ChangeNotifier {
  final MapRepository _repo;
  MapResponse? _mapData;
  bool _loading = false;

  MapController(this._repo);

  MapResponse? get mapData => _mapData;
  bool get loading => _loading;

  Future<void> loadMap(int buildingId) async {
    _loading = true;
    notifyListeners();
    try {
      _mapData = await _repo.fetchMap(buildingId);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
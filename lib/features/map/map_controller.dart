import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/map/map_repository.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';

class MapController with ChangeNotifier {
  final MapRepository _repo;
  MapResponse? _map;
  bool _loading = false;

  MapController(this._repo);

  Future<void> loadMap(int buildingId) async {
    _loading = true; notifyListeners();
    try {
      _map = await _repo.fetchMap(buildingId);
    } catch (e) {
      // обработка ошибок
    } finally {
      _loading = false; notifyListeners();
    }
  }

  MapResponse? get map => _map;
  bool get isLoading => _loading;
}

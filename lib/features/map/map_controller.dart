import 'package:flutter/foundation.dart';
import 'package:navigation_diploma_client/features/map/map_model.dart';
import 'package:navigation_diploma_client/features/map/map_repository.dart';

/// map_controller.dart
///
/// Управляет состоянием карты: загрузка данных, переключение этажей, масштабирование.
class MapController extends ChangeNotifier {
  final MapRepository _repository;

  MapController(this._repository);

  MapModel? _mapModel;
  int _currentFloorIndex = 0;

  // Параметры отображения карты
  double _scale = 1.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;

  MapModel? get mapModel => _mapModel;
  FloorModel? get currentFloor => _mapModel?.floors[_currentFloorIndex];
  double get currentScale => _scale;
  double get offsetX => _offsetX;
  double get offsetY => _offsetY;

  Future<void> loadMapData() async {
    _mapModel = await _repository.fetchMapData();
    _currentFloorIndex = 0; // всегда начинаем с 1-го этажа
    notifyListeners();
  }

  void switchFloor(int floorIndex) {
    if (_mapModel == null) return;
    if (floorIndex >= 0 && floorIndex < _mapModel!.floors.length) {
      _currentFloorIndex = floorIndex;
      notifyListeners();
    }
  }

  void setScale(double newScale) {
    _scale = newScale;
    notifyListeners();
  }

  void setOffset(double dx, double dy) {
    _offsetX = dx;
    _offsetY = dy;
    notifyListeners();
  }

  /// Пример функции для "центрирования" на комнате
  void centerOnRoom(RoomModel room) {
    // Допустим, мы хотим сместить offset так, чтобы комната оказалась в центре экрана
    // Логику расчёта оставим на ваше усмотрение.
    _offsetX = room.x;
    _offsetY = room.y;
    notifyListeners();
  }
}

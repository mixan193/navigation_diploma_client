import 'package:navigation_diploma_client/features/map/map_model.dart';
// Допустим, у нас есть локальный DAO или сетевые запросы
import 'package:navigation_diploma_client/features/storage/map_dao.dart';

/// map_repository.dart
///
/// Содержит логику загрузки/кэширования данных карты из сети или локального хранилища.
class MapRepository {
  final MapDao _mapDao;

  MapRepository(this._mapDao);

  /// Получение данных карты (список этажей, комнат и т.д.)
  Future<MapModel> fetchMapData() async {
    // Можно сначала проверить наличие данных в локальной БД:
    final localData = await _mapDao.getCachedMap();
    if (localData != null) {
      // Если уже есть актуальные данные, можно вернуть сразу
      return localData;
    }

    // Если нет — грузим с сервера (примерно), потом сохраняем в БД:
    final fetchedData = await _fetchFromServer();
    await _mapDao.saveMapData(fetchedData);
    return fetchedData;
  }

  /// Пример запроса на сервер (заглушка).
  /// Здесь можно вызывать ваш ApiClient.
  Future<MapModel> _fetchFromServer() async {
    // Логика запроса к API (например, http.get, dio и т.д.)
    // Для примера создадим фейковые данные.
    await Future.delayed(const Duration(seconds: 1)); // эмуляция сети

    return MapModel(floors: [
      FloorModel(
        floorNumber: 1,
        floorName: 'First Floor',
        rooms: [
          RoomModel(id: 'R101', name: 'Room 101', x: 100, y: 200),
          RoomModel(id: 'R102', name: 'Room 102', x: 300, y: 250),
        ],
      ),
      FloorModel(
        floorNumber: 2,
        floorName: 'Second Floor',
        rooms: [
          RoomModel(id: 'R201', name: 'Room 201', x: 150, y: 300),
        ],
      ),
    ]);
  }
}

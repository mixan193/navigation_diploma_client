import 'package:navigation_diploma_client/features/networking/map_response.dart';
// Допустим, у нас есть локальный DAO или сетевые запросы

import '../../features/networking/api_client.dart';

/// map_repository.dart
///
/// Содержит логику загрузки/кэширования данных карты из сети или локального хранилища.
class MapRepository {
  final ApiClient _api;

  MapRepository(this._api);

  Future<MapResponse> fetchMap(int buildingId) =>
      _api.getBuildingMap(buildingId);
}

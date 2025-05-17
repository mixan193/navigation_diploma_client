import 'package:get_it/get_it.dart';
import '../networking/api_client.dart';
import '../networking/map_response.dart';

class MapDao {
  final ApiClient _api = GetIt.instance<ApiClient>();

  /// Запрос карты здания по ID
  Future<MapResponse> fetchMap(int buildingId) {
    return _api.getBuildingMap(buildingId);
  }
}
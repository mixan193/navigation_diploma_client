import 'package:get_it/get_it.dart';
import 'package:navigation_diploma_client/features/networking/api_client.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';

class MapDao {
  final ApiClient _api = GetIt.instance<ApiClient>();

  Future<MapResponse> fetchMap(int buildingId) {
    return _api.getBuildingMap(buildingId);
  }
}
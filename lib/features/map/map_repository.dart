import 'package:navigation_diploma_client/di/service_locator.dart';
import 'package:navigation_diploma_client/features/networking/api_client.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';

class MapRepository {
  final ApiClient _api = locator<ApiClient>();

  Future<MapResponse> fetchMap(int buildingId) {
    return _api.getBuildingMap(buildingId);
  }
}
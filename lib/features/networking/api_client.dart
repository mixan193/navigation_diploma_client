import 'package:dio/dio.dart';
import 'package:navigation_diploma_client/features/networking/ap_out.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';
import 'package:navigation_diploma_client/features/networking/scan_upload.dart';
import '../../config/env.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

  Future<String> login(String username, String password) async {
    final resp = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return resp.data['access_token'] as String;
  }

  Future<MapResponse> getBuildingMap(int buildingId) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/v1/building-map',
      queryParameters: {'id': buildingId},
    );
    if (resp.data == null) {
      throw Exception('No data');
    }
    return MapResponse.fromJson(resp.data!);
  }

  Future<AccessPointOut> addAccessPoint({
    required int buildingId,
    required int floor,
    required double x,
    required double y,
    double? z,
    required String bssid,
    required int frequency,
    int? id,
  }) async {
    final resp = await _dio.post(
      '/v1/access-point',
      data: {
        'buildingId': buildingId,
        'floor': floor,
        'x': x,
        'y': y,
        if (z != null) 'z': z,
        'bssid': bssid,
        'frequency': frequency,
        if (id != null) 'id': id,
      },
    );
    return AccessPointOut.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> uploadScan(ScanUpload scan) async {
    await _dio.post('/v1/upload', data: scan.toJson());
  }
}
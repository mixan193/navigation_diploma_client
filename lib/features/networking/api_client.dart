import 'package:dio/dio.dart';
import 'package:navigation_diploma_client/features/networking/ap_out.dart';
import 'package:navigation_diploma_client/features/networking/map_response.dart';
import 'package:navigation_diploma_client/features/networking/scan_upload.dart';
import '../../config/env.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: Env.apiBaseUrl));

  /// (Опционально) если сервер требует JWT:
  Future<String> login(String username, String password) async {
    final resp = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return resp.data['access_token'] as String;
  }

  /// POST /v1/upload
  /// Отправляет скан, возвращает серверный ответ как Map (status и coordinates)
  Future<Map<String, dynamic>> uploadScan(
    ScanUpload scan, {
    String? token,
  }) async {
    final opts = Options(
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    final resp = await _dio.post(
      '/v1/upload',
      data: scan.toJson(),
      options: opts,
    );
    return resp.data;
  }

  /// Новый: отправить скан и сразу получить координаты пользователя (x, y, z, floor)
  /// Для простоты результат - Map<String, dynamic> с координатами или null, если ошибка
  Future<Map<String, dynamic>?> uploadScanAndGetPosition(
    ScanUpload scan, {
    String? token,
  }) async {
    try {
      final result = await uploadScan(scan, token: token);
      if (result['status'] == 'success' && result['coordinates'] != null) {
        // Например: {'x':..., 'y':..., 'z':..., 'floor':..., ...}
        return Map<String, dynamic>.from(result['coordinates'] as Map);
      }
      return null;
    } on DioError catch (e) {
      // Можно логировать и детально разбирать ошибку сервера для защиты
      throw Exception(
        'Ошибка отправки скана: ${e.response?.data ?? e.message}',
      );
    }
  }

  /// GET /v1/map/<building_id> (получить карту этажа здания)
  Future<MapResponse> getBuildingMap(int buildingId) async {
    final resp = await _dio.get('/v1/map/$buildingId');
    return MapResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  // Получение всех AP по buildingId
  Future<List<AccessPointOut>> getAccessPoints(int buildingId) async {
    final resp = await _dio.get('/v1/ap?building_id=$buildingId');
    final aps =
        (resp.data as List)
            .map((item) => AccessPointOut.fromJson(item))
            .toList();
    return aps;
  }

  // Обновление координат AP
  Future<void> updateAccessPoint(
    String bssid, {
    required double x,
    required double y,
    required double z,
  }) async {
    await _dio.put('/v1/ap/$bssid', data: {'x': x, 'y': y, 'z': z});
  }
}

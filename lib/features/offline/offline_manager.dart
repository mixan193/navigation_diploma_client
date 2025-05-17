import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:navigation_diploma_client/features/networking/scan_upload.dart';
import 'package:navigation_diploma_client/features/networking/api_client.dart';

typedef PositionUpdateCallback = void Function(Map<String, dynamic>? userPosition);

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal();

  // Простой in-memory кэш (замените на локальную БД при необходимости)
  final List<ScanUpload> _offlineScans = [];

  // Проверка доступности интернета (можно расширить до ping сервера)
  Future<bool> get hasInternet async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Основной метод: отправляет скан или кэширует его при отсутствии сети
  Future<void> sendOrCacheScan(
    ScanUpload scan, {
    String? token,
    PositionUpdateCallback? onPositionUpdate,
  }) async {
    if (await hasInternet) {
      try {
        final api = ApiClient();
        final userCoords = await api.uploadScanAndGetPosition(scan, token: token);
        onPositionUpdate?.call(userCoords);
        // После успешной отправки — синхронизируем всё, что было в оффлайн-кэше
        await _syncOfflineScans(token, onPositionUpdate);
      } catch (e) {
        // Если сервер недоступен, кэшируем
        _offlineScans.add(scan);
      }
    } else {
      _offlineScans.add(scan);
    }
  }

  /// Попытаться отправить все кэшированные сканы при появлении сети
  Future<void> _syncOfflineScans(
    String? token,
    PositionUpdateCallback? onPositionUpdate,
  ) async {
    if (_offlineScans.isEmpty) return;
    final api = ApiClient();
    final List<ScanUpload> successfullySent = [];
    for (final scan in _offlineScans) {
      try {
        final userCoords = await api.uploadScanAndGetPosition(scan, token: token);
        onPositionUpdate?.call(userCoords);
        successfullySent.add(scan);
      } catch (_) {
        // Оставляем в кэше
        break;
      }
    }
    _offlineScans.removeWhere((scan) => successfullySent.contains(scan));
  }

  /// Ручной запуск синхронизации (например, по кнопке или при смене статуса сети)
  Future<void> sync({String? token, PositionUpdateCallback? onPositionUpdate}) async {
    if (await hasInternet) {
      await _syncOfflineScans(token, onPositionUpdate);
    }
  }

  /// Для теста/диагностики: получить кол-во неотправленных сканов
  int get pendingCount => _offlineScans.length;
}

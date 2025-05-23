import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:navigation_diploma_client/features/networking/scan_upload.dart';
import 'package:navigation_diploma_client/features/networking/api_client.dart';
import 'package:navigation_diploma_client/features/networking/connectivity_checker.dart';

typedef PositionUpdateCallback =
    void Function(Map<String, dynamic>? userPosition);

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      // result всегда List<ConnectivityResult>
      if (result.isNotEmpty && result.first != ConnectivityResult.none) {
        _uploadPendingScans();
      }
    });
  }

  final List<ScanUpload> _queue = [];
  late dynamic _connectivitySubscription;

  void addScan(ScanUpload scan) {
    _queue.add(scan);
  }

  Future<void> _uploadPendingScans() async {
    while (_queue.isNotEmpty) {
      final scan = _queue.removeAt(0);
      try {
        await ApiClient().uploadScan(scan);
      } catch (_) {
        _queue.insert(0, scan);
        break;
      }
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }

  // Позволяет вручную инициировать загрузку сканов (например, из SyncWatcher)
  Future<void> uploadPendingScans() async {
    await _uploadPendingScans();
  }

  // Проверка наличия интернета
  Future<bool> get hasInternet async {
    return await ConnectivityChecker().check();
  }

  // Количество ожидающих отправки сканов
  int get pendingCount => _queue.length;

  // Явная синхронизация очереди
  Future<void> sync() async {
    await _uploadPendingScans();
  }
}

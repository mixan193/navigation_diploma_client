import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:navigation_diploma_client/features/offline/offline_manager.dart';

class SyncWatcher {
  static final SyncWatcher _instance = SyncWatcher._internal();
  factory SyncWatcher() => _instance;
  SyncWatcher._internal();

  StreamSubscription<ConnectivityResult>? _sub;

  /// Запуск автонаблюдателя (вызывайте в main.dart или при старте приложения)
  void start() {
    _sub?.cancel();
    _sub = Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        // Есть сеть — пробуем синхронизировать сканы
        await OfflineManager().sync();
      }
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}

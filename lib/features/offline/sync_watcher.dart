import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:navigation_diploma_client/features/offline/offline_manager.dart';

class SyncWatcher {
  static final SyncWatcher _instance = SyncWatcher._internal();
  factory SyncWatcher() => _instance;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  SyncWatcher._internal() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        OfflineManager().uploadPendingScans();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityChecker {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  ConnectivityChecker() {
    // Слушаем изменения
    _connectivity.onConnectivityChanged.listen((result) {
      // result всегда List<ConnectivityResult>
      _controller.add(
        result.isNotEmpty && result.first != ConnectivityResult.none,
      );
    });
  }

  /// Текущий стрим статуса (true = есть интернет)
  Stream<bool> get statusStream => _controller.stream;

  /// Разовый чек
  Future<bool> check() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _controller.close();
  }
}

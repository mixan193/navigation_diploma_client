import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class GyroscopeService {
  final _controller = StreamController<GyroscopeEvent>.broadcast();

  void start() {
    gyroscopeEventStream().listen(_controller.add);
  }

  Stream<GyroscopeEvent> get stream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
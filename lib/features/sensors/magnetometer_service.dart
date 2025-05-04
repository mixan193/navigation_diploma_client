import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class MagnetometerService {
  final _controller = StreamController<MagnetometerEvent>.broadcast();

  void start() {
    magnetometerEventStream().listen(_controller.add);
  }

  Stream<MagnetometerEvent> get stream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
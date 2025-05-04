import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerService {
  final _controller = StreamController<AccelerometerEvent>.broadcast();

  void start() {
    accelerometerEventStream().listen(_controller.add);
  }

  Stream<AccelerometerEvent> get stream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
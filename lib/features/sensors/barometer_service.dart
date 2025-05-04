import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class BarometerService {
  final _controller = StreamController<BarometerEvent>.broadcast();
  BarometerEvent? latestPressure;

  void start() {
    barometerEventStream().listen(
      (event) {
        latestPressure = event;
        _controller.add(event);
      },
      cancelOnError: true,
    );
  }

  Stream<BarometerEvent> get stream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}

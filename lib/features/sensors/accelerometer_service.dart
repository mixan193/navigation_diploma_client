import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerService {
  Stream<AccelerometerEvent> get accelerometerStream => accelerometerEventStream();
}

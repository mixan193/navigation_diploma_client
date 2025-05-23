import 'package:sensors_plus/sensors_plus.dart';

class MagnetometerService {
  Stream<MagnetometerEvent> get magnetometerStream => magnetometerEventStream();
}

import 'package:sensors_plus/sensors_plus.dart';

class GyroscopeService {
  Stream<GyroscopeEvent> get gyroscopeStream => gyroscopeEventStream();
}

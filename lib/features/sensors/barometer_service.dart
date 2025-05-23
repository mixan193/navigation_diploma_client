import 'package:sensors_plus/sensors_plus.dart';

class BarometerService {
  Stream<double> get pressureStream =>
      barometerEventStream().map((e) => e.pressure);
}

import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';

import 'accelerometer_service.dart';
import 'gyroscope_service.dart';
import 'magnetometer_service.dart';
import 'barometer_service.dart';
import 'gps_service.dart';
import 'wifi_service.dart';

class SensorManager {
  static final SensorManager _instance = SensorManager._internal();
  factory SensorManager() => _instance;
  SensorManager._internal();

  final _accelerometerService = AccelerometerService();
  final _gyroscopeService = GyroscopeService();
  final _magnetometerService = MagnetometerService();
  final _barometerService = BarometerService();
  final _gpsService = GpsService();
  final _wifiService = WifiService();

  double? _referencePressure;
  double? _referenceAltitude;
  Timer? _referenceUpdateTimer;

  Future<void> initialize() async {
    _accelerometerService.start();
    _gyroscopeService.start();
    _magnetometerService.start();
    _barometerService.start();
    await _gpsService.start();

    // обновление эталонных значений
    _referenceUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) => _updateReferenceFromGPS());
    await _updateReferenceFromGPS();
  }

  Future<void> _updateReferenceFromGPS() async {
    try {
      final position = _gpsService.latestPosition;
      if (position != null) {
        _referenceAltitude = position.altitude;
        _referencePressure = _barometerService.latestPressure?.pressure;
      }
    } catch (_) {
      // можно логировать
    }
  }

  double calculateRelativeAltitude(double pressure) {
    if (_referencePressure == null || _referenceAltitude == null) return 0;
    return _referenceAltitude! +
        44330 * (1 - pow(pressure / _referencePressure!, 1 / 5.255));
  }

  // Потоки данных
  Stream<AccelerometerEvent> get accelerometerStream => _accelerometerService.stream;
  Stream<GyroscopeEvent> get gyroscopeStream => _gyroscopeService.stream;
  Stream<MagnetometerEvent> get magnetometerStream => _magnetometerService.stream;
  Stream<double> get pressureStream => _barometerService.stream.map((event) => event.pressure);
  Stream<Position> get gpsStream => _gpsService.stream;

  // Последние значения
  Position? get lastKnownGPS => _gpsService.latestPosition;
  double? get lastKnownPressure => _barometerService.latestPressure?.pressure;

  // Wi-Fi сканирование
  Future<List<WiFiAccessPoint>> scanWifi() => _wifiService.scan();

  void dispose() {
    _referenceUpdateTimer?.cancel();
    _gpsService.dispose();
    _barometerService.dispose();
    _accelerometerService.dispose();
    _gyroscopeService.dispose();
    _magnetometerService.dispose();
  }
}

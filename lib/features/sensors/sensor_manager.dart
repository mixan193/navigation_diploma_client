import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'accelerometer_service.dart';
import 'barometer_service.dart';
import 'gyroscope_service.dart';
import 'magnetometer_service.dart';

class SensorManager {
  static final SensorManager _instance = SensorManager._internal();
  factory SensorManager() => _instance;
  SensorManager._internal();

  final AccelerometerService _accelService = AccelerometerService();
  final MagnetometerService _magnetService = MagnetometerService();
  final BarometerService _baroService = BarometerService();
  final GyroscopeService _gyroService = GyroscopeService();

  Stream<AccelerometerEvent> get accelerometerStream =>
      _accelService.accelerometerStream;
  Stream<MagnetometerEvent> get magnetometerStream =>
      _magnetService.magnetometerStream;
  Stream<double> get pressureStream => _baroService.pressureStream;
  Stream<GyroscopeEvent> get gyroscopeStream => _gyroService.gyroscopeStream;

  double? _lastKnownPressure;
  double? get lastKnownPressure => _lastKnownPressure;
  void updatePressure(double pressure) {
    _lastKnownPressure = pressure;
  }

  double? calculateRelativeAltitude(double seaLevelPressure) {
    // Если нет последнего давления — вернуть null
    if (_lastKnownPressure == null) return null;
    // Барометрическая формула (ISA):
    // altitude = 44330 * (1 - (P / P0)^(1/5.255))
    final p = _lastKnownPressure!;
    final p0 = seaLevelPressure;
    return 44330.0 * (1.0 - pow(p / p0, 1 / 5.255));
  }

  Stream<Position> get gpsStream => Geolocator.getPositionStream();

  Position? lastKnownGPS;

  double? _referencePressure; // Эталонное давление (P0)
  double? _referenceAltitude; // Эталонная высота (по GPS или Wi-Fi)
  DateTime? _referenceTime;

  double? get referencePressure => _referencePressure;
  double? get referenceAltitude => _referenceAltitude;

  /// Обновить эталон по GPS (или Wi-Fi)
  void updateReferenceByGPS({
    required double pressure,
    required double altitude,
  }) {
    _referencePressure = pressure;
    _referenceAltitude = altitude;
    _referenceTime = DateTime.now();
  }

  /// Обновить эталон только по высоте (например, если Wi-Fi дал высоту, но нет давления)
  void updateReferenceByWifi({required double altitude}) {
    if (_lastKnownPressure != null) {
      _referencePressure = _lastKnownPressure;
      _referenceAltitude = altitude;
      _referenceTime = DateTime.now();
    }
  }

  /// Гибридная высота: приоритет Wi-Fi > GPS > барометр
  double? getHybridAltitude() {
    // 1. Если есть эталонная высота (Wi-Fi или GPS) и прошло <10 мин, вернуть её
    if (_referenceAltitude != null &&
        _referenceTime != null &&
        DateTime.now().difference(_referenceTime!).inMinutes < 10) {
      return _referenceAltitude;
    }
    // 2. Если есть барометр и эталонное давление, рассчитать относительную высоту
    if (_lastKnownPressure != null &&
        _referencePressure != null &&
        _referenceAltitude != null) {
      final rel =
          44330.0 *
          (1.0 - pow(_lastKnownPressure! / _referencePressure!, 1 / 5.255));
      return _referenceAltitude! + rel;
    }
    // 3. Если ничего нет — null
    return null;
  }

  Future<void> initialize() async {
    await Geolocator.requestPermission();
    lastKnownGPS = await Geolocator.getCurrentPosition();
    // При инициализации обновить эталон по GPS, если есть давление
    if (lastKnownGPS != null && _lastKnownPressure != null) {
      updateReferenceByGPS(
        pressure: _lastKnownPressure!,
        altitude: lastKnownGPS!.altitude,
      );
    }
  }

  Future<List<WiFiAccessPoint>> scanWifi() async {
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) return [];
    await WiFiScan.instance.startScan();
    return await WiFiScan.instance.getScannedResults();
  }

  /// Собрать скан Wi-Fi и GPS, отправить на сервер и вернуть позицию пользователя (если сервер вернул)
  Future<void> collectAndSendScan({
    required int buildingId,
    required int floor,
    void Function(Map<String, dynamic>? userPosition)? onPositionUpdate,
  }) async {
    // Скан Wi-Fi
    final wifiResults = await scanWifi();
    // Получить GPS
    Position? gps;
    try {
      gps = await Geolocator.getCurrentPosition();
    } catch (_) {
      gps = null;
    }
    // Собрать данные для отправки
    final scan = {
      'buildingId': buildingId,
      'floor': floor,
      'wifi':
          wifiResults
              .map(
                (ap) => {
                  'ssid': ap.ssid,
                  'bssid': ap.bssid,
                  'rssi': ap.level,
                  'frequency': ap.frequency,
                },
              )
              .toList(),
      if (gps != null) ...{
        'lat': gps.latitude,
        'lon': gps.longitude,
        'accuracy': gps.accuracy,
      },
    };
    // Отправить на сервер
    try {
      final response = await Dio().post(
        'http://185.66.71.243:8000/v1/upload',
        data: scan,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.data is Map && onPositionUpdate != null) {
        final data = response.data as Map<String, dynamic>;
        // Если сервер вернул высоту (например, по Wi-Fi), обновить эталон
        if (data['altitude'] != null && data['altitude'] is num) {
          updateReferenceByWifi(altitude: (data['altitude'] as num).toDouble());
        }
        onPositionUpdate(data);
      }
    } catch (e) {
      if (onPositionUpdate != null) onPositionUpdate(null);
      rethrow;
    }
  }
}

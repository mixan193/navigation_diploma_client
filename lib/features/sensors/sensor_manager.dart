import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:navigation_diploma_client/features/networking/wifi_observation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';

import 'accelerometer_service.dart';
import 'gyroscope_service.dart';
import 'magnetometer_service.dart';
import 'barometer_service.dart';
import 'gps_service.dart';
import 'wifi_service.dart';

// Подключаем upload-модель и апиклиент
import 'package:navigation_diploma_client/features/networking/scan_upload.dart';
import 'package:navigation_diploma_client/features/networking/api_client.dart';

// Callback для передачи новых координат после отправки скана
typedef PositionUpdateCallback = void Function(Map<String, dynamic>? userPosition);

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

  /// --- Новый функционал: сбор всех сенсоров и отправка на сервер ---
  Future<void> collectAndSendScan({
    required int buildingId,
    required int floor,
    double? manualX,
    double? manualY,
    double? manualZ,
    PositionUpdateCallback? onPositionUpdate,
    String? token,
  }) async {
    // 1. Получаем актуальные данные
    final gps = lastKnownGPS;
    final pressure = lastKnownPressure;
    final wifiList = await scanWifi();

    // 2. Собираем список Wi-Fi наблюдений
    final observations = wifiList.map((ap) => WiFiObservation(
      ssid: ap.ssid ?? "",
      bssid: ap.bssid,
      rssi: ap.level,
      frequency: ap.frequency,
    )).toList();

    // 3. Формируем ScanUpload
    final scan = ScanUpload(
      buildingId: buildingId,
      floor: floor,
      x: manualX, // Если пользователь вручную указывает x/y/z — можно подставить
      y: manualY,
      z: manualZ ?? (pressure != null ? calculateRelativeAltitude(pressure) : null),
      yaw: null, // Если есть источник азимута/компаса — подставьте
      pitch: null,
      roll: null,
      lat: gps?.latitude,
      lon: gps?.longitude,
      accuracy: gps?.accuracy,
      observations: observations,
    );

    // 4. Отправляем скан на сервер
    final api = ApiClient();
    final userCoords = await api.uploadScanAndGetPosition(scan, token: token);

    // 5. Обновляем позицию пользователя в UI через callback
    if (onPositionUpdate != null) {
      onPositionUpdate(userCoords);
    }
  }
}

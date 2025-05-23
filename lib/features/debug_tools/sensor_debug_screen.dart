import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:wifi_scan/wifi_scan.dart';

class SensorDebugScreen extends StatefulWidget {
  const SensorDebugScreen({super.key});

  @override
  State<SensorDebugScreen> createState() => _SensorDebugScreenState();
}

class _SensorDebugScreenState extends State<SensorDebugScreen> {
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  double? _barometricPressure;
  double? _relativeAltitude;
  Position? _gps;
  List<WiFiAccessPoint>? _wifiAccessPoints = [];

  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;
  StreamSubscription? _magnetSub;
  StreamSubscription? _baroSub;
  StreamSubscription? _gpsSub;

  double? _hybridAltitude;
  double? _hybridAccuracy;

  void _updateHybridAltitude() {
    final manager = SensorManager();
    final alt = manager.getHybridAltitude();
    setState(() {
      _hybridAltitude = alt;
      // Для примера: точность берём из GPS, если есть, иначе null
      _hybridAccuracy = _gps?.accuracy;
    });
  }

  @override
  void initState() {
    super.initState();
    final manager = SensorManager();
    _accelSub = manager.accelerometerStream.listen((event) {
      setState(() => _accelerometerValues = [event.x, event.y, event.z]);
    });
    _gyroSub = manager.gyroscopeStream.listen((event) {
      setState(() => _gyroscopeValues = [event.x, event.y, event.z]);
    });
    _magnetSub = manager.magnetometerStream.listen((event) {
      setState(() => _magnetometerValues = [event.x, event.y, event.z]);
    });
    _baroSub = manager.pressureStream.listen((pressure) {
      setState(() {
        _barometricPressure = pressure;
        _relativeAltitude = manager.calculateRelativeAltitude(pressure);
      });
    });
    _gpsSub = manager.gpsStream.listen((pos) {
      setState(() => _gps = pos);
      _updateHybridAltitude();
    });

    manager.scanWifi().then((result) {
      setState(() => _wifiAccessPoints = result);
      _updateHybridAltitude();
    });
    // Первичная инициализация гибридной высоты
    _updateHybridAltitude();
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _magnetSub?.cancel();
    _baroSub?.cancel();
    _gpsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Debug Screen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSensorCard('Accelerometer', _accelerometerValues),
            _buildSensorCard('Gyroscope', _gyroscopeValues),
            _buildSensorCard('Magnetometer', _magnetometerValues),
            _buildPressureCard(),
            _buildGPSCard(),
            _buildHybridAltitudeCard(),
            _buildWifiList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final manager = SensorManager();
          manager.scanWifi().then((result) {
            setState(() {
              _wifiAccessPoints = result;
              _gps = manager.lastKnownGPS;
              _updateHybridAltitude();
            });
          });
        },
        tooltip: "Обновить Wi-Fi и GPS",
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSensorCard(String title, List<double>? values) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          values != null
              ? values.map((e) => e.toStringAsFixed(2)).join(', ')
              : 'Нет данных...',
        ),
      ),
    );
  }

  Widget _buildPressureCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: const Text('Barometer'),
        subtitle: Text(
          _barometricPressure != null
              ? 'Давление: ${_barometricPressure!.toStringAsFixed(2)} hPa\nВысота: ${_relativeAltitude?.toStringAsFixed(2) ?? "-"} м'
              : 'Нет данных...',
        ),
      ),
    );
  }

  Widget _buildGPSCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: const Text('GPS'),
        subtitle:
            _gps != null
                ? Text(
                  "lat: ${_gps!.latitude.toStringAsFixed(7)}, lon: ${_gps!.longitude.toStringAsFixed(7)}\n"
                  "alt: ${_gps!.altitude.toStringAsFixed(2)} м, точность: ±${_gps!.accuracy.toStringAsFixed(1)} м",
                )
                : const Text('Нет данных...'),
      ),
    );
  }

  Widget _buildHybridAltitudeCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: const Text('Гибридная высота'),
        subtitle: Text(
          _hybridAltitude != null
              ? 'Высота: ${_hybridAltitude!.toStringAsFixed(2)} м' +
                  (_hybridAccuracy != null
                      ? ' (±${_hybridAccuracy!.toStringAsFixed(1)} м)'
                      : '')
              : 'Нет данных...',
        ),
      ),
    );
  }

  Widget _buildWifiList() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: const Text('Wi-Fi Networks (RSSI)'),
        children:
            _wifiAccessPoints != null && _wifiAccessPoints!.isNotEmpty
                ? _wifiAccessPoints!
                    .map(
                      (ap) => ListTile(
                        title: Text(ap.ssid.isNotEmpty ? ap.ssid : ap.bssid),
                        subtitle: Text("RSSI: ${ap.level} dBm"),
                      ),
                    )
                    .toList()
                : [const ListTile(title: Text('Сканирование Wi-Fi...'))],
      ),
    );
  }
}

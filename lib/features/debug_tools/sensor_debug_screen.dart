import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

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

  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;
  StreamSubscription? _magnetSub;
  StreamSubscription? _baroSub;
  StreamSubscription? _gpsSub;

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
    });
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
          ],
        ),
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
}

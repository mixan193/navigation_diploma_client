import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

class MapDebugOverlay extends StatefulWidget {
  final bool isDebugEnabled;

  const MapDebugOverlay({super.key, required this.isDebugEnabled});

  @override
  State<MapDebugOverlay> createState() => _MapDebugOverlayState();
}

class _MapDebugOverlayState extends State<MapDebugOverlay> {

  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  double? _pressure;
  double? _altitude;
  Position? _gpsPosition;
  String? _gpsError;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magnetSub;
  StreamSubscription<double>? _pressureSub;
  StreamSubscription<Position>? _gpsSub;

  @override
  void initState() {
    super.initState();
    _subscribeSensors();
  }

  void _subscribeSensors() {
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

    _pressureSub = manager.pressureStream.listen((pressureValue) {
      setState(() {
        _pressure = pressureValue;
        _altitude = manager.calculateRelativeAltitude(pressureValue);
      });
    });

    _gpsSub = manager.gpsStream.listen(
      (pos) {
        setState(() => _gpsPosition = pos);
      },
      onError: (e) {
        setState(() => _gpsError = e.toString());
      },
    );
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _magnetSub?.cancel();
    _pressureSub?.cancel();
    _gpsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDebugEnabled) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        color: Colors.black54,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MAP DEBUG OVERLAY',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            _buildDebugLine(
              'Accelerometer',
              _accelerometerValues != null ? _accelerometerValues!.map((v) => v.toStringAsFixed(2)).join(', ') : 'N/A',
            ),
            _buildDebugLine(
              'Gyroscope',
              _gyroscopeValues != null ? _gyroscopeValues!.map((v) => v.toStringAsFixed(2)).join(', ') : 'N/A',
            ),
            _buildDebugLine(
              'Magnetometer',
              _magnetometerValues != null ? _magnetometerValues!.map((v) => v.toStringAsFixed(2)).join(', ') : 'N/A',
            ),
            _buildDebugLine(
              'Barometer (hPa)',
              _pressure?.toStringAsFixed(2) ?? 'N/A',
            ),
            _buildDebugLine(
              'Altitude (m)',
              _altitude?.toStringAsFixed(2) ?? 'N/A',
            ),
            const Divider(color: Colors.white),
            const Text(
              'GPS',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (_gpsError != null)
              Text('Ошибка: $_gpsError', style: const TextStyle(color: Colors.red)),
            if (_gpsError == null && _gpsPosition != null)
              Text(
                'Lat: ${_gpsPosition!.latitude.toStringAsFixed(6)}\n'
                'Lon: ${_gpsPosition!.longitude.toStringAsFixed(6)}\n'
                'Alt: ${_gpsPosition!.altitude.toStringAsFixed(2)} m\n'
                'Acc: ±${_gpsPosition!.accuracy.toStringAsFixed(2)} m',
                style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
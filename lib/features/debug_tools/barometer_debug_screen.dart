import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:geolocator/geolocator.dart';

class BarometerDebugScreen extends StatefulWidget {
  const BarometerDebugScreen({super.key});

  @override
  State<BarometerDebugScreen> createState() => _BarometerDebugScreenState();
}

class _BarometerDebugScreenState extends State<BarometerDebugScreen> {
  double? _pressure;
  double? _altitude;
  double? _hybridAltitude;
  double? _seaLevelPressure;
  StreamSubscription<double>? _subscription;
  Timer? _gpsReferenceTimer;

  void _updateHybridAltitude() {
    final manager = SensorManager();
    final alt = manager.getHybridAltitude();
    setState(() {
      _hybridAltitude = alt;
    });
  }

  void _updateReferenceFromGPS() async {
    final pos =
        SensorManager().lastKnownGPS ?? await Geolocator.getCurrentPosition();
    final pressure = SensorManager().lastKnownPressure;
    if (pressure != null) {
      SensorManager().updateReferenceByGPS(
        pressure: pressure,
        altitude: pos.altitude,
      );
      setState(() {
        _seaLevelPressure = pressure;
        _altitude = SensorManager().calculateRelativeAltitude(pressure);
      });
      _updateHybridAltitude();
    }
  }

  @override
  void initState() {
    super.initState();
    _seaLevelPressure = SensorManager().referencePressure;
    _subscription = SensorManager().pressureStream.listen((pressure) {
      setState(() {
        _pressure = pressure;
        if (_seaLevelPressure != null) {
          _altitude = SensorManager().calculateRelativeAltitude(
            _seaLevelPressure!,
          );
        } else {
          _altitude = null;
        }
      });
      _updateHybridAltitude();
    });
    _updateHybridAltitude();
    // Периодически обновлять эталон по GPS (раз в 30 сек)
    _gpsReferenceTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateReferenceFromGPS(),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _gpsReferenceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barometer Debug')),
      body: Center(
        child:
            _pressure == null
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pressure: [1m${_pressure!.toStringAsFixed(2)} hPa\n'
                      'Baro Altitude: ${_altitude != null ? _altitude!.toStringAsFixed(2) : "-"} м',
                      style: const TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Гибридная высота: ${_hybridAltitude?.toStringAsFixed(2) ?? "-"} м',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

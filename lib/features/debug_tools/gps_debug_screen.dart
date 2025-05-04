import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

class GPSDebugScreen extends StatefulWidget {
  const GPSDebugScreen({super.key});

  @override
  State<GPSDebugScreen> createState() => GPSDebugScreenState();
}

class GPSDebugScreenState extends State<GPSDebugScreen> {
  Position? _position;
  String? _error;

  @override
  void initState() {
    super.initState();

    SensorManager().gpsStream.listen(
      (position) {
        setState(() => _position = position);
      },
      onError: (e) {
        setState(() => _error = e.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPS Debug')),
      body: Center(
        child: _error != null
            ? Text('Ошибка: $_error')
            : (_position != null
                ? Text(
                    'Lat: ${_position!.latitude.toStringAsFixed(6)}\n'
                    'Lon: ${_position!.longitude.toStringAsFixed(6)}\n'
                    'Alt: ${_position!.altitude.toStringAsFixed(2)} m\n'
                    'Accuracy: ±${_position!.accuracy.toStringAsFixed(2)} m',
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  )
                : const CircularProgressIndicator()),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

class BarometerDebugScreen extends StatefulWidget {
  const BarometerDebugScreen({super.key});

  @override
  State<BarometerDebugScreen> createState() => _BarometerDebugScreenState();
}

class _BarometerDebugScreenState extends State<BarometerDebugScreen> {
  double? _pressure;
  double? _altitude;

  @override
  void initState() {
    super.initState();
    final manager = SensorManager();
    manager.pressureStream.listen((pressure) {
      setState(() {
        _pressure = pressure;
        _altitude = manager.calculateRelativeAltitude(pressure);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barometer Debug')),
      body: Center(
        child: _pressure == null
            ? const CircularProgressIndicator()
            : Text(
                'Pressure: ${_pressure!.toStringAsFixed(2)} hPa\n'
                'Altitude: ${_altitude?.toStringAsFixed(2) ?? "-"} m',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}

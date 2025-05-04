import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

class AccelerometerDebugScreen extends StatefulWidget {
  const AccelerometerDebugScreen({super.key});

  @override
  State<AccelerometerDebugScreen> createState() => _AccelerometerDebugScreenState();
}

class _AccelerometerDebugScreenState extends State<AccelerometerDebugScreen> {
  List<double>? _values;

  @override
  void initState() {
    super.initState();
    SensorManager().accelerometerStream.listen((event) {
      setState(() {
        _values = [event.x, event.y, event.z];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accelerometer Debug')),
      body: Center(
        child: Text(
          _values != null
              ? 'X: ${_values![0].toStringAsFixed(2)}\n'
                'Y: ${_values![1].toStringAsFixed(2)}\n'
                'Z: ${_values![2].toStringAsFixed(2)}'
              : 'Waiting for data...',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

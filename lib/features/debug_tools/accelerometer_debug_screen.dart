import 'dart:async';
import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerDebugScreen extends StatefulWidget {
  const AccelerometerDebugScreen({super.key});

  @override
  State<AccelerometerDebugScreen> createState() =>
      _AccelerometerDebugScreenState();
}

class _AccelerometerDebugScreenState extends State<AccelerometerDebugScreen> {
  List<double>? _values;
  StreamSubscription<AccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = SensorManager().accelerometerStream.listen((event) {
      setState(() {
        _values = [event.x, event.y, event.z];
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
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

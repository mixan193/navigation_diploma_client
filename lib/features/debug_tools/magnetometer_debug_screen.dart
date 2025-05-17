import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MagnetometerDebugScreen extends StatefulWidget {
  const MagnetometerDebugScreen({super.key});

  @override
  State<MagnetometerDebugScreen> createState() => _MagnetometerDebugScreenState();
}

class _MagnetometerDebugScreenState extends State<MagnetometerDebugScreen> {
  StreamSubscription<MagnetometerEvent>? _sub;
  List<double>? _values;

  @override
  void initState() {
    super.initState();
    SensorManager().magnetometerStream.listen((event) {
      if (!mounted) return;
      setState(() => _values = [event.x, event.y, event.z]);
    });
  }

@override
  void dispose() {
    _sub?.cancel();                   // очень важно!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Magnetometer Debug')),
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

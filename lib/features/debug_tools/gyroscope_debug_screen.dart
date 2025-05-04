import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

class GyroscopeDebugScreen extends StatefulWidget {
  const GyroscopeDebugScreen({super.key});

  @override
  State<GyroscopeDebugScreen> createState() => _GyroscopeDebugScreenState();
}

class _GyroscopeDebugScreenState extends State<GyroscopeDebugScreen> {
  List<double>? _values;

  @override
  void initState() {
    super.initState();
    SensorManager().gyroscopeStream.listen((event) {
      setState(() => _values = [event.x, event.y, event.z]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gyroscope Debug')),
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

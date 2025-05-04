import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

class PositionDebugScreen extends StatefulWidget {
  const PositionDebugScreen({super.key});

  @override
  State<PositionDebugScreen> createState() => _PositionDebugScreenState();
}

class _PositionDebugScreenState extends State<PositionDebugScreen> {
  double _z = 0;

  @override
  void initState() {
    super.initState();
    SensorManager().pressureStream.listen((pressure) {
      setState(() {
        _z = SensorManager().calculateRelativeAltitude(pressure);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // x, y пока что временные заглушки
    const double x = 0.0;
    const double y = 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Position Debug')),
      body: Center(
        child: Text(
          'X: ${x.toStringAsFixed(2)}\n'
          'Y: ${y.toStringAsFixed(2)}\n'
          'Z: ${_z.toStringAsFixed(2)} m',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

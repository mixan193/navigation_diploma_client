import 'package:flutter/material.dart';
import 'sensor_debug_screen.dart';
import 'accelerometer_debug_screen.dart';
import 'gyroscope_debug_screen.dart';
import 'magnetometer_debug_screen.dart';
import 'wifi_debug_screen.dart';
import 'position_debug_screen.dart';
import 'gps_debug_screen.dart';
import 'barometer_debug_screen.dart';
import 'map_debug_screen.dart';

class DebugToolsMenu extends StatelessWidget {
  const DebugToolsMenu({super.key});

  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Tools')),
      body: ListView(
        children: [
          _buildButton(context, 'Sensor Overview', const SensorDebugScreen()),
          _buildButton(context, 'Accelerometer', const AccelerometerDebugScreen()),
          _buildButton(context, 'Gyroscope', const GyroscopeDebugScreen()),
          _buildButton(context, 'Magnetometer', const MagnetometerDebugScreen()),
          _buildButton(context, 'Wi-Fi RSSI', const WifiDebugScreen()),
          _buildButton(context, 'Position Debug', const PositionDebugScreen()),
          _buildButton(context, 'GPS Debug', const GPSDebugScreen()), 
          _buildButton(context, 'Barometer', const BarometerDebugScreen()),
          _buildButton(context, 'Map Debug', const MapDebugScreen()),
        ],
      ),
    );
  }
  
  Widget _buildButton(BuildContext context, String title, Widget screen) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
    );
  }
}

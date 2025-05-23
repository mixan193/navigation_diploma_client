import 'package:flutter/material.dart';
import 'position_debug_screen.dart';
import 'accelerometer_debug_screen.dart';
import 'gyroscope_debug_screen.dart';
import 'magnetometer_debug_screen.dart';
import 'wifi_debug_screen.dart';
import 'gps_debug_screen.dart';
import 'barometer_debug_screen.dart';
import 'log_exporter.dart';
import 'log_viewer_screen.dart';
import 'scan_debug_screen.dart';

class DebugToolsMenu extends StatelessWidget {
  const DebugToolsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Tools')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Position Debug'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PositionDebugScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Accelerometer Debug'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccelerometerDebugScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Gyroscope Debug'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GyroscopeDebugScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Magnetometer Debug'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MagnetometerDebugScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('WiFi Debug'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WiFiDebugScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('GPS Debug'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GPSDebugScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Barometer Debug'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarometerDebugScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Экспорт логов сенсоров'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(child: LogExporter()),
              );
            },
          ),
          ListTile(
            title: const Text('Просмотреть лог сенсоров'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogViewerScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Отправка скана (Wi-Fi/GPS/Baro)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanDebugScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

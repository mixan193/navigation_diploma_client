// sensor_debug_screen.dart (обновлённый)
import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:wifi_scan/wifi_scan.dart';

class SensorDebugScreen extends StatefulWidget {
  const SensorDebugScreen({super.key});

  @override
  State<SensorDebugScreen> createState() => _SensorDebugScreenState();
}

class _SensorDebugScreenState extends State<SensorDebugScreen> {
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  double? _barometricPressure;
  double? _relativeAltitude;
  List<WiFiAccessPoint>? _wifiAccessPoints = [];

  @override
  void initState() {
    super.initState();
    final manager = SensorManager();

    manager.accelerometerStream.listen((event) {
      setState(() => _accelerometerValues = [event.x, event.y, event.z]);
    });
    manager.gyroscopeStream.listen((event) {
      setState(() => _gyroscopeValues = [event.x, event.y, event.z]);
    });
    manager.magnetometerStream.listen((event) {
      setState(() => _magnetometerValues = [event.x, event.y, event.z]);
    });
    manager.pressureStream.listen((pressure) {
      setState(() {
        _barometricPressure = pressure;
        _relativeAltitude = manager.calculateRelativeAltitude(pressure);
      });
    });

    _startWifiScan(manager);
  }

  Future<void> _startWifiScan(SensorManager manager) async {
    final result = await manager.scanWifi();
    setState(() => _wifiAccessPoints = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Debug Screen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSensorCard('Accelerometer', _accelerometerValues),
            _buildSensorCard('Gyroscope', _gyroscopeValues),
            _buildSensorCard('Magnetometer', _magnetometerValues),
            _buildPressureCard(),
            _buildWifiList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startWifiScan(SensorManager()),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSensorCard(String title, List<double>? values) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(values != null
            ? values.map((e) => e.toStringAsFixed(2)).join(', ')
            : 'Awaiting data...'),
      ),
    );
  }

  Widget _buildPressureCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: const Text('Barometer'),
        subtitle: Text(_barometricPressure != null
            ? 'Pressure: ${_barometricPressure!.toStringAsFixed(2)} hPa\nEstimated Altitude: ${_relativeAltitude?.toStringAsFixed(2) ?? "-"} m'
            : 'Awaiting data...'),
      ),
    );
  }

  Widget _buildWifiList() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: const Text('Wi-Fi Networks (RSSI)'),
        children: _wifiAccessPoints != null && _wifiAccessPoints!.isNotEmpty
            ? _wifiAccessPoints!
                .map((ap) => ListTile(
                      title: Text(ap.ssid),
                      subtitle: Text("RSSI: \${ap.level} dBm"),
                    ))
                .toList()
            : [const ListTile(title: Text('Scanning Wi-Fi...'))],
      ),
    );
  }
}

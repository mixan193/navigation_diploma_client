import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

class WifiDebugScreen extends StatefulWidget {
  const WifiDebugScreen({super.key});

  @override
  State<WifiDebugScreen> createState() => _WifiDebugScreenState();
}

class _WifiDebugScreenState extends State<WifiDebugScreen> {
  List<WiFiAccessPoint>? _wifiAccessPoints;

  @override
  void initState() {
    super.initState();
    _scanWifi();
  }

  Future<void> _scanWifi() async {
    final results = await SensorManager().scanWifi();
    setState(() => _wifiAccessPoints = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wi-Fi Debug')),
      body: _wifiAccessPoints != null
          ? ListView(
              children: _wifiAccessPoints!
                  .map((ap) => ListTile(
                        title: Text(ap.ssid),
                        subtitle: Text('RSSI: ${ap.level} dBm\nBSSID: ${ap.bssid}'),
                      ))
                  .toList(),
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanWifi,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

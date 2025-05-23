import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WiFiDebugScreen extends StatefulWidget {
  const WiFiDebugScreen({super.key});

  @override
  State<WiFiDebugScreen> createState() => _WiFiDebugScreenState();
}

class _WiFiDebugScreenState extends State<WiFiDebugScreen> {
  List<WiFiAccessPoint> _results = [];

  @override
  void initState() {
    super.initState();
    WiFiScan.instance.canStartScan().then((can) {
      if (can == CanStartScan.yes) {
        WiFiScan.instance.startScan().then((_) {
          WiFiScan.instance.getScannedResults().then((results) {
            setState(() {
              _results = results;
            });
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WiFi Debug')),
      body: ListView(
        children:
            _results
                .map(
                  (ap) => ListTile(
                    title: Text(ap.ssid.isNotEmpty ? ap.ssid : ap.bssid),
                    subtitle: Text(
                      'RSSI: ${ap.level} dBm, Frequency: ${ap.frequency} MHz',
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

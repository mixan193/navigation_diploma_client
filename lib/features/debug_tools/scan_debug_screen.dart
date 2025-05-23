import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:geolocator/geolocator.dart';

class ScanDebugScreen extends StatefulWidget {
  const ScanDebugScreen({super.key});

  @override
  State<ScanDebugScreen> createState() => _ScanDebugScreenState();
}

class _ScanDebugScreenState extends State<ScanDebugScreen> {
  Map<String, dynamic>? lastScanData;
  bool sending = false;
  String? sendResult;
  bool loading = false;

  Future<void> _collectScan() async {
    setState(() {
      loading = true;
      sendResult = null;
    });
    await SensorManager().collectAndSendScan(
      buildingId: 0, // Можно заменить на актуальный
      floor: 0, // Можно заменить на актуальный
      onPositionUpdate: (data) {
        setState(() {
          lastScanData = data;
        });
      },
    );
    setState(() {
      loading = false;
    });
  }

  Future<void> _sendScanAgain() async {
    setState(() {
      sending = true;
      sendResult = null;
    });
    await SensorManager().collectAndSendScan(
      buildingId: 0,
      floor: 0,
      onPositionUpdate: (data) {
        setState(() {
          sendResult = data != null ? 'Отправлено успешно' : 'Ошибка отправки';
        });
      },
    );
    setState(() {
      sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug: Отправка скана')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: loading ? null : _collectScan,
              icon:
                  loading
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.wifi_tethering),
              label: const Text('Собрать и показать скан'),
            ),
            const SizedBox(height: 16),
            if (lastScanData != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Данные для отправки:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(lastScanData.toString()),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: sending ? null : _sendScanAgain,
                        icon:
                            sending
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.cloud_upload),
                        label: const Text('Отправить эти данные на сервер'),
                      ),
                      if (sendResult != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          sendResult!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

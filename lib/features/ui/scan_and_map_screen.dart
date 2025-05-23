import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:navigation_diploma_client/features/map/map_view.dart';

class ScanAndMapScreen extends StatefulWidget {
  final int buildingId;
  final int floor;
  const ScanAndMapScreen({
    super.key,
    required this.buildingId,
    required this.floor,
  });

  @override
  State<ScanAndMapScreen> createState() => _ScanAndMapScreenState();
}

class _ScanAndMapScreenState extends State<ScanAndMapScreen> {
  Map<String, dynamic>? userPosition;
  bool isLoading = false;
  String? error;
  Map<String, dynamic>? lastScanData;
  bool sending = false;
  String? sendResult;

  void _runScan() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      await SensorManager().collectAndSendScan(
        buildingId: widget.buildingId,
        floor: widget.floor,
        onPositionUpdate: (pos) {
          setState(() {
            userPosition = pos;
            lastScanData = pos;
          });
        },
      );
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendScanAgain() async {
    setState(() {
      sending = true;
      sendResult = null;
    });
    try {
      await SensorManager().collectAndSendScan(
        buildingId: widget.buildingId,
        floor: widget.floor,
        onPositionUpdate: (pos) {
          setState(() {
            sendResult = pos != null ? 'Отправлено успешно' : 'Ошибка отправки';
          });
        },
      );
    } catch (e) {
      setState(() {
        sendResult = 'Ошибка: $e';
      });
    } finally {
      setState(() {
        sending = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Автоматический скан при входе (можно убрать, если не нужно)
    // _runScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Навигация')),
      body: Column(
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Ошибка: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (lastScanData != null)
            Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Последние данные сканирования:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(lastScanData.toString()),
                    const SizedBox(height: 12),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _runScan,
              icon:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.wifi_tethering),
              label: Text(
                isLoading
                    ? 'Сканирование...'
                    : 'Сканировать и определить позицию',
              ),
              style: ElevatedButton.styleFrom(minimumSize: const Size(240, 48)),
            ),
          ),
          Expanded(
            child: MapView(
              buildingId: widget.buildingId,
              userPosition: userPosition,
            ),
          ),
        ],
      ),
    );
  }
}

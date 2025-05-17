import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:navigation_diploma_client/features/map/map_view.dart';

class ScanAndMapScreen extends StatefulWidget {
  final int buildingId;
  final int floor;
  const ScanAndMapScreen({Key? key, required this.buildingId, required this.floor}) : super(key: key);

  @override
  State<ScanAndMapScreen> createState() => _ScanAndMapScreenState();
}

class _ScanAndMapScreenState extends State<ScanAndMapScreen> {
  Map<String, dynamic>? userPosition;
  bool isLoading = false;
  String? error;

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
              child: Text('Ошибка: $error', style: const TextStyle(color: Colors.red)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _runScan,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(isLoading ? 'Сканирование...' : 'Сканировать и определить позицию'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(240, 48),
              ),
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

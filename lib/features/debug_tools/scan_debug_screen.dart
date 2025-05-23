import 'dart:async';
import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:navigation_diploma_client/features/sensors/wifi_service.dart';
import 'package:navigation_diploma_client/features/networking/api_client.dart';
import 'package:navigation_diploma_client/features/networking/scan_upload.dart';
import 'package:navigation_diploma_client/features/networking/wifi_observation.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class ScanDebugScreen extends StatefulWidget {
  const ScanDebugScreen({super.key});

  @override
  State<ScanDebugScreen> createState() => _ScanDebugScreenState();
}

class _ScanDebugScreenState extends State<ScanDebugScreen> {
  Position? _gps;
  double? _gpsAccuracy;
  double? _hybridAltitude;
  double? _baroPressure;
  List<WiFiAccessPoint> _wifiList = [];
  bool _sending = false;
  String? _sendResult;
  Timer? _gpsCalibTimer;
  StreamSubscription<Position>? _gpsSub;
  StreamSubscription<double>? _baroSub;

  @override
  void initState() {
    super.initState();
    _subscribeSensors();
    _scanWifi();
    _gpsCalibTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _calibrateByGPS(),
    );
  }

  void _subscribeSensors() {
    final manager = SensorManager();
    double? _bestAccuracy;
    _gpsSub = manager.gpsStream.listen((pos) {
      setState(() {
        _gps = pos;
        _gpsAccuracy = pos.accuracy;
        // Если эталон ещё не установлен — установить с любой точностью
        if (manager.referenceAltitude == null &&
            manager.lastKnownPressure != null) {
          manager.updateReferenceByGPS(
            pressure: manager.lastKnownPressure!,
            altitude: pos.altitude,
          );
          _bestAccuracy = pos.accuracy;
        }
        // Если точность улучшилась — перекалибровать эталон
        if (_bestAccuracy == null || pos.accuracy < _bestAccuracy!) {
          if (manager.lastKnownPressure != null) {
            manager.updateReferenceByGPS(
              pressure: manager.lastKnownPressure!,
              altitude: pos.altitude,
            );
            _bestAccuracy = pos.accuracy;
          }
        }
        _hybridAltitude = manager.getHybridAltitude();
      });
    });
    _baroSub = manager.pressureStream.listen((pressure) {
      manager.updatePressure(pressure);
      setState(() {
        _baroPressure = pressure;
        _hybridAltitude = manager.getHybridAltitude();
      });
    });
  }

  void _calibrateByGPS() {
    final manager = SensorManager();
    if (_gps != null &&
        _gpsAccuracy != null &&
        _gpsAccuracy! < 10 &&
        manager.lastKnownPressure != null) {
      manager.updateReferenceByGPS(
        pressure: manager.lastKnownPressure!,
        altitude: _gps!.altitude,
      );
      setState(() {
        _hybridAltitude = manager.getHybridAltitude();
      });
    }
  }

  Future<void> _scanWifi() async {
    final wifi = WifiService();
    final results = await wifi.scan();
    setState(() {
      _wifiList = results;
    });
  }

  Future<void> _sendScan() async {
    final manager = SensorManager();
    print(
      'DEBUG: referenceAltitude = [33m[1m${manager.referenceAltitude}[0m',
    );
    print(
      'DEBUG: referencePressure = [33m[1m${manager.referencePressure}[0m',
    );
    print(
      'DEBUG: lastKnownPressure = [33m[1m${manager.lastKnownPressure}[0m',
    );
    print(
      'DEBUG: getHybridAltitude = [33m[1m${manager.getHybridAltitude()}[0m',
    );
    if (_hybridAltitude == null) {
      setState(() {
        _sendResult =
            'Ошибка: высота (z) не определена! Проверьте GPS и барометр.';
      });
      return;
    }
    setState(() {
      _sending = true;
      _sendResult = null;
    });
    try {
      final scan = ScanUpload(
        buildingId: 0,
        floor: 0,
        lat: _gps?.latitude,
        lon: _gps?.longitude,
        accuracy: _gpsAccuracy,
        z: _hybridAltitude,
        observations:
            _wifiList
                .where((ap) => ap.ssid.isNotEmpty)
                .map(
                  (ap) => WiFiObservation(
                    ssid: ap.ssid,
                    bssid: ap.bssid,
                    rssi: ap.level,
                    frequency: ap.frequency,
                  ),
                )
                .toList(),
      );
      final json = scan.toJson();
      print('Request JSON: ' + json.toString());
      await ApiClient().uploadScan(scan);
      setState(() {
        _sendResult = 'Отправлено успешно';
      });
    } catch (e) {
      if (e is DioError && e.response != null) {
        print('Server response: \n' + e.response!.data.toString());
        setState(() {
          _sendResult = 'Ошибка отправки: ${e.response!.data}';
        });
      } else {
        setState(() {
          _sendResult = 'Ошибка отправки: $e';
        });
      }
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    _baroSub?.cancel();
    _gpsCalibTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug: Wi-Fi, GPS, Барометр')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('GPS: '),
                if (_gps != null)
                  Text(
                    'lat: ${_gps!.latitude.toStringAsFixed(6)}, lon: ${_gps!.longitude.toStringAsFixed(6)}',
                  ),
                if (_gpsAccuracy != null)
                  Text(' (±${_gpsAccuracy!.toStringAsFixed(1)} м)'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Высота: '),
                if (_hybridAltitude != null)
                  Text('${_hybridAltitude!.toStringAsFixed(2)} м'),
                if (_baroPressure != null)
                  Text(' (давл: ${_baroPressure!.toStringAsFixed(1)} гПа)'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _sending ? null : _sendScan,
                  icon:
                      _sending
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.cloud_upload),
                  label: const Text('Отправить на сервер'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _scanWifi,
                  icon: const Icon(Icons.wifi),
                  label: const Text('Обновить Wi-Fi'),
                ),
              ],
            ),
            if (_sendResult != null) ...[
              const SizedBox(height: 8),
              Text(
                '${_sendResult!}',
                style: TextStyle(
                  color:
                      _sendResult!.contains('успешно')
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Wi-Fi сети:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _wifiList.length,
                itemBuilder: (context, i) {
                  final ap = _wifiList[i];
                  return ListTile(
                    title: Text(ap.ssid.isNotEmpty ? ap.ssid : ap.bssid),
                    subtitle: Text(
                      'BSSID: ${ap.bssid}\nRSSI: ${ap.level} dBm, Freq: ${ap.frequency} MHz',
                    ),
                    trailing: Text('${ap.level} dBm'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

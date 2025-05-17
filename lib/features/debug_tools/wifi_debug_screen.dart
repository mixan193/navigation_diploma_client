import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation_diploma_client/features/networking/api_client.dart';
import 'package:navigation_diploma_client/features/networking/wifi_observation.dart';
import 'package:navigation_diploma_client/features/networking/scan_upload.dart';
// ... другие импорты ...

class WifiDebugScreen extends StatefulWidget {
  const WifiDebugScreen({Key? key}) : super(key: key);

  @override
  _WifiDebugScreenState createState() => _WifiDebugScreenState();
}

class _WifiDebugScreenState extends State<WifiDebugScreen> {
  List<WiFiAccessPoint>? _wifiAccessPoints;

  @override
  void initState() {
    super.initState();
    // Инициализация, запрос разрешений и т.д.
    // ...
    _scanWifi(); // первоначальный скан при открытии экрана
  }

  Future<void> _scanWifi() async {
    // Вызов сканирования Wi-Fi через SensorManager (обертка над wifi_service)
    final results = await SensorManager().scanWifi();
    setState(() {
      _wifiAccessPoints = results;
    });
  }

  Future<void> _uploadScan() async {
    final position = SensorManager().lastKnownGPS;
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет данных GPS для отправки')),
      );
      return;
    }

    // Формируем список Wi-Fi наблюдений, отфильтровывая недопустимые данные
    List<WiFiObservation> observations = [];
    if (_wifiAccessPoints != null) {
      for (final ap in _wifiAccessPoints!) {
        int? freq;
        try {
          freq = ap.frequency;
        } catch (_) {
          freq = null;
        }
        if (freq == null) continue;                      // пропускаем, если нет данных о частоте
        if (ap.ssid.trim().isEmpty) continue;            // пропускаем скрытые сети с пустым SSID
        if (freq < 2400 || freq > 2500) continue;        // пропускаем сети вне диапазона 2.4 ГГц (сервер их не примет)
        observations.add(WiFiObservation(
          ssid: ap.ssid,
          bssid: ap.bssid,
          rssi: ap.level,
          frequency: freq,
        ));
      }
    }
    if (observations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Список Wi-Fi сетей пуст')),
      );
      return;
    }

    // Создаем объект ScanUpload с текущими данными (GPS и Wi-Fi)
    final scan = ScanUpload(
      buildingId: 1,
      floor: 1,
      x: null,
      y: null,
      z: position.altitude,            // высота (altitude) по данным GPS
      lat: position.latitude,
      lon: position.longitude,
      accuracy: position.accuracy,
      observations: observations,
    );

    try {
      // Отправляем данные на сервер
      final result = await GetIt.I<ApiClient>().uploadScan(scan);
      // Отображаем статус и полученные координаты от сервера
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan uploaded: $result')),
      );
    } catch (e) {
      // В случае ошибки соединения/валидации
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI код для отображения списка Wi-Fi сетей и кнопок сканирования/отправки...
    return Scaffold(
      appBar: AppBar(title: const Text('Wi-Fi RSSI')),
      body: _wifiAccessPoints == null 
          ? Center(child: Text('Сканирование...')) 
          : ListView(
              children: _wifiAccessPoints!.map((ap) => ListTile(
                title: Text('${ap.ssid.isNotEmpty ? ap.ssid : "<hidden>"} (${ap.bssid})'),
                subtitle: Text('RSSI: ${ap.level} дБм, Частота: ${(() {
                  try { return ap.frequency; } catch(_) { return "n/a"; }
                })()} МГц'),
              )).toList(),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Кнопка повторного сканирования Wi-Fi
          FloatingActionButton(
            heroTag: 'scanWifi',
            onPressed: _scanWifi,
            child: const Icon(Icons.wifi),
            tooltip: 'Scan Wi-Fi',
          ),
          const SizedBox(height: 16),
          // Кнопка отправки скана на сервер
          FloatingActionButton(
            heroTag: 'uploadScan',
            onPressed: _uploadScan,
            tooltip: 'Upload Scan',
            child: const Icon(Icons.upload),
          ),
        ],
      ),
    );
  }
}
// ... другие методы и классы ...
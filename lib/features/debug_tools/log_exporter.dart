import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

class LogExporter extends StatefulWidget {
  const LogExporter({Key? key}) : super(key: key);

  @override
  State<LogExporter> createState() => _LogExporterState();
}

class _LogExporterState extends State<LogExporter> {
  String? _lastLogPath;
  bool _exporting = false;
  String? _error;

  Future<void> _exportLogs() async {
    setState(() {
      _exporting = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final filename = "navigation_log_${now.toIso8601String().replaceAll(':', '-')}.txt";
      final dir = await getTemporaryDirectory();
      final path = "${dir.path}/$filename";

      // Пример: собираем текущее состояние сенсоров (расширяйте по необходимости)
      final manager = SensorManager();
      final gps = manager.lastKnownGPS;
      final pressure = manager.lastKnownPressure;

      final sb = StringBuffer();
      sb.writeln("=== Лог датчиков (${now.toLocal()}) ===\n");

      // GPS
      sb.writeln("--- GPS ---");
      if (gps != null) {
        sb.writeln("lat: ${gps.latitude}, lon: ${gps.longitude}");
        sb.writeln("alt: ${gps.altitude}, точность: ${gps.accuracy}");
      } else {
        sb.writeln("Нет данных");
      }

      // Давление
      sb.writeln("\n--- Barometer ---");
      sb.writeln(pressure != null ? "Давление: $pressure hPa" : "Нет данных");

      // Можно добавить историю Wi-Fi, акселерометра, логи сканов — интегрируйте свою реализацию

      // Сохраняем в файл
      final file = File(path);
      await file.writeAsString(sb.toString());

      setState(() => _lastLogPath = path);

      // Открываем диалог для отправки/экспорта
      await Share.shareXFiles([XFile(path)], text: 'Лог сенсоров навигации');
    } catch (e) {
      setState(() => _error = "Ошибка экспорта: $e");
    } finally {
      setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Экспорт логов сенсоров",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download),
              label: Text(_exporting ? "Экспорт..." : "Выгрузить логи"),
              onPressed: _exporting ? null : _exportLogs,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_lastLogPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text("Файл сохранён: $_lastLogPath"),
              ),
          ],
        ),
      ),
    );
  }
}

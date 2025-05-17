import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:navigation_diploma_client/features/evacuation/plan_parser.dart';
import 'package:navigation_diploma_client/features/notes/poi_manager.dart';

class PlanImportScreen extends StatefulWidget {
  const PlanImportScreen({Key? key}) : super(key: key);

  @override
  State<PlanImportScreen> createState() => _PlanImportScreenState();
}

class _PlanImportScreenState extends State<PlanImportScreen> {
  String? _lastStatus;
  bool _importing = false;

  Future<void> _importPlan() async {
    setState(() {
      _lastStatus = null;
      _importing = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );
      if (result == null || result.files.single.path == null) {
        setState(() {
          _lastStatus = "Файл не выбран";
          _importing = false;
        });
        return;
      }
      final file = File(result.files.single.path!);
      final contents = await file.readAsString();

      // Импортируем план эвакуации из JSON
      PlanParser.importPOIFromJson(contents);

      setState(() {
        _lastStatus = "План успешно импортирован! Все POI добавлены.";
      });
    } catch (e) {
      setState(() {
        _lastStatus = "Ошибка импорта: $e";
      });
    } finally {
      setState(() {
        _importing = false;
      });
    }
  }

  void _clearPOIs() {
    POIManager().clear();
    setState(() {
      _lastStatus = "Все POI очищены.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Импорт плана эвакуации"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Очистить все POI",
            onPressed: _importing ? null : _clearPOIs,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: _importing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(_importing ? "Импорт..." : "Выбрать файл плана (.json)"),
              onPressed: _importing ? null : _importPlan,
            ),
            const SizedBox(height: 20),
            if (_lastStatus != null)
              Text(
                _lastStatus!,
                style: TextStyle(
                  color: _lastStatus!.startsWith("Ошибка") ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 30),
            const Text(
              "Требования к формату файла:\n"
              'JSON-массив с POI: [{"name":"...","x":10.0,"y":15.0,"floor":1,"type":"exit","description":"Главный выход"}]',
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

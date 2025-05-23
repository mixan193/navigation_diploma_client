import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  String? _logContent;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLatestLog();
  }

  Future<void> _loadLatestLog() async {
    try {
      final dir = await getTemporaryDirectory();
      final files =
          dir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.contains('navigation_log_'))
              .toList();
      if (files.isEmpty) {
        setState(() => _logContent = 'Нет сохранённых логов.');
        return;
      }
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );
      final latest = files.first;
      final content = await latest.readAsString();
      setState(() => _logContent = content);
    } catch (e) {
      setState(() => _error = 'Ошибка чтения лога: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лог сенсоров')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : _logContent == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(child: SelectableText(_logContent!)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/offline/offline_manager.dart';

class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool isOnline = true;
  int pending = 0;
  bool syncing = false;

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  Future<void> _updateStatus() async {
    final online = await OfflineManager().hasInternet;
    setState(() {
      isOnline = online;
      pending = OfflineManager().pendingCount;
    });
  }

  Future<void> _syncNow() async {
    setState(() {
      syncing = true;
    });
    await OfflineManager().sync();
    await _updateStatus();
    setState(() {
      syncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isOnline ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: isOnline ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isOnline
                    ? (pending == 0
                        ? 'Связь с сервером установлена'
                        : 'Ожидает отправки: $pending скан(ов)')
                    : 'Нет соединения с интернетом',
                style: TextStyle(
                  color: isOnline ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (pending > 0)
              ElevatedButton.icon(
                onPressed: syncing ? null : _syncNow,
                icon:
                    syncing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.sync),
                label: Text(syncing ? 'Синхронизация...' : 'Синхронизировать'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(50, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Обновить статус',
              onPressed: _updateStatus,
            ),
          ],
        ),
      ),
    );
  }
}

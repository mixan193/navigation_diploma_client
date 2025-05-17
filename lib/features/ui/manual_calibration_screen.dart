import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/networking/ap_out.dart';
import 'package:navigation_diploma_client/features/networking/api_client.dart';
import 'package:navigation_diploma_client/features/roles/permissions.dart';
import 'package:navigation_diploma_client/features/roles/role_manager.dart';

class ManualCalibrationScreen extends StatefulWidget {
  final int buildingId;
  const ManualCalibrationScreen({Key? key, required this.buildingId}) : super(key: key);

  @override
  State<ManualCalibrationScreen> createState() => _ManualCalibrationScreenState();
}

class _ManualCalibrationScreenState extends State<ManualCalibrationScreen> {
  List<AccessPointOut> aps = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAPs();
  }

  Future<void> _loadAPs() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ApiClient();
      aps = await api.getAccessPoints(widget.buildingId);
    } catch (e) {
      error = e.toString();
    }
    setState(() {
      loading = false;
    });
  }

  void _showEditDialog(AccessPointOut ap) {
    final xCtrl = TextEditingController(text: ap.x.toString());
    final yCtrl = TextEditingController(text: ap.y.toString());
    final zCtrl = TextEditingController(text: ap.z.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Калибровка AP: ${ap.ssid}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("BSSID: ${ap.bssid}"),
              TextField(
                controller: xCtrl,
                decoration: const InputDecoration(labelText: "X (м)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: yCtrl,
                decoration: const InputDecoration(labelText: "Y (м)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: zCtrl,
                decoration: const InputDecoration(labelText: "Z (м)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newX = double.tryParse(xCtrl.text);
                final newY = double.tryParse(yCtrl.text);
                final newZ = double.tryParse(zCtrl.text);
                if (newX == null || newY == null || newZ == null) return;
                await _updateAP(ap, newX, newY, newZ);
                Navigator.pop(context);
              },
              child: const Text("Сохранить"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAP(AccessPointOut ap, double x, double y, double z) async {
    setState(() => loading = true);
    try {
      final api = ApiClient();
      await api.updateAccessPoint(ap.bssid, x: x, y: y, z: z);
      await _loadAPs();
    } catch (e) {
      setState(() => error = "Ошибка обновления: $e");
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!Permissions.canCalibrate()) {
      return const Scaffold(
        body: Center(child: Text("Нет доступа: только для калибровщиков и админов")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ручная калибровка точек доступа"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : ListView.separated(
                  itemCount: aps.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final ap = aps[idx];
                    return ListTile(
                      title: Text(ap.ssid.isNotEmpty ? ap.ssid : ap.bssid),
                      subtitle: Text("x: ${ap.x.toStringAsFixed(2)}, y: ${ap.y.toStringAsFixed(2)}, z: ${ap.z.toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(ap),
                        tooltip: "Редактировать координаты",
                      ),
                    );
                  },
                ),
    );
  }
}

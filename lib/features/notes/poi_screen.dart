import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/notes/poi_manager.dart';

class POIScreen extends StatefulWidget {
  final int? selectedFloor; // Можно фильтровать по этажу

  const POIScreen({Key? key, this.selectedFloor}) : super(key: key);

  @override
  State<POIScreen> createState() => _POIScreenState();
}

class _POIScreenState extends State<POIScreen> {
  final _manager = POIManager();

  int? _floorFilter;

  @override
  void initState() {
    super.initState();
    _floorFilter = widget.selectedFloor;
    _manager.addListener(_onPOIUpdate);
  }

  @override
  void dispose() {
    _manager.removeListener(_onPOIUpdate);
    super.dispose();
  }

  void _onPOIUpdate() => setState(() {});

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    double? x, y;
    int? floor;
    POIType type = POIType.custom;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Добавить POI"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<POIType>(
                  value: type,
                  items: POIType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (val) => type = val ?? POIType.custom,
                  decoration: const InputDecoration(labelText: "Тип"),
                ),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Название"),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Описание"),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "X"),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => x = double.tryParse(v),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Y"),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => y = double.tryParse(v),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Этаж"),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => floor = int.tryParse(v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Отмена")),
            ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isEmpty || x == null || y == null || floor == null) return;
                  final poi = POI(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text,
                    x: x!,
                    y: y!,
                    floor: floor!,
                    type: type,
                    description: descCtrl.text,
                  );
                  _manager.addPOI(poi);
                  Navigator.pop(ctx);
                },
                child: const Text("Добавить")),
          ],
        );
      },
    );
  }

  void _removePOI(String id) {
    _manager.removePOI(id);
  }

  @override
  Widget build(BuildContext context) {
    final pois = _floorFilter == null
        ? _manager.pois
        : _manager.poisOnFloor(_floorFilter!);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Точки интереса (POI)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
            tooltip: "Добавить POI",
          ),
        ],
      ),
      body: pois.isEmpty
          ? const Center(child: Text("Нет точек интереса"))
          : ListView.builder(
              itemCount: pois.length,
              itemBuilder: (ctx, i) {
                final poi = pois[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    leading: Icon(poi.type.icon, color: Colors.blue),
                    title: Text(poi.name),
                    subtitle: Text(
                        "x: ${poi.x.toStringAsFixed(1)}, y: ${poi.y.toStringAsFixed(1)}, этаж: ${poi.floor}\n${poi.description ?? ""}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removePOI(poi.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
        tooltip: "Добавить POI",
      ),
    );
  }
}

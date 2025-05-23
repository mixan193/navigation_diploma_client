import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/notes/poi_manager.dart';
import 'package:provider/provider.dart';

class POIScreen extends StatelessWidget {
  final int? selectedFloor;

  const POIScreen({super.key, this.selectedFloor});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<POIManager>(
      create: (_) => POIManager(),
      child: Scaffold(
        appBar: AppBar(title: const Text('POI Screen')),
        body: Consumer<POIManager>(
          builder: (context, manager, child) {
            final list = manager.pois
                .where((poi) => selectedFloor == null || poi.floor == selectedFloor)
                .toList();
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final poi = list[index];
                return ListTile(
                  leading: Icon(poi.type.icon),
                  title: Text(poi.name),
                  subtitle: Text('Floor: ${poi.floor} (${poi.x}, ${poi.y})'),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final id = DateTime.now().millisecondsSinceEpoch.toString();
            final poi = POI(
              id: id,
              name: 'New POI $id',
              x: 0.0,
              y: 0.0,
              floor: selectedFloor ?? 1,
              type: POIType.custom,
            );
            Provider.of<POIManager>(context, listen: false).addPOI(poi);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
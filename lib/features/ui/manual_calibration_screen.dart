import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/features/networking/api_client.dart';

class ManualCalibrationScreen extends StatefulWidget {
  final int buildingId;
  const ManualCalibrationScreen({super.key, required this.buildingId});

  @override
  State<ManualCalibrationScreen> createState() =>
      _ManualCalibrationScreenState();
}

class _ManualCalibrationScreenState extends State<ManualCalibrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _xController = TextEditingController();
  final _yController = TextEditingController();
  final _zController = TextEditingController();
  final _bssidController = TextEditingController();
  final _floorController = TextEditingController();
  final _idController = TextEditingController();

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final api = ApiClient();
    final result = await api.addAccessPoint(
      buildingId: widget.buildingId,
      floor: int.tryParse(_floorController.text) ?? 0,
      x: double.tryParse(_xController.text) ?? 0,
      y: double.tryParse(_yController.text) ?? 0,
      z: double.tryParse(_zController.text),
      bssid: _bssidController.text,
      frequency: 2437,
      id: int.tryParse(_idController.text),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added AP: ${result.bssid} (floor ${result.floor})'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Calibration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _floorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Floor'),
              ),
              TextFormField(
                controller: _xController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'X'),
              ),
              TextFormField(
                controller: _yController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Y'),
              ),
              TextFormField(
                controller: _zController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Z'),
              ),
              TextFormField(
                controller: _bssidController,
                decoration: const InputDecoration(labelText: 'BSSID'),
              ),
              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'AP ID (optional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _onSubmit, child: const Text('Add AP')),
            ],
          ),
        ),
      ),
    );
  }
}

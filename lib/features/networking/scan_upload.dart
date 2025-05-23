import 'package:navigation_diploma_client/features/networking/wifi_observation.dart';

class ScanUpload {
  final int buildingId;
  final int floor;
  final double? x, y, z;
  final double? yaw, pitch, roll;
  final double? lat, lon;
  final double? accuracy;
  final List<WiFiObservation> observations;
  final DateTime timestamp;

  ScanUpload({
    required this.buildingId,
    required this.floor,
    this.x,
    this.y,
    this.z,
    this.yaw,
    this.pitch,
    this.roll,
    this.lat,
    this.lon,
    this.accuracy,
    required this.observations,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'floor': floor,
        'x': x,
        'y': y,
        'z': z,
        'yaw': yaw,
        'pitch': pitch,
        'roll': roll,
        'lat': lat,
        'lon': lon,
        'accuracy': accuracy,
        'observations': observations.map((e) => e.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
      };
}
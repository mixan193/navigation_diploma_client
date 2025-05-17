import 'package:navigation_diploma_client/features/networking/wifi_observation.dart';

class ScanUpload {
  final int buildingId;
  final int floor;
  final double? x, y, z;
  final double? yaw, pitch, roll;
  final double? lat, lon;
  final double? accuracy;
  final List<WiFiObservation> observations;

  ScanUpload({
    required this.buildingId,
    required this.floor,
    this.x, this.y, this.z,
    this.yaw, this.pitch, this.roll,
    this.lat, this.lon, this.accuracy,
    required this.observations,
  });

  Map<String, dynamic> toJson() => {
    'building_id': buildingId,
    'floor': floor,
    'x': x,
    'y': y,
    'z': z,
    'yaw': yaw,
    'pitch': pitch,
    'roll': roll,
    if (lat != null) 'lat': lat,
    if (lon != null) 'lon': lon,
    if (accuracy != null) 'accuracy': accuracy,
    'observations': observations.map((o) => o.toJson()).toList(),
  };
}

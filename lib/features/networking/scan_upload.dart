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

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'building_id': buildingId,
      'floor': floor,
      'observations': observations.map((e) => e.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
    if (x != null) data['x'] = x;
    if (y != null) data['y'] = y;
    if (z != null) data['z'] = z;
    if (yaw != null) data['yaw'] = yaw;
    if (pitch != null) data['pitch'] = pitch;
    if (roll != null) data['roll'] = roll;
    if (lat != null) data['lat'] = lat;
    if (lon != null) data['lon'] = lon;
    if (accuracy != null) data['accuracy'] = accuracy;
    return data;
  }
}

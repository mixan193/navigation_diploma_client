class AccessPointOut {
  final int id;
  final String bssid;
  final String? ssid;
  final int buildingId;
  final int floor;
  final double x, y;
  final double? z;
  final DateTime createdAt;

  AccessPointOut({
    required this.id,
    required this.bssid,
    this.ssid,
    required this.buildingId,
    required this.floor,
    required this.x,
    required this.y,
    this.z,
    required this.createdAt,
  });

  factory AccessPointOut.fromJson(Map<String, dynamic> json) => AccessPointOut(
    id:          json['id'],
    bssid:       json['bssid'],
    ssid:        json['ssid'],
    buildingId:  json['building_id'],
    floor:       json['floor'],
    x:           (json['x'] as num).toDouble(),
    y:           (json['y'] as num).toDouble(),
    z:           json['z'] != null ? (json['z'] as num).toDouble() : null,
    createdAt:   DateTime.parse(json['created_at']),
  );
}
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
    required this.ssid,
    required this.buildingId,
    required this.floor,
    required this.x,
    required this.y,
    this.z,
    required this.createdAt,
  });

  factory AccessPointOut.fromJson(Map<String, dynamic> json) {
    return AccessPointOut(
      id: json['id'] as int,
      bssid: json['bssid'] as String,
      ssid: json['ssid'] as String?,
      buildingId: json['buildingId'] as int,
      floor: json['floor'] as int,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: json['z'] != null ? (json['z'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bssid': bssid,
        'ssid': ssid,
        'buildingId': buildingId,
        'floor': floor,
        'x': x,
        'y': y,
        'z': z,
        'createdAt': createdAt.toIso8601String(),
      };
}
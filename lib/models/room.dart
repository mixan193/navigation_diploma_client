class RoomModel {
  final String id;
  final String name;
  final double x;
  final double y;
  final double z;
  final int floorNumber;
  final List<String> neighbors;

  RoomModel({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.z,
    required this.floorNumber,
    required this.neighbors,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num?)?.toDouble() ?? 0.0,
      floorNumber: json['floorNumber'],
      neighbors: List<String>.from(json['neighbors'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'x': x,
    'y': y,
    'z': z,
    'floorNumber': floorNumber,
    'neighbors': neighbors,
  };
}

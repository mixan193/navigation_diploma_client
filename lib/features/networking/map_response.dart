import 'package:navigation_diploma_client/features/networking/ap_out.dart';

class FloorSchema {
  final int floor;
  final List<List<double>> polygon;
  final List<AccessPointOut> accessPoints;

  FloorSchema({
    required this.floor,
    required this.polygon,
    required this.accessPoints,
  });

  factory FloorSchema.fromJson(Map<String, dynamic> json) => FloorSchema(
    floor: json['floor'],
    polygon: List<List<double>>.from(
      (json['polygon'] as List).map((row) => List<double>.from((row as List).map((x) => (x as num).toDouble())))
    ),
    accessPoints: (json['access_points'] as List)
      .map((e) => AccessPointOut.fromJson(e))
      .toList(),
  );
}
class MapResponse {
  final int buildingId;
  final String buildingName;
  final String address;
  final List<FloorSchema> floors;

  MapResponse({
    required this.buildingId,
    required this.buildingName,
    required this.address,
    required this.floors,
  });

  factory MapResponse.fromJson(Map<String, dynamic> json) => MapResponse(
    buildingId:    json['building_id'],
    buildingName:  json['building_name'],
    address:       json['address'],
    floors:        (json['floors'] as List).map((e) => FloorSchema.fromJson(e)).toList(),
  );
}
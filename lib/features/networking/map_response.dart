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

  factory FloorSchema.fromJson(Map<String, dynamic> json) {
    return FloorSchema(
      floor: json['floor'] as int,
      polygon: (json['polygon'] as List<dynamic>)
          .map((e) => (e as List).map((x) => (x as num).toDouble()).toList())
          .toList(),
      accessPoints: (json['accessPoints'] as List<dynamic>)
          .map((e) => AccessPointOut.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'floor': floor,
        'polygon': polygon,
        'accessPoints': accessPoints.map((e) => e.toJson()).toList(),
      };
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

  factory MapResponse.fromJson(Map<String, dynamic> json) {
    return MapResponse(
      buildingId: json['buildingId'] as int,
      buildingName: json['buildingName'] as String,
      address: json['address'] as String,
      floors: (json['floors'] as List<dynamic>)
          .map((e) => FloorSchema.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'buildingName': buildingName,
        'address': address,
        'floors': floors.map((e) => e.toJson()).toList(),
      };
}
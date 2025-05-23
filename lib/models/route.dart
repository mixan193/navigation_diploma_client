class RouteModel {
  final String id;
  final List<RoutePoint> points;
  final double length;
  final int floorFrom;
  final int floorTo;

  RouteModel({
    required this.id,
    required this.points,
    required this.length,
    required this.floorFrom,
    required this.floorTo,
  });
}

class RoutePoint {
  final double x;
  final double y;
  final double z;
  final int floor;

  RoutePoint({
    required this.x,
    required this.y,
    required this.z,
    required this.floor,
  });
}

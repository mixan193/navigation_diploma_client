import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GpsService {
  final _controller = StreamController<Position>.broadcast();
  StreamSubscription<Position>? _positionSubscription;
  Position? latestPosition;

Future<void> start() async {
  final hasPermission = await _handlePermission();
  if (!hasPermission) {
    _controller.addError('Location permissions are denied');
    return;
  }

  const locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
    
  );

  _positionSubscription = Geolocator.getPositionStream(
    locationSettings: locationSettings,
  ).listen((position) {
    latestPosition = position;
    _controller.add(position);
  });
}

  Stream<Position> get stream => _controller.stream;

  void dispose() {
    _positionSubscription?.cancel();
    _controller.close();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}

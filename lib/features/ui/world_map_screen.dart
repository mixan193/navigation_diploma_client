import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class WorldMapScreen extends StatefulWidget {
  final LatLng? buildingLocation;
  final String? buildingName;
  const WorldMapScreen({super.key, this.buildingLocation, this.buildingName});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  LatLng? _userLocation;
  bool _isNearBuilding = false;
  final double _proximityRadius = 30.0; // метров
  final double _zoom = 16.0;
  StreamSubscription<Position>? _positionSubscription;
  double? _userAltitude;
  double? _userAccuracy;
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _determinePosition();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _userAltitude = position.altitude;
      _userAccuracy = position.accuracy;
      _isNearBuilding = _checkProximity();
    });
    _positionSubscription = Geolocator.getPositionStream().listen((pos) {
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
        _userAltitude = pos.altitude;
        _userAccuracy = pos.accuracy;
        _isNearBuilding = _checkProximity();
      });
    });
  }

  bool _checkProximity() {
    if (_userLocation == null || widget.buildingLocation == null) return false;
    final distance = Distance().as(
      LengthUnit.Meter,
      _userLocation!,
      widget.buildingLocation!,
    );
    return distance <= _proximityRadius;
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter =
        _userLocation ??
        widget.buildingLocation ??
        LatLng(55.751244, 37.618423);
    return Scaffold(
      appBar: AppBar(title: const Text('Мировая карта')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: _zoom,
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom |
                    InteractiveFlag.flingAnimation |
                    InteractiveFlag.scrollWheelZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.navigation_diploma_client',
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 50,
                      height: 50,
                      child: Tooltip(
                        message: 'Вы здесь',
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              if (widget.buildingLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.buildingLocation!,
                      width: 60,
                      height: 60,
                      child: Tooltip(
                        message: widget.buildingName ?? 'Здание',
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_city,
                              color: Colors.red,
                              size: 36,
                            ),
                            if (widget.buildingName != null)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.buildingName!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_userAltitude != null)
            Positioned(
              top: 16,
              right: 16,
              child: Card(
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Высота: ${_userAltitude!.toStringAsFixed(2)} м' +
                        (_userAccuracy != null
                            ? ' (±${_userAccuracy!.toStringAsFixed(1)} м)'
                            : ''),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_userLocation != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton(
                heroTag: 'centerUser',
                mini: true,
                onPressed: () {
                  _mapController?.move(_userLocation!, _zoom);
                },
                tooltip: 'Центрировать по мне',
                child: const Icon(Icons.my_location),
              ),
            ),
          if (_isNearBuilding)
            FloatingActionButton.extended(
              icon: const Icon(Icons.door_front_door),
              label: const Text('Внутренняя карта'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Внутренняя карта в разработке'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

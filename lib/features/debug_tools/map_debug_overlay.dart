import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';

/// Виджет, накладывающий на карту (или другой экран) панель
/// отладки, показывающую данные сенсоров, GPS и т.д.
class MapDebugOverlay extends StatefulWidget {
  /// Если [isDebugEnabled] == false, панель не будет отображаться.
  final bool isDebugEnabled;

  const MapDebugOverlay({
    super.key,
    required this.isDebugEnabled,
  });

  @override
  State<MapDebugOverlay> createState() => _MapDebugOverlayState();
}

class _MapDebugOverlayState extends State<MapDebugOverlay> {
  bool _showPanel = true;

  // Храним последние полученные данные от сенсоров:
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  double? _pressure;
  double? _altitude;
  Position? _gpsPosition;
  String? _gpsError;

  // Подписки на потоки, чтобы корректно отменять в dispose()
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magnetSub;
  StreamSubscription<double>? _pressureSub;
  StreamSubscription<Position>? _gpsSub;

  @override
  void initState() {
    super.initState();
    _subscribeSensors();
  }

  void _subscribeSensors() {
    final manager = SensorManager();

    // Подписка на акселерометр
    _accelSub = manager.accelerometerStream.listen((event) {
      setState(() => _accelerometerValues = [event.x, event.y, event.z]);
    });

    // Подписка на гироскоп
    _gyroSub = manager.gyroscopeStream.listen((event) {
      setState(() => _gyroscopeValues = [event.x, event.y, event.z]);
    });

    // Подписка на магнитометр
    _magnetSub = manager.magnetometerStream.listen((event) {
      setState(() => _magnetometerValues = [event.x, event.y, event.z]);
    });

    // Подписка на барометр
    _pressureSub = manager.pressureStream.listen((pressureValue) {
      setState(() {
        _pressure = pressureValue;
        _altitude = manager.calculateRelativeAltitude(pressureValue);
      });
    });

    // Подписка на GPS
    _gpsSub = manager.gpsStream.listen(
      (pos) {
        setState(() => _gpsPosition = pos);
      },
      onError: (e) {
        setState(() => _gpsError = e.toString());
      },
    );
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _magnetSub?.cancel();
    _pressureSub?.cancel();
    _gpsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Если отладка выключена, не отображаем ничего
    if (!widget.isDebugEnabled) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      right: 0,
      child: _showPanel
          ? Container(
              width: 260,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              color: Colors.black54,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MAP DEBUG OVERLAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Акселерометр
                    _buildDebugLine(
                      'Accelerometer',
                      _accelerometerValues != null
                          ? _accelerometerValues!
                              .map((v) => v.toStringAsFixed(2))
                              .join(', ')
                          : 'N/A',
                    ),

                    // Гироскоп
                    _buildDebugLine(
                      'Gyroscope',
                      _gyroscopeValues != null
                          ? _gyroscopeValues!
                              .map((v) => v.toStringAsFixed(2))
                              .join(', ')
                          : 'N/A',
                    ),

                    // Магнитометр
                    _buildDebugLine(
                      'Magnetometer',
                      _magnetometerValues != null
                          ? _magnetometerValues!
                              .map((v) => v.toStringAsFixed(2))
                              .join(', ')
                          : 'N/A',
                    ),

                    // Барометр
                    _buildDebugLine(
                      'Barometer (hPa)',
                      _pressure?.toStringAsFixed(2) ?? 'N/A',
                    ),

                    // Оценка высоты
                    _buildDebugLine(
                      'Altitude (m)',
                      _altitude?.toStringAsFixed(2) ?? 'N/A',
                    ),

                    // GPS
                    const Divider(color: Colors.white),
                    Text(
                      'GPS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_gpsError != null)
                      Text(
                        'Ошибка: $_gpsError',
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (_gpsPosition != null)
                      Text(
                        'Lat: ${_gpsPosition!.latitude.toStringAsFixed(6)}\n'
                        'Lon: ${_gpsPosition!.longitude.toStringAsFixed(6)}\n'
                        'Alt: ${_gpsPosition!.altitude.toStringAsFixed(2)} m\n'
                        'Accuracy: ±${_gpsPosition!.accuracy.toStringAsFixed(2)} м',
                        style: const TextStyle(color: Colors.white),
                      )
                    else
                      const Text('Waiting for GPS...', style: TextStyle(color: Colors.white)),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(() => _showPanel = false),
                          child: const Text('Hide'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.white),
              onPressed: () => setState(() => _showPanel = true),
            ),
    );
  }

  Widget _buildDebugLine(String label, String value) {
    return Text(
      '$label: $value',
      style: const TextStyle(color: Colors.white),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:navigation_diploma_client/di/service_locator.dart';
import 'package:navigation_diploma_client/features/sensors/sensor_manager.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SensorManager().initialize();
  setupLocator();
  runApp(const IndoorNavigationApp());
}
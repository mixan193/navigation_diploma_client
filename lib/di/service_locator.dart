import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../config/env.dart';
import '../features/networking/api_client.dart';
import '../features/storage/map_dao.dart';
import '../features/networking/connectivity_checker.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    ),
  );
  locator.registerLazySingleton(() => ApiClient());
  locator.registerLazySingleton(() => MapDao());
  locator.registerLazySingleton(() => ConnectivityChecker());
}
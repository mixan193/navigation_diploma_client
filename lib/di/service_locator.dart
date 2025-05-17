import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../config/env.dart';
import '../features/networking/api_client.dart';
import '../features/storage/map_dao.dart';
import '../features/networking/connectivity_checker.dart';

/// Глобальный экземпляр сервис-локатора
final GetIt locator = GetIt.instance;

/// Регистрация всех сервисов и DAO
void setupLocator() {
  // 1) HTTP-клиент (Dio) с таймаутами в виде Duration
  locator.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    ),
  );

  // 2) ApiClient: обёртка над Dio
  locator.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: locator<Dio>()),
  );

  // 3) MapDao: запросы к серверу для карты
  locator.registerLazySingleton<MapDao>(
    () => MapDao(),
  );

  // 4) ConnectivityChecker: слушаем статус сети
  locator.registerLazySingleton<ConnectivityChecker>(
    () => ConnectivityChecker(),
  );
}

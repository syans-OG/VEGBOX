import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../services/cart_service.dart';
import '../../services/favorites_service.dart';
import '../../services/notification_service.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';
import '../../services/vegetable_service.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<Dio>(DioClient.createDio);
  getIt.registerLazySingleton<VegetableService>(
    () => VegetableService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<CartService>(CartService.new);
  getIt.registerLazySingleton<FavoritesService>(FavoritesService.new);
  getIt.registerLazySingleton<OrderService>(OrderService.new);
  getIt.registerLazySingleton<NotificationService>(NotificationService.new);
  getIt.registerLazySingleton<UserService>(UserService.new);
}

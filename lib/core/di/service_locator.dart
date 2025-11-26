import 'package:get_it/get_it.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/ride_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/websocket_service.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/client/client_bloc.dart';
import '../../logic/driver/driver_bloc.dart';
import '../../logic/language/language_cubit.dart';
import '../../logic/profile/profile_cubit.dart';
import '../../logic/ride_history/ride_history_cubit.dart';

final getIt = GetIt.instance;

/// Setup dependency injection for the app.
/// Call this once in main() before runApp().
Future<void> setupDependencies() async {
  // ===== Services =====
  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService());

  // ===== Repositories =====
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton<LocationRepository>(() => LocationRepository());
  getIt.registerLazySingleton<RideRepository>(() => RideRepository());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());

  // ===== BLoCs & Cubits (as Factories) =====
  // Global/Long-lived Cubits
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerFactory<LanguageCubit>(() => LanguageCubit());

  // Screen-specific BLoCs
  getIt.registerFactory<ClientBloc>(() => ClientBloc(
        getIt<LocationRepository>(),
        getIt<RideRepository>(),
        getIt<WebSocketService>(),
      ));

  getIt.registerFactory<DriverBloc>(() => DriverBloc(
        getIt<LocationRepository>(),
        getIt<RideRepository>(),
        getIt<WebSocketService>(),
      ));

  // Cubits for profile/history
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt<UserRepository>()));
  getIt.registerFactory<RideHistoryCubit>(() => RideHistoryCubit(getIt<UserRepository>()));
}

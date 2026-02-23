import 'package:get_it/get_it.dart';
import '../data/services/api_service.dart';
import '../data/services/crypto_service.dart';
import '../data/services/encoding_service.dart';
import '../data/services/history_service.dart';
import '../data/services/timestamp_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<CryptoService>(() => CryptoService());
  getIt.registerLazySingleton<EncodingService>(() => EncodingService());
  getIt.registerLazySingleton<HistoryService>(() => HistoryService());
  getIt.registerLazySingleton<TimestampService>(() => TimestampService());
}

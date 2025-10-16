import 'package:get_it/get_it.dart';
import 'package:watertrack/services/notification_service.dart';
import 'package:watertrack/services/prefs_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => PrefsService());
  locator.registerLazySingleton(() => NotificationService());
}

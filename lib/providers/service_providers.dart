import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watertrack/locator.dart';
import 'package:watertrack/services/notification_service.dart';
import 'package:watertrack/services/prefs_service.dart';

final prefsServiceProvider = Provider<PrefsService>((ref) {
  return locator<PrefsService>();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return locator<NotificationService>();
});

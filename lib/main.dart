import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watertrack/locator.dart';
import 'package:watertrack/pages/splash_page.dart';
import 'package:watertrack/pages/onboarding_page.dart';
import 'package:watertrack/pages/home_page.dart';
import 'package:watertrack/pages/stats_page.dart';
import 'package:watertrack/theme/app_theme.dart';
import 'package:watertrack/services/notification_service.dart';
import 'package:watertrack/services/prefs_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await _initTimezone();
  await locator<PrefsService>().init();
  await locator<NotificationService>().initialize();
  runApp(const ProviderScope(child: WaterTrackApp()));
}

Future<void> _initTimezone() async {
  tz.initializeTimeZones();
  try {
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    // Log or handle the error if timezone cannot be determined
    print('Could not determine local timezone: $e');
  }
}

class WaterTrackApp extends StatelessWidget {
  const WaterTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterTrack',
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
      routes: {
        '/splash': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/home': (context) => const HomePage(),
        '/stats': (context) => const StatsPage(),
      },
    );
  }
}
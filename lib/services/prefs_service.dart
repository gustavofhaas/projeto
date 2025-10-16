import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  late SharedPreferences _instance;

  Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static const String _keyDailyGoal = 'daily_goal';
  static const String _keyFirstReminderTime = 'first_reminder_time';
  static const String _keyLastReminderTime = 'last_reminder_time';
  static const String _keyReminderInterval = 'reminder_interval';
  static const String _keyIsFirstRun = 'is_first_run';
  static const String _keyDailyProgress = 'daily_progress';

  bool isFirstRun() {
    return _instance.getBool(_keyIsFirstRun) ?? true;
  }

  Future<void> setFirstRunComplete() async {
    await _instance.setBool(_keyIsFirstRun, false);
  }

  Future<void> setDailyGoal(double liters) async {
    await _instance.setDouble(_keyDailyGoal, liters);
  }

  double getDailyGoal() {
    return _instance.getDouble(_keyDailyGoal) ?? 2.0; // Padrão: 2 litros
  }

  Future<void> setFirstReminderTime(String time) async {
    await _instance.setString(_keyFirstReminderTime, time);
  }

  String? getFirstReminderTime() {
    return _instance.getString(_keyFirstReminderTime);
  }

  Future<void> setLastReminderTime(String time) async {
    await _instance.setString(_keyLastReminderTime, time);
  }

  String? getLastReminderTime() {
    return _instance.getString(_keyLastReminderTime);
  }

  Future<void> setReminderInterval(int minutes) async {
    await _instance.setInt(_keyReminderInterval, minutes);
  }

  int? getReminderInterval() {
    return _instance.getInt(_keyReminderInterval) ?? 120; // Padrão: 2 horas
  }

  Future<void> setDailyProgress(double progress) async {
    await _instance.setDouble(_keyDailyProgress, progress);
  }

  double getDailyProgress() {
    return _instance.getDouble(_keyDailyProgress) ?? 0.0;
  }

  Future<void> resetDailyProgress() async {
    await setDailyProgress(0.0);
  }
}
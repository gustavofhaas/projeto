import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<bool> requestPermission() async {
    if (!_initialized) {
      await initialize();
    }
    
    return true; // Permissão será solicitada durante a inicialização
  }

  Future<void> initialize() async {
    if (_initialized) return;

    // Timezone is now initialized in main.dart

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) async {
        // Tratamento de notificação quando o app está aberto
      },
    );
    
    _initialized = true;
  }

  Future<void> scheduleReminders({
    required String startTime,
    required String endTime,
    required int intervalMinutes,
  }) async {
    try {
      await initialize();
      await _notifications.cancelAll(); // Cancela notificações anteriores

      // Validações básicas
      if (startTime.isEmpty || endTime.isEmpty) {
        throw Exception('Horários inválidos');
      }
      
      if (intervalMinutes <= 0) {
        throw Exception('Intervalo deve ser maior que zero');
      }

      // Converte strings de tempo para DateTime
      final now = DateTime.now();
      final start = _parseTimeString(startTime, now);
      final end = _parseTimeString(endTime, now);

      // Se o horário inicial já passou hoje, agenda para amanhã
      final DateTime adjustedStart = start.isBefore(now)
          ? start.add(const Duration(days: 1))
          : start;
          
      final DateTime adjustedEnd = end.isBefore(adjustedStart)
          ? end.add(const Duration(days: 1))
          : end;

      // Valida se o período é válido
      if (adjustedEnd.isBefore(adjustedStart)) {
        throw Exception('O horário final deve ser depois do horário inicial');
      }

      // Calcula quantas notificações serão enviadas
      final totalMinutes = adjustedEnd.difference(adjustedStart).inMinutes;
      if (totalMinutes <= 0) {
        throw Exception('Período inválido para notificações');
      }

      final notificationCount = totalMinutes ~/ intervalMinutes;
      if (notificationCount <= 0) {
        throw Exception('Intervalo muito grande para o período selecionado');
      }

      // Agenda as notificações
      var scheduledCount = 0;
      for (var i = 0; i < notificationCount; i++) {
        final scheduledTime = adjustedStart.add(Duration(minutes: i * intervalMinutes));
        
        if (scheduledTime.isAfter(now) && scheduledTime.isBefore(adjustedEnd)) {
          await _scheduleNotification(
            id: i,
            title: 'Hora de beber água! 💧',
            body: 'Mantenha-se hidratado para um dia mais saudável!',
            scheduledTime: scheduledTime,
          );
          scheduledCount++;
        }
      }

      if (scheduledCount == 0) {
        throw Exception('Nenhuma notificação pôde ser agendada para o período selecionado');
      }
    } catch (e) {
      throw Exception('Erro ao agendar notificações: ${e.toString()}');
    }
  }

  DateTime _parseTimeString(String timeString, DateTime reference) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(
      reference.year,
      reference.month,
      reference.day,
      hour,
      minute,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final location = tz.local;
    final scheduledDate = tz.TZDateTime(
      location,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder',
          'Lembretes de Água',
          channelDescription: 'Lembretes para beber água',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentBadge: true,
          presentAlert: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

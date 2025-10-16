import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WaterRecord {
  final DateTime timestamp;
  final double amount;

  WaterRecord({
    required this.timestamp,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'amount': amount,
  };

  factory WaterRecord.fromJson(Map<String, dynamic> json) => WaterRecord(
    timestamp: DateTime.parse(json['timestamp']),
    amount: json['amount'],
  );
}

class HistoryService {
  static const String _keyDailyRecords = 'daily_records';
  static const String _keyMonthlyStats = 'monthly_stats';

  // Adiciona um registro de consumo de água
  static Future<void> addRecord(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final record = WaterRecord(
      timestamp: DateTime.now(),
      amount: amount,
    );

    // Carrega registros existentes
    final records = await getDailyRecords();
    records.add(record);

    // Remove registros mais antigos que 30 dias
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    records.removeWhere((r) => r.timestamp.isBefore(thirtyDaysAgo));

    // Salva registros atualizados
    await prefs.setString(_keyDailyRecords, jsonEncode(
      records.map((r) => r.toJson()).toList(),
    ));

    // Atualiza estatísticas mensais
    await _updateMonthlyStats(records);
  }

  // Obtém registros do dia atual
  static Future<List<WaterRecord>> getTodayRecords() async {
    final records = await getDailyRecords();
    final today = DateTime.now();
    return records.where((r) => 
      r.timestamp.year == today.year &&
      r.timestamp.month == today.month &&
      r.timestamp.day == today.day
    ).toList();
  }

  // Obtém todos os registros dos últimos 30 dias
  static Future<List<WaterRecord>> getDailyRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_keyDailyRecords);
    if (recordsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(recordsJson);
    return decoded.map((json) => WaterRecord.fromJson(json)).toList();
  }

  // Obtém estatísticas da semana atual
  static Future<Map<String, double>> getWeeklyStats() async {
    final records = await getDailyRecords();
    final stats = <String, double>{};
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayTotal = records.where((r) =>
        r.timestamp.year == date.year &&
        r.timestamp.month == date.month &&
        r.timestamp.day == date.day
      ).fold(0.0, (sum, record) => sum + record.amount);
      
      stats[date.toIso8601String().split('T')[0]] = dayTotal;
    }

    return stats;
  }

  // Obtém estatísticas mensais
  static Future<Map<String, double>> getMonthlyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_keyMonthlyStats);
    if (statsJson == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(statsJson);
    return decoded.map((key, value) => MapEntry(key, value.toDouble()));
  }

  // Atualiza estatísticas mensais
  static Future<void> _updateMonthlyStats(List<WaterRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = <String, double>{};

    // Agrupa registros por mês
    for (final record in records) {
      final monthKey = '${record.timestamp.year}-${record.timestamp.month}';
      stats[monthKey] = (stats[monthKey] ?? 0) + record.amount;
    }

    await prefs.setString(_keyMonthlyStats, jsonEncode(stats));
  }

  // Limpa todos os dados do histórico
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDailyRecords);
    await prefs.remove(_keyMonthlyStats);
  }
}
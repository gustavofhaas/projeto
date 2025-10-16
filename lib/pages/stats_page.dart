import 'package:flutter/material.dart';
import 'package:watertrack/services/history_service.dart';
import 'package:watertrack/widgets/water_consumption_chart.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _isLoading = true;
  Map<String, double> _weeklyStats = {};
  Map<String, double> _monthlyStats = {};
  List<WaterRecord> _todayRecords = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final weeklyStats = await HistoryService.getWeeklyStats();
      final monthlyStats = await HistoryService.getMonthlyStats();
      final todayRecords = await HistoryService.getTodayRecords();

      setState(() {
        _weeklyStats = weeklyStats;
        _monthlyStats = monthlyStats;
        _todayRecords = todayRecords;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final todayTotal = _todayRecords.fold(
      0.0,
      (sum, record) => sum + record.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoje',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total consumido: ${todayTotal.toStringAsFixed(1)}L',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Registros:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ..._todayRecords.map((record) {
                        final time = TimeOfDay.fromDateTime(record.timestamp);
                        return ListTile(
                          leading: const Icon(Icons.water_drop),
                          title: Text('${record.amount}L'),
                          subtitle: Text('${time.hour}:${time.minute}'),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            if (_weeklyStats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: WaterConsumptionChart(
                    data: _weeklyStats,
                    title: 'Consumo Semanal',
                  ),
                ),
              ),
            if (_monthlyStats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: WaterConsumptionChart(
                    data: _monthlyStats,
                    title: 'Consumo Mensal',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
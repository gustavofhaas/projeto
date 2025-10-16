import 'package:flutter/material.dart';
import 'package:watertrack/services/prefs_service.dart';
import 'package:watertrack/services/notification_service.dart';
import 'package:watertrack/locator.dart';
import 'package:watertrack/services/history_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _dailyGoal = 2.0;
  double _progress = 0.0;
  bool _isLoading = true;
  double _tempProgress = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await locator<NotificationService>().initialize();
    final hasPermission = await locator<NotificationService>().requestPermission();
    if (hasPermission) {
      final startTime = locator<PrefsService>().getFirstReminderTime();
      final endTime = locator<PrefsService>().getLastReminderTime();
      final interval = locator<PrefsService>().getReminderInterval();

      if (startTime != null && endTime != null && interval != null) {
        await locator<NotificationService>().scheduleReminders(
          startTime: startTime,
          endTime: endTime,
          intervalMinutes: interval,
        );
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dailyGoal = locator<PrefsService>().getDailyGoal();
      final progress = locator<PrefsService>().getDailyProgress();
      setState(() {
        _dailyGoal = dailyGoal;
        _progress = progress;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addWater(double amount) async {
    final newProgress = _progress + amount;
    await locator<PrefsService>().setDailyProgress(newProgress);
    await HistoryService.addRecord(amount);
    setState(() => _progress = newProgress);
  }

  void _openStats() {
    Navigator.pushNamed(context, '/stats');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('WaterTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: _openStats,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await locator<NotificationService>().requestPermission();
          if (!result) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permissão de notificação necessária'),
              ),
            );
            return;
          }
          
          if (!mounted) return;
          Navigator.pushNamed(context, '/onboarding');
        },
        child: const Icon(Icons.notifications),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _isDragging = true;
                        _tempProgress = _progress;
                      });
                    },
                    onPanUpdate: (details) {
                      if (!_isDragging) return;
                      
                      // Convertendo o movimento vertical em litros (50px = 0.1L)
                      final delta = -details.delta.dy / 500; // Mais sensível
                      final newProgress = (_progress + delta).clamp(0.0, _dailyGoal);
                      
                      // Arredonda para múltiplos de 0.1L para melhor feedback
                      final roundedProgress = (newProgress * 10).round() / 10;
                      
                      setState(() {
                        _tempProgress = roundedProgress;
                      });
                    },
                    onPanEnd: (details) {
                      if (!_isDragging) return;
                      setState(() {
                        _isDragging = false;
                        _addWater(_tempProgress - _progress);
                      });
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          width: 15,
                        ),
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: (_isDragging ? _tempProgress : _progress) / _dailyGoal,
                                strokeWidth: 15,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Indicador de litros durante o arraste
                                if (_isDragging) ...[
                                  const Icon(Icons.arrow_drop_up, size: 36),
                                  const SizedBox(height: 4),
                                ],
                                // Quantidade atual
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${(_isDragging ? _tempProgress : _progress).toStringAsFixed(1)}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'L',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Meta diária
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Meta: ',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      '${_dailyGoal}L',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isDragging) ...[
                                  const SizedBox(height: 8),
                                  // Diferença durante o arraste
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (_tempProgress - _progress) >= 0 
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          (_tempProgress - _progress) >= 0 
                                            ? Icons.add 
                                            : Icons.remove,
                                          size: 16,
                                          color: (_tempProgress - _progress) >= 0 
                                            ? Colors.green 
                                            : Colors.red,
                                        ),
                                        Text(
                                          '${(_tempProgress - _progress).abs().toStringAsFixed(1)}L',
                                          style: TextStyle(
                                            color: (_tempProgress - _progress) >= 0 
                                              ? Colors.green 
                                              : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AddWaterButton(
                  amount: 0.2,
                  onPressed: () => _addWater(0.2),
                ),
                _AddWaterButton(
                  amount: 0.3,
                  onPressed: () => _addWater(0.3),
                ),
                _AddWaterButton(
                  amount: 0.5,
                  onPressed: () => _addWater(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddWaterButton extends StatelessWidget {
  final double amount;
  final VoidCallback onPressed;

  const _AddWaterButton({
    required this.amount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
      ),
      child: Text('${amount}L'),
    );
  }
}
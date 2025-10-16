import 'package:flutter/material.dart';
import 'package:watertrack/services/notification_service.dart';
import 'package:watertrack/services/prefs_service.dart';
import 'package:watertrack/locator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  double _dailyGoal = 2.0;
  TimeOfDay _firstReminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _lastReminderTime = const TimeOfDay(hour: 21, minute: 0);
  int _reminderInterval = 120;
  bool _isMinutesSelected = false;
  bool _isSaving = false;
  final TextEditingController _intervalController = TextEditingController(text: '2');

  @override
  void initState() {
    super.initState();
    _intervalController.addListener(_updateInterval);
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  void _updateInterval() {
    final value = double.tryParse(_intervalController.text);
    if (value != null) {
      setState(() {
        _reminderInterval = (_isMinutesSelected ? value : value * 60).round();
      });
    }
  }

  Future<void> _savePreferences() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final firstTime = _formatTimeOfDay(_firstReminderTime);
      final lastTime = _formatTimeOfDay(_lastReminderTime);

  // Salva as preferências
  await locator<PrefsService>().setDailyGoal(_dailyGoal);
  await locator<PrefsService>().setFirstReminderTime(firstTime);
  await locator<PrefsService>().setLastReminderTime(lastTime);
  await locator<PrefsService>().setReminderInterval(_reminderInterval);
  await locator<PrefsService>().setFirstRunComplete();

      // Agenda as notificações
      // await NotificationService.scheduleReminders(
      //   startTime: firstTime,
      //   endTime: lastTime,
      //   intervalMinutes: _reminderInterval,
      // );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações salvas com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );
        
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar configurações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectFirstTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _firstReminderTime,
    );
    if (picked != null && picked != _firstReminderTime) {
      setState(() {
        _firstReminderTime = picked;
      });
    }
  }

  Future<void> _selectLastTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _lastReminderTime,
    );
    if (picked != null && picked != _lastReminderTime) {
      setState(() {
        _lastReminderTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    Icons.water_drop,
                    size: 72,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bem-vindo ao WaterTrack!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vamos configurar suas preferências',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_drink, color: theme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Meta Diária de Água',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'L',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _dailyGoal,
                            min: 1.0,
                            max: 5.0,
                            divisions: 8,
                            label: ' L',
                            onChanged: (value) {
                              setState(() {
                                _dailyGoal = value;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('1.0L', style: theme.textTheme.bodySmall),
                              Text('5.0L', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notifications_active, color: theme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Configurar Lembretes',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text('Horário Inicial:', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _selectFirstTime,
                            icon: const Icon(Icons.access_time),
                            label: Text(_formatTimeOfDay(_firstReminderTime)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Horário Final:', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _selectLastTime,
                            icon: const Icon(Icons.access_time),
                            label: Text(_formatTimeOfDay(_lastReminderTime)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Intervalo:', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _intervalController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: _isMinutesSelected ? 'Minutos' : 'Horas',
                                    hintText: _isMinutesSelected ? '30, 45, 60...' : '1, 1.5, 2...',
                                    prefixIcon: Icon(Icons.timer, color: theme.primaryColor),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira um valor';
                                    }
                                    final number = double.tryParse(value);
                                    if (number == null || number <= 0) {
                                      return 'Digite um número válido';
                                    }
                                    final minutes = _isMinutesSelected ? number : number * 60;
                                    if (minutes < 15) {
                                      return 'Mínimo de 15 minutos';
                                    }
                                    if (minutes > 240) {
                                      return 'Máximo de 4 horas';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.primaryColor),
                                ),
                                child: ToggleButtons(
                                  borderRadius: BorderRadius.circular(8),
                                  onPressed: (int index) {
                                    setState(() {
                                      _isMinutesSelected = index == 0;
                                      final currentValue = double.tryParse(_intervalController.text);
                                      if (currentValue != null) {
                                        if (index == 0) {
                                          _intervalController.text = (currentValue * 60).round().toString();
                                        } else {
                                          _intervalController.text = (currentValue / 60).toStringAsFixed(1);
                                        }
                                      }
                                    });
                                  },
                                  isSelected: [_isMinutesSelected, !_isMinutesSelected],
                                  selectedColor: theme.colorScheme.onPrimary,
                                  fillColor: theme.primaryColor,
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 40,
                                  ),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('min'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('h'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _savePreferences,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleMedium,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Começar'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

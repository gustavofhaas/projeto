import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static const String _keySoundEnabled = 'notification_sound_enabled';
  static const String _keySelectedSound = 'notification_sound_selected';

  static const Map<String, String> availableSounds = {
    'default': 'notification_default.wav',
    'drop': 'water_drop.wav',
    'splash': 'water_splash.wav',
    'pour': 'water_pour.wav',
  };

  // Verifica se o som está habilitado
  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundEnabled) ?? true;
  }

  // Habilita/desabilita som das notificações
  static Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, enabled);
  }

  // Obtém o som selecionado
  static Future<String> getSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedSound) ?? 'default';
  }

  // Define o som selecionado
  static Future<void> setSelectedSound(String soundKey) async {
    if (!availableSounds.containsKey(soundKey)) {
      throw ArgumentError('Som não encontrado: $soundKey');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedSound, soundKey);
  }

  // Obtém o caminho do arquivo de som atual
  static Future<String> getCurrentSoundPath() async {
    final soundKey = await getSelectedSound();
    return availableSounds[soundKey] ?? availableSounds['default']!;
  }
}
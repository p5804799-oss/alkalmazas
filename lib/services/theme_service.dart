import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreset {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color card;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.card,
  });
}

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const List<ThemePreset> presets = [
    ThemePreset(
      id: 'cyber_green',
      name: 'Cyber Neon Green',
      primary: Color(0xFF00E676),
      secondary: Color(0xFF00B0FF),
      background: Color(0xFF07101B),
      card: Color(0xFF101B2B),
    ),
    ThemePreset(
      id: 'blood_orange',
      name: 'Blood Orange',
      primary: Color(0xFFFF3D00),
      secondary: Color(0xFFFFEA00),
      background: Color(0xFF120A07),
      card: Color(0xFF22130F),
    ),
    ThemePreset(
      id: 'royal_purple',
      name: 'Royal Purple',
      primary: Color(0xFFD500F9),
      secondary: Color(0xFF00E5FF),
      background: Color(0xFF0D0714),
      card: Color(0xFF1A102B),
    ),
  ];

  String _activePresetId = 'cyber_green';
  Color _primaryColor = const Color(0xFF00E676);
  Color _secondaryColor = const Color(0xFF00B0FF);
  Color _backgroundColor = const Color(0xFF07101B);
  Color _cardColor = const Color(0xFF101B2B);

  String get activePresetId => _activePresetId;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get backgroundColor => _backgroundColor;
  Color get cardColor => _cardColor;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('theme_preset_id');
    if (savedId != null) {
      setPreset(savedId);
    }
  }

  Future<void> setPreset(String id) async {
    final preset = presets.firstWhere((p) => p.id == id, orElse: () => presets.first);
    _activePresetId = preset.id;
    _primaryColor = preset.primary;
    _secondaryColor = preset.secondary;
    _backgroundColor = preset.background;
    _cardColor = preset.card;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_preset_id', preset.id);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeOption {
  final String id;
  final String name;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color cardBg;

  const AppThemeOption({
    required this.id,
    required this.name,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.cardBg,
  });
}

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const List<AppThemeOption> presets = [
    AppThemeOption(
      id: 'default_cyan',
      name: 'Neon Cián & Pink (Alapértelmezett)',
      primaryAccent: Color(0xFF28D5CF),
      secondaryAccent: Color(0xFFFF356D),
      cardBg: Color(0xFF0D1825),
    ),
    AppThemeOption(
      id: 'cyberpunk_purple',
      name: 'Cyberpunk (Lila & Neonsárga)',
      primaryAccent: Color(0xFFA855F7),
      secondaryAccent: Color(0xFFEAB308),
      cardBg: Color(0xFF140F2D),
    ),
    AppThemeOption(
      id: 'crimson_beast',
      name: 'Vérvörös Beast (Piros & Narancs)',
      primaryAccent: Color(0xFFFF334B),
      secondaryAccent: Color(0xFFFF8A00),
      cardBg: Color(0xFF1F0E12),
    ),
    AppThemeOption(
      id: 'emerald_gold',
      name: 'Emerald & Arany (Luxus Zöld)',
      primaryAccent: Color(0xFF10B981),
      secondaryAccent: Color(0xFFFBBF24),
      cardBg: Color(0xFF061A14),
    ),
    AppThemeOption(
      id: 'monochrome_dark',
      name: 'Ultra Dark (Minimal Szürke)',
      primaryAccent: Color(0xFFE2E8F0),
      secondaryAccent: Color(0xFF64748B),
      cardBg: Color(0xFF121820),
    ),
  ];

  Color primaryColor = const Color(0xFF28D5CF);
  Color secondaryColor = const Color(0xFFFF356D);
  Color cardColor = const Color(0xFF0D1825);
  String activePresetId = 'default_cyan';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    activePresetId = prefs.getString('app_theme_preset') ?? 'default_cyan';
    
    final matching = presets.firstWhere(
      (p) => p.id == activePresetId,
      orElse: () => presets.first,
    );
    
    primaryColor = matching.primaryAccent;
    secondaryColor = matching.secondaryAccent;
    cardColor = matching.cardBg;
    notifyListeners();
  }

  Future<void> setPreset(AppThemeOption preset) async {
    primaryColor = preset.primaryAccent;
    secondaryColor = preset.secondaryAccent;
    cardColor = preset.cardBg;
    activePresetId = preset.id;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_preset', preset.id);
    notifyListeners();
  }
}

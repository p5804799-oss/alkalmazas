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

const List<ThemePreset> kAppThemePresets = [
  ThemePreset(
    id: 'cyberpunk_cyan',
    name: 'Cyberpunk Cián',
    primary: Color(0xFF28D5CF),
    secondary: Color(0xFFFF356D),
    background: Color(0xFF07101B),
    card: Color(0xFF0D1825),
  ),
  ThemePreset(
    id: 'deep_amethyst',
    name: 'Mély Ametiszt',
    primary: Color(0xFFB347EB),
    secondary: Color(0xFF00FFC2),
    background: Color(0xFF100720),
    card: Color(0xFF190D32),
  ),
  ThemePreset(
    id: 'emerald_matrix',
    name: 'Smaragd Mátrix',
    primary: Color(0xFF00E676),
    secondary: Color(0xFFFFB300),
    background: Color(0xFF05170E),
    card: Color(0xFF0B2618),
  ),
  ThemePreset(
    id: 'magma_blood',
    name: 'Vulkán Vörös',
    primary: Color(0xFFFF3D00),
    secondary: Color(0xFFFFD600),
    background: Color(0xFF1A0808),
    card: Color(0xFF2B0F0F),
  ),
  ThemePreset(
    id: 'midnight_oled',
    name: 'Éjfekete OLED',
    primary: Color(0xFF00B0FF),
    secondary: Color(0xFFFF4081),
    background: Color(0xFF000000),
    card: Color(0xFF121212),
  ),
];

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static List<ThemePreset> get presets => kAppThemePresets;

  String _currentThemeId = 'cyberpunk_cyan';

  String get activePresetId => _currentThemeId;
  String get currentThemeId => _currentThemeId;
  Color get primaryColor => _findTheme(_currentThemeId).primary;
  Color get secondaryColor => _findTheme(_currentThemeId).secondary;
  Color get backgroundColor => _findTheme(_currentThemeId).background;
  Color get cardColor => _findTheme(_currentThemeId).card;

  ThemePreset _findTheme(String id) {
    return kAppThemePresets.firstWhere(
      (t) => t.id == id,
      orElse: () => kAppThemePresets.first,
    );
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentThemeId = prefs.getString('app_theme_id') ?? 'cyberpunk_cyan';
    notifyListeners();
  }

  Future<void> setPreset(ThemePreset preset) async {
    await setTheme(preset.id);
  }

  Future<void> setTheme(String id) async {
    _currentThemeId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_id', id);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  Color _primaryColor = const Color(0xFF00E676);
  Color _secondaryColor = const Color(0xFF00B0FF);
  Color _backgroundColor = const Color(0xFF07101B);
  Color _cardColor = const Color(0xFF101B2B);

  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get backgroundColor => _backgroundColor;
  Color get cardColor => _cardColor;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final pHex = prefs.getInt('theme_primary');
    if (pHex != null) _primaryColor = Color(pHex);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_primary', color.value);
    notifyListeners();
  }
}

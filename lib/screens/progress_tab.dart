import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  final ThemeService _theme = ThemeService();
  double _currentWeight = 78.5;
  double _targetWeight = 75.0;
  List<double> _weightHistory = [81.0, 80.2, 79.4, 78.5];

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentWeight = prefs.getDouble('user_current_weight') ?? 78.5;
      _targetWeight = prefs.getDouble('user_target_weight') ?? 75.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: _theme.backgroundColor,
            title: const Text('Dagi app • Fejlődés & Grafikok', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SÚLYCÉL HALADÁS', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jelenlegi: $_currentWeight kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Cél: $_targetWeight kg', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: ((85.0 - _currentWeight) / (85.0 - _targetWeight)).clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFF1F2F42),
                      color: _theme.primaryColor,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('HETI SÚLYVÁLTOZÁS TREND (GRAFIKON)', style: TextStyle(color: Color(0xFF91A2B5), fontWeight: FontWeight.w900, fontSize: 12)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _weightHistory.map((w) {
                          final heightFactor = ((w - 70) / 15).clamp(0.2, 1.0);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('$w kg', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Container(
                                width: 32,
                                height: heightFactor * 80,
                                decoration: BoxDecoration(
                                  color: _theme.primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text('Mérés', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 10)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

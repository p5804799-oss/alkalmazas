import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ThemeService _theme = ThemeService();
  int _stepGoal = 10000;
  double _currentWeight = 78.5;
  double _targetWeight = 75.0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stepGoal = prefs.getInt('user_step_goal') ?? 10000;
      _currentWeight = prefs.getDouble('user_current_weight') ?? 78.5;
      _targetWeight = prefs.getDouble('user_target_weight') ?? 75.0;
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_step_goal', _stepGoal);
    await prefs.setDouble('user_current_weight', _currentWeight);
    await prefs.setDouble('user_target_weight', _targetWeight);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Profil adatok sikeresen mentve! 🎯'), backgroundColor: _theme.primaryColor),
      );
    }
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
            title: const Text('Dagi app • Profil & Célok', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NAPI CÉLOK & PARAMÉTEREK', style: TextStyle(color: Color(0xFF91A2B5), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Napi Lépésszám Cél: $_stepGoal lépés', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Slider(
                        value: _stepGoal.toDouble(),
                        min: 3000,
                        max: 25000,
                        divisions: 44,
                        activeColor: _theme.primaryColor,
                        inactiveColor: const Color(0xFF26364A),
                        onChanged: (val) => setState(() => _stepGoal = val.toInt()),
                      ),
                      const SizedBox(height: 14),
                      Text('Aktuális Súly: $_currentWeight kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Slider(
                        value: _currentWeight,
                        min: 40.0,
                        max: 160.0,
                        divisions: 240,
                        activeColor: _theme.secondaryColor,
                        inactiveColor: const Color(0xFF26364A),
                        onChanged: (val) => setState(() => _currentWeight = double.parse(val.toStringAsFixed(1))),
                      ),
                      const SizedBox(height: 14),
                      Text('Cél Súly: $_targetWeight kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Slider(
                        value: _targetWeight,
                        min: 40.0,
                        max: 160.0,
                        divisions: 240,
                        activeColor: _theme.primaryColor,
                        inactiveColor: const Color(0xFF26364A),
                        onChanged: (val) => setState(() => _targetWeight = double.parse(val.toStringAsFixed(1))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: _saveProfileData,
                    child: const Text('VÁLTOZÁSOK MENTÉSE 💾', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

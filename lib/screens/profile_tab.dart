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
  bool _onlineSyncEnabled = true;
  String _userHandle = 'DagiGymBro';

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
      _onlineSyncEnabled = prefs.getBool('user_online_sync') ?? true;
      _userHandle = prefs.getString('user_handle') ?? 'DagiGymBro';
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_step_goal', _stepGoal);
    await prefs.setDouble('user_current_weight', _currentWeight);
    await prefs.setDouble('user_target_weight', _targetWeight);
    await prefs.setBool('user_online_sync', _onlineSyncEnabled);
    await prefs.setString('user_handle', _userHandle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Profil és online fiók adatok mentve! ☁️💪'), backgroundColor: _theme.primaryColor),
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
            title: const Text('Dagi app • Profil & Online Fiók', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _theme.primaryColor.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: _theme.primaryColor.withValues(alpha: 0.2),
                        child: Icon(Icons.cloud_sync_rounded, color: _theme.primaryColor, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_userHandle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(_onlineSyncEnabled ? 'Online szinkronizáció: AKTÍV 🟢' : 'Offline mód 🔴', style: TextStyle(color: _onlineSyncEnabled ? _theme.primaryColor : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('FIÓK & ONLINE BEÁLLÍTÁSOK', style: TextStyle(color: Color(0xFF91A2B5), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Valós idejű online szinkronizáció', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Edzések és meghívók küldése a barátoknak', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                        value: _onlineSyncEnabled,
                        activeColor: _theme.primaryColor,
                        onChanged: (val) => setState(() => _onlineSyncEnabled = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('TESTCÉLOK & PARAMÉTEREK', style: TextStyle(color: Color(0xFF91A2B5), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                    child: const Text('MINDEN VÁLTOZÁS MENTÉSE 💾', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900)),
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

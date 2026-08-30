import 'dart:convert';
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
  String _username = 'Peti';
  String _userTag = '#PETI_8472';
  double _currentWeight = 85.0;
  double _targetWeight = 80.0;
  int _heightCm = 180;
  int _age = 25;
  String _gender = 'Férfi';
  String _activityLevel = 'Mérsékelten aktív (3-5 edzés/hét)';

  // Aktivitás adatok (Víz + Lépések)
  int _waterMl = 0;
  final int _waterGoalMl = 3000;
  int _steps = 0;
  final int _stepGoal = 10000;

  bool _shareWeight = true;
  bool _shareMeals = true;
  bool _shareWorkouts = true;

  int _calculatedTdee = 2550;
  int _todayConsumedCalories = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileAndActivity();
  }

  Future<void> _loadProfileAndActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final rawMeals = prefs.getString('daily_meals_$dateKey');
    int consumed = 0;
    if (rawMeals != null && rawMeals.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(rawMeals);
      for (var m in decoded) {
        consumed += (m['calories'] as num?)?.toInt() ?? 0;
      }
    }

    setState(() {
      _username = prefs.getString('user_profile_name') ?? 'Peti';
      _userTag = prefs.getString('user_profile_tag') ?? '#PETI_8472';
      _currentWeight = prefs.getDouble('user_current_weight') ?? 85.0;
      _targetWeight = prefs.getDouble('user_target_weight') ?? 80.0;
      _heightCm = prefs.getInt('user_height_cm') ?? 180;
      _age = prefs.getInt('user_age') ?? 25;
      _gender = prefs.getString('user_gender') ?? 'Férfi';
      _activityLevel = prefs.getString('user_activity_level') ?? 'Mérsékelten aktív (3-5 edzés/hét)';

      _waterMl = prefs.getInt('daily_water_$dateKey') ?? 1750;
      _steps = prefs.getInt('daily_steps_$dateKey') ?? 6420;

      _shareWeight = prefs.getBool('privacy_share_weight') ?? true;
      _shareMeals = prefs.getBool('privacy_share_meals') ?? true;
      _shareWorkouts = prefs.getBool('privacy_share_workouts') ?? true;

      _todayConsumedCalories = consumed;
      _calculateTdee();
      _isLoading = false;
    });
  }

  void _calculateTdee() {
    double bmr;
    if (_gender == 'Férfi') {
      bmr = (10 * _currentWeight) + (6.25 * _heightCm) - (5 * _age) + 5;
    } else {
      bmr = (10 * _currentWeight) + (6.25 * _heightCm) - (5 * _age) - 161;
    }

    double multiplier = 1.2;
    if (_activityLevel.contains('Könnyű')) multiplier = 1.375;
    if (_activityLevel.contains('Mérsékelten')) multiplier = 1.55;
    if (_activityLevel.contains('Nagyon')) multiplier = 1.725;

    _calculatedTdee = (bmr * multiplier).round();
  }

  // Becsült elégetett kalória (TDEE + Lépések)
  int get _estimatedBurnedTotal {
    final stepCalories = (_steps * 0.04).round(); // ~40 kcal / 1000 lépés
    return _calculatedTdee + stepCalories;
  }

  int get _calorieDeficit => _estimatedBurnedTotal - _todayConsumedCalories;

  Future<void> _addWater(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    setState(() {
      _waterMl = (_waterMl + amount).clamp(0, 8000);
    });
    await prefs.setInt('daily_water_$dateKey', _waterMl);
  }

  Future<void> _saveProfile() async {
    _calculateTdee();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile_name', _username);
    await prefs.setString('user_profile_tag', _userTag);
    await prefs.setDouble('user_current_weight', _currentWeight);
    await prefs.setDouble('user_target_weight', _targetWeight);
    await prefs.setInt('user_height_cm', _heightCm);
    await prefs.setInt('user_age', _age);
    await prefs.setString('user_gender', _gender);
    await prefs.setString('user_activity_level', _activityLevel);
    await prefs.setInt('daily_target_calories', _calculatedTdee);

    await prefs.setBool('privacy_share_weight', _shareWeight);
    await prefs.setBool('privacy_share_meals', _shareMeals);
    await prefs.setBool('privacy_share_workouts', _shareWorkouts);

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Profil és kalóriacél frissítve!'), backgroundColor: _theme.primaryColor),
      );
    }
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _username);
    final weightCtrl = TextEditingController(text: _currentWeight.toString());
    final targetWeightCtrl = TextEditingController(text: _targetWeight.toString());
    final heightCtrl = TextEditingController(text: _heightCm.toString());
    final ageCtrl = TextEditingController(text: _age.toString());
    String tempGender = _gender;
    String tempActivity = _activityLevel;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: _theme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF26364A))),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profil Beállítások', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Felhasználónév',
                    labelStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 12),
                    filled: true,
                    fillColor: _theme.cardColor,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildNumField(weightCtrl, 'Súly (kg)')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumField(targetWeightCtrl, 'Célsúly (kg)')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildNumField(heightCtrl, 'Magasság (cm)')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumField(ageCtrl, 'Életkor')),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Nem:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                Row(
                  children: ['Férfi', 'Nő'].map((g) {
                    final selected = g == tempGender;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setDialogState(() => tempGender = g),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? _theme.primaryColor.withValues(alpha: 0.2) : _theme.cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? _theme.primaryColor : const Color(0xFF26364A)),
                          ),
                          child: Center(child: Text(g, style: TextStyle(color: selected ? _theme.primaryColor : Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () {
                      setState(() {
                        _username = nameCtrl.text.trim().isEmpty ? _username : nameCtrl.text.trim();
                        _currentWeight = double.tryParse(weightCtrl.text) ?? _currentWeight;
                        _targetWeight = double.tryParse(targetWeightCtrl.text) ?? _targetWeight;
                        _heightCm = int.tryParse(heightCtrl.text) ?? _heightCm;
                        _age = int.tryParse(ageCtrl.text) ?? _age;
                        _gender = tempGender;
                        _activityLevel = tempActivity;
                      });
                      _saveProfile();
                      Navigator.pop(ctx);
                    },
                    child: const Text('MENTÉS', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 12),
        filled: true,
        fillColor: _theme.cardColor,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        if (_isLoading) {
          return Scaffold(backgroundColor: _theme.backgroundColor, body: Center(child: CircularProgressIndicator(color: _theme.primaryColor)));
        }

        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: _theme.backgroundColor,
            elevation: 0,
            title: const Text('Felhasználói Profil & Aktivitás', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            actions: [
              IconButton(icon: Icon(Icons.edit, color: _theme.primaryColor), onPressed: _showEditProfileDialog),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil Kártya
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [_theme.primaryColor, _theme.secondaryColor]),
                        ),
                        child: Center(
                          child: Text(_username.isNotEmpty ? _username[0].toUpperCase() : 'P', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF07101B))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 2),
                          Text(_userTag, style: TextStyle(color: _theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // KALÓRIADEFICIT & ÉGETÉS KÁRTYA
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Napi Becsült Kalória Egyenleg & Deficit ⚡', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDeficitItem('Összes égetés (kb.)', '$_estimatedBurnedTotal kcal', _theme.primaryColor),
                          _buildDeficitItem('Bevitt étel', '$_todayConsumedCalories kcal', const Color(0xFFFFB800)),
                          _buildDeficitItem('Deficit / Többlet', '${_calorieDeficit > 0 ? "-$_calorieDeficit" : "+${_calorieDeficit.abs()}"} kcal', _calorieDeficit >= 0 ? _theme.primaryColor : _theme.secondaryColor),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '* Alapanyagcsere (TDEE: $_calculatedTdee) + Lépésekből égetett (~${(_steps * 0.04).round()} kcal) alapján számolva.',
                        style: const TextStyle(color: Color(0xFF55687D), fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // AKTIVITÁS BEÉPÍTVE (Víz & Lépés)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Napi Vízbevitel 💧', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('$_waterMl / $_waterGoalMl ml', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_waterMl / _waterGoalMl).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: const Color(0xFF1B2A3D),
                          color: _theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildWaterBtn('+250 ml', () => _addWater(250)),
                          const SizedBox(width: 8),
                          _buildWaterBtn('+500 ml', () => _addWater(500)),
                          const SizedBox(width: 8),
                          _buildWaterBtn('Reset', () => _addWater(-_waterMl)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF1B2A3D)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Napi Lépések 🚶', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('$_steps / $_stepGoal lépés', style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Adatvédelem Barátlistához
                Container(
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeThumbColor: _theme.primaryColor,
                        title: const Text('Testsúly megosztása barátokkal', style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: _shareWeight,
                        onChanged: (val) {
                          setState(() => _shareWeight = val);
                          _saveProfile();
                        },
                      ),
                      const Divider(color: Color(0xFF1B2A3D), height: 1),
                      SwitchListTile(
                        activeThumbColor: _theme.primaryColor,
                        title: const Text('Ételek & Makrók láthatósága', style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: _shareMeals,
                        onChanged: (val) {
                          setState(() => _shareMeals = val);
                          _saveProfile();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeficitItem(String title, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }

  Widget _buildWaterBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFF1B2A3D), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF26364A))),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

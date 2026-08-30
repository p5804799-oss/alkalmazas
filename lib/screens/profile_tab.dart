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

  bool _shareWeight = true;
  bool _shareMeals = true;
  bool _shareWorkouts = true;

  int _calculatedTdee = 2550;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('user_profile_name') ?? 'Peti';
      _userTag = prefs.getString('user_profile_tag') ?? '#PETI_8472';
      _currentWeight = prefs.getDouble('user_current_weight') ?? 85.0;
      _targetWeight = prefs.getDouble('user_target_weight') ?? 80.0;
      _heightCm = prefs.getInt('user_height_cm') ?? 180;
      _age = prefs.getInt('user_age') ?? 25;
      _gender = prefs.getString('user_gender') ?? 'Férfi';
      _activityLevel = prefs.getString('user_activity_level') ?? 'Mérsékelten aktív (3-5 edzés/hét)';

      _shareWeight = prefs.getBool('privacy_share_weight') ?? true;
      _shareMeals = prefs.getBool('privacy_share_meals') ?? true;
      _shareWorkouts = prefs.getBool('privacy_share_workouts') ?? true;

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
        SnackBar(
          content: const Text('Profil és számított kalóriacél elmentve!'),
          backgroundColor: _theme.primaryColor,
        ),
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
          backgroundColor: const Color(0xFF07101B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF26364A)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profil & Kalóriakalkulátor',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                _buildField(nameCtrl, 'Becenév / Felhasználónév'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildField(weightCtrl, 'Súly (kg)', isNum: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField(targetWeightCtrl, 'Célsúly (kg)', isNum: true)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildField(heightCtrl, 'Magasság (cm)', isNum: true)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildField(ageCtrl, 'Életkor', isNum: true)),
                  ],
                ),
                const SizedBox(height: 12),
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
                            color: selected ? const Color(0xFF166864) : const Color(0xFF0D1825),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? _theme.primaryColor : const Color(0xFF26364A)),
                          ),
                          child: Center(
                            child: Text(g, style: TextStyle(color: selected ? _theme.primaryColor : Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Aktivitási szint:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1825),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tempActivity,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0D1825),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: const [
                        DropdownMenuItem(value: 'Ülőmunka (kevés mozgás)', child: Text('Ülőmunka (kevés mozgás)')),
                        DropdownMenuItem(value: 'Könnyű (1-3 edzés/hét)', child: Text('Könnyű (1-3 edzés/hét)')),
                        DropdownMenuItem(value: 'Mérsékelten aktív (3-5 edzés/hét)', child: Text('Mérsékelten aktív (3-5 edzés/hét)')),
                        DropdownMenuItem(value: 'Nagyon aktív (6-7 edzés/hét)', child: Text('Nagyon aktív (6-7 edzés/hét)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => tempActivity = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
                    child: const Text('SZÁMOLÁS & MENTÉS', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, {bool isNum = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF0D1825),
        isDense: true,
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
          return Scaffold(backgroundColor: const Color(0xFF07101B), body: Center(child: CircularProgressIndicator(color: _theme.primaryColor)));
        }

        return Scaffold(
          backgroundColor: const Color(0xFF07101B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF07101B),
            elevation: 0,
            title: const Text('Felhasználói Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: _theme.primaryColor),
                onPressed: _showEditProfileDialog,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1825),
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
                          child: Text(
                            _username.isNotEmpty ? _username[0].toUpperCase() : 'P',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF07101B)),
                          ),
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
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1825),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Számított Napi Kalóriaszükséglet (TDEE):', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('$_calculatedTdee kcal / nap', style: TextStyle(color: _theme.primaryColor, fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCol('Súly', '$_currentWeight kg'),
                          _buildInfoCol('Célsúly', '$_targetWeight kg'),
                          _buildInfoCol('Magasság', '$_heightCm cm'),
                          _buildInfoCol('Kor', '$_age év'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Adatvédelem & Megosztás Barátokkal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1825),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeThumbColor: _theme.primaryColor,
                        title: const Text('Testsúly & Diagram megosztása', style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text('A barátaid láthatják a testsúlyod alakulását', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                        value: _shareWeight,
                        onChanged: (val) {
                          setState(() => _shareWeight = val);
                          _saveProfile();
                        },
                      ),
                      const Divider(color: Color(0xFF1B2A3D), height: 1),
                      SwitchListTile(
                        activeThumbColor: _theme.primaryColor,
                        title: const Text('Napi étkezések & Makrók láthatósága', style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text('A barátaid láthatják, mit ettél a mai napon', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                        value: _shareMeals,
                        onChanged: (val) {
                          setState(() => _shareMeals = val);
                          _saveProfile();
                        },
                      ),
                      const Divider(color: Color(0xFF1B2A3D), height: 1),
                      SwitchListTile(
                        activeThumbColor: _theme.primaryColor,
                        title: const Text('Edzéstervek & Használt súlyok', style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text('A barátaid láthatják az elvégzett szériáidat', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                        value: _shareWorkouts,
                        onChanged: (val) {
                          setState(() => _shareWorkouts = val);
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

  Widget _buildInfoCol(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF55687D), fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

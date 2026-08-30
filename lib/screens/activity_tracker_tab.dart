import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyActivityData {
  final String dateKey;
  int waterMl;
  int steps;

  DailyActivityData({
    required this.dateKey,
    this.waterMl = 0,
    this.steps = 0,
  });

  Map<String, dynamic> toMap() => {
        'dateKey': dateKey,
        'waterMl': waterMl,
        'steps': steps,
      };

  factory DailyActivityData.fromMap(Map<String, dynamic> map) => DailyActivityData(
        dateKey: map['dateKey'] ?? '',
        waterMl: map['waterMl'] ?? 0,
        steps: map['steps'] ?? 0,
      );
}

class ActivityTrackerTab extends StatefulWidget {
  const ActivityTrackerTab({super.key});

  @override
  State<ActivityTrackerTab> createState() => _ActivityTrackerTabState();
}

class _ActivityTrackerTabState extends State<ActivityTrackerTab> {
  int _waterTargetMl = 3000;
  int _stepsTarget = 10000;

  int _currentWaterMl = 0;
  int _currentSteps = 0;
  bool _isLoading = true;

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  Future<void> _loadActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    _waterTargetMl = prefs.getInt('target_water_ml') ?? 3000;
    _stepsTarget = prefs.getInt('target_steps_count') ?? 10000;

    final String? rawData = prefs.getString('activity_log_$_todayKey');
    if (rawData != null && rawData.isNotEmpty) {
      final data = DailyActivityData.fromMap(jsonDecode(rawData));
      _currentWaterMl = data.waterMl;
      _currentSteps = data.steps;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('target_water_ml', _waterTargetMl);
    await prefs.setInt('target_steps_count', _stepsTarget);

    final data = DailyActivityData(
      dateKey: _todayKey,
      waterMl: _currentWaterMl,
      steps: _currentSteps,
    );
    await prefs.setString('activity_log_$_todayKey', jsonEncode(data.toMap()));
  }

  void _addWater(int amount) {
    setState(() {
      _currentWaterMl = (_currentWaterMl + amount).clamp(0, 10000);
    });
    _saveActivityData();
  }

  void _showSetStepsDialog() {
    final ctrl = TextEditingController(text: _currentSteps > 0 ? _currentSteps.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF07101B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF26364A)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mai Lépésszám Rögzítése',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Pl. 7500',
                  hintStyle: const TextStyle(color: Color(0xFF55687D)),
                  suffixText: 'lépés',
                  suffixStyle: const TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0xFF0D1825),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF26364A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF28D5CF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28D5CF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final val = int.tryParse(ctrl.text) ?? _currentSteps;
                    setState(() {
                      _currentSteps = val.clamp(0, 100000);
                    });
                    _saveActivityData();
                    Navigator.of(ctx, rootNavigator: true).pop();
                  },
                  child: const Text(
                    'MENTÉS',
                    style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTargetsDialog() {
    final waterCtrl = TextEditingController(text: _waterTargetMl.toString());
    final stepsCtrl = TextEditingController(text: _stepsTarget.toString());

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF07101B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF26364A)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Napi Célok Beállítása',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: waterCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Napi vízcél (ml)',
                  labelStyle: const TextStyle(color: Color(0xFF91A2B5)),
                  filled: true,
                  fillColor: const Color(0xFF0D1825),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF26364A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF28D5CF)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: stepsCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Napi lépéscél',
                  labelStyle: const TextStyle(color: Color(0xFF91A2B5)),
                  filled: true,
                  fillColor: const Color(0xFF0D1825),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF26364A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF28D5CF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF356D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final w = int.tryParse(waterCtrl.text) ?? _waterTargetMl;
                    final s = int.tryParse(stepsCtrl.text) ?? _stepsTarget;
                    setState(() {
                      _waterTargetMl = w > 0 ? w : 3000;
                      _stepsTarget = s > 0 ? s : 10000;
                    });
                    _saveActivityData();
                    Navigator.of(ctx, rootNavigator: true).pop();
                  },
                  child: const Text('CÉLOK MENTÉSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF07101B),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF28D5CF))),
      );
    }

    final double waterProgress = (_currentWaterMl / _waterTargetMl).clamp(0.0, 1.0);
    final double stepsProgress = (_currentSteps / _stepsTarget).clamp(0.0, 1.0);

    final double estimatedKm = (_currentSteps * 0.00075);
    final int estimatedBurnedKcal = (_currentSteps * 0.04).round();

    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B),
        elevation: 0,
        title: const Text(
          'Aktivitás & Folyadék',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1825),
                border: Border.all(color: const Color(0xFF26364A)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded, color: Color(0xFF28D5CF), size: 20),
            ),
            onPressed: _showEditTargetsDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Vízbevitel Kártya
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16344A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.water_drop_rounded, color: Color(0xFF28D5CF), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Vízbevitel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Cél: $_waterTargetMl ml', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '$_currentWaterMl ml',
                        style: const TextStyle(color: Color(0xFF28D5CF), fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: waterProgress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFF1B2A3D),
                      color: const Color(0xFF28D5CF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(waterProgress * 100).toInt()}% teljesítve',
                      style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildWaterQuickBtn('+250 ml', 250, Icons.local_cafe_outlined),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildWaterQuickBtn('+500 ml', 500, Icons.sports_bar_outlined),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildWaterQuickBtn('+1000 ml', 1000, Icons.water_drop_outlined),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2A3D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.refresh, color: Color(0xFFFF356D), size: 18),
                        onPressed: () {
                          setState(() => _currentWaterMl = 0);
                          _saveActivityData();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Lépésszám & Aktivitás Kártya
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1825),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF26364A)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF382232),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.directions_walk_rounded, color: Color(0xFFFF356D), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Napi Lépések', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Cél: $_stepsTarget lépés', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF356D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: _showSetStepsDialog,
                        child: const Text('Rögzítés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: CircularProgressIndicator(
                          value: stepsProgress,
                          strokeWidth: 10,
                          backgroundColor: const Color(0xFF1B2A3D),
                          color: const Color(0xFFFF356D),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$_currentSteps',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                          const Text('lépés', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat('Megtett táv', '${estimatedKm.toStringAsFixed(2)} km', Icons.straighten_rounded),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMiniStat('Becsült kalória', '$estimatedBurnedKcal kcal', Icons.local_fire_department_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterQuickBtn(String title, int amount, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B2A3D),
        foregroundColor: const Color(0xFF28D5CF),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 15),
      label: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      onPressed: () => _addWater(amount),
    );
  }

  Widget _buildMiniStat(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF07101B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B2A3D)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFB800), size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 10)),
              Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

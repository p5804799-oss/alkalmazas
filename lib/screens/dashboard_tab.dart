import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_dialog.dart';

class MealItem {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  MealItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory MealItem.fromMap(Map<String, dynamic> map) => MealItem(
        id: map['id'],
        name: map['name'],
        calories: map['calories'],
        protein: (map['protein'] as num).toDouble(),
        carbs: (map['carbs'] as num).toDouble(),
        fat: (map['fat'] as num).toDouble(),
      );
}

class WorkoutSet {
  final String id;
  final String exerciseName;
  final double weightKg;
  final int reps;

  WorkoutSet({
    required this.id,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'exerciseName': exerciseName,
        'weightKg': weightKg,
        'reps': reps,
      };

  factory WorkoutSet.fromMap(Map<String, dynamic> map) => WorkoutSet(
        id: map['id'],
        exerciseName: map['exerciseName'],
        weightKg: (map['weightKg'] as num).toDouble(),
        reps: map['reps'],
      );
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final int _targetCalories = 2400;
  final double _targetProtein = 160.0;
  final double _targetCarbs = 250.0;
  final double _targetFat = 70.0;

  List<MealItem> _meals = [];
  List<WorkoutSet> _workouts = [];

  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isRestTimerActive = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? mealData = prefs.getString('daily_meals_data');
    final String? workoutData = prefs.getString('daily_workouts_data');

    setState(() {
      if (mealData != null && mealData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(mealData);
        _meals = decoded.map((m) => MealItem.fromMap(m)).toList();
      }
      if (workoutData != null && workoutData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(workoutData);
        _workouts = decoded.map((w) => WorkoutSet.fromMap(w)).toList();
      }
    });
  }

  Future<void> _saveDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'daily_meals_data', jsonEncode(_meals.map((m) => m.toMap()).toList()));
    await prefs.setString('daily_workouts_data',
        jsonEncode(_workouts.map((w) => w.toMap()).toList()));
  }

  int get _consumedCalories =>
      _meals.fold(0, (sum, item) => sum + item.calories);
  double get _consumedProtein =>
      _meals.fold(0.0, (sum, item) => sum + item.protein);
  double get _consumedCarbs =>
      _meals.fold(0.0, (sum, item) => sum + item.carbs);
  double get _consumedFat => _meals.fold(0.0, (sum, item) => sum + item.fat);

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = seconds;
      _isRestTimerActive = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 0) {
        setState(() {
          _restSecondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRestTimerActive = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pihenőidő letelt! Következő széria! 💪'),
              backgroundColor: Color(0xFF28D5CF),
            ),
          );
        }
      }
    });
  }

  void _showAddMealDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final pCtrl = TextEditingController();
    final cCtrl = TextEditingController();
    final fCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
                'Étel Rögzítése',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 14),
              _buildInputField(nameCtrl, 'Étel neve (pl. Csirkemell rizzsel)'),
              const SizedBox(height: 10),
              _buildInputField(calCtrl, 'Kalória (kcal)', isNumber: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child:
                          _buildInputField(pCtrl, 'Fehérje (g)', isNumber: true)),
                  const SizedBox(width: 8),
                  Expanded(
                      child:
                          _buildInputField(cCtrl, 'Szénhidrát (g)', isNumber: true)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildInputField(fCtrl, 'Zsír (g)', isNumber: true)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28D5CF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final cal = int.tryParse(calCtrl.text) ?? 0;
                    final p = double.tryParse(pCtrl.text) ?? 0.0;
                    final c = double.tryParse(cCtrl.text) ?? 0.0;
                    final f = double.tryParse(fCtrl.text) ?? 0.0;

                    if (name.isEmpty || cal <= 0) return;

                    setState(() {
                      _meals.insert(
                        0,
                        MealItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          calories: cal,
                          protein: p,
                          carbs: c,
                          fat: f,
                        ),
                      );
                    });
                    _saveDashboardData();
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'HOZZÁADÁS',
                    style: TextStyle(
                        color: Color(0xFF07101B),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddWorkoutDialog() {
    final nameCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final repsCtrl = TextEditingController();

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
                'Edzésszéria Rögzítése',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 14),
              _buildInputField(nameCtrl, 'Gyakorlat (pl. Fekvenyomás)'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _buildInputField(weightCtrl, 'Súly (kg)',
                          isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildInputField(repsCtrl, 'Ismétlés',
                          isNumber: true)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF356D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final weight =
                        double.tryParse(weightCtrl.text.replaceAll(',', '.')) ??
                            0.0;
                    final reps = int.tryParse(repsCtrl.text) ?? 0;

                    if (name.isEmpty || reps <= 0) return;

                    setState(() {
                      _workouts.insert(
                        0,
                        WorkoutSet(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          exerciseName: name,
                          weightKg: weight,
                          reps: reps,
                        ),
                      );
                    });
                    _saveDashboardData();
                    Navigator.pop(ctx);
                    _startRestTimer(90);
                  },
                  child: const Text(
                    'SZÉRIA MENTÉSE & PIHENŐ INDÍTÁSA (90s)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType:
          isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0D1825),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF26364A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF28D5CF)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingCalories = _targetCalories - _consumedCalories;
    final calorieProgress =
        (_consumedCalories / _targetCalories).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B),
        elevation: 0,
        title: const Text(
          'Dagi app Vezérlőpult',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1825),
                border: Border.all(color: const Color(0xFF26364A)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings_outlined,
                  size: 20, color: Color(0xFF28D5CF)),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) => const SettingsDialog(),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pihenőidő lebegő csík (ha aktív)
            if (_isRestTimerActive)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF356D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFF356D)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Color(0xFFFF356D)),
                        const SizedBox(width: 10),
                        Text(
                          'Pihenőidő hátra: $_restSecondsRemaining mp',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _startRestTimer(0),
                      child: const Text('Kész',
                          style: TextStyle(
                              color: Color(0xFFFF356D),
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),

            // Kalória és Makró Összegző Kártya
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Napi Kalóriakeret',
                              style: TextStyle(
                                  color: Color(0xFF91A2B5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '$remainingCalories kcal',
                            style: TextStyle(
                              color: remainingCalories >= 0
                                  ? const Color(0xFF28D5CF)
                                  : const Color(0xFFFF356D),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Elfogyasztva: $_consumedCalories / $_targetCalories kcal',
                            style: const TextStyle(
                                color: Color(0xFF55687D), fontSize: 12),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 68,
                            height: 68,
                            child: CircularProgressIndicator(
                              value: calorieProgress,
                              strokeWidth: 7,
                              backgroundColor: const Color(0xFF1B2A3D),
                              color: const Color(0xFF28D5CF),
                            ),
                          ),
                          Text(
                            '${(calorieProgress * 100).toInt()}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF1B2A3D)),
                  const SizedBox(height: 12),
                  // Makró progress csíkok
                  _buildMacroRow('Fehérje', _consumedProtein, _targetProtein,
                      const Color(0xFF28D5CF)),
                  const SizedBox(height: 10),
                  _buildMacroRow('Szénhidrát', _consumedCarbs, _targetCarbs,
                      const Color(0xFFFFB800)),
                  const SizedBox(height: 10),
                  _buildMacroRow('Zsír', _consumedFat, _targetFat,
                      const Color(0xFFFF356D)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Napi Ételek Szekció
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mai Étkezések',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: Color(0xFF28D5CF), size: 28),
                  onPressed: _showAddMealDialog,
                ),
              ],
            ),
            if (_meals.isEmpty)
              _buildEmptyPlaceholder('Még nem rögzítettél ételt a mai napon.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _meals.length,
                itemBuilder: (ctx, i) {
                  final item = _meals[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1825),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF26364A)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              '${item.calories} kcal | F: ${item.protein}g Sz: ${item.carbs}g Zs: ${item.fat}g',
                              style: const TextStyle(
                                  color: Color(0xFF91A2B5), fontSize: 11),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFFFF356D), size: 18),
                          onPressed: () {
                            setState(() => _meals.removeAt(i));
                            _saveDashboardData();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Edzés Szekció
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mai Edzés & Szériák',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: Color(0xFFFF356D), size: 28),
                  onPressed: _showAddWorkoutDialog,
                ),
              ],
            ),
            if (_workouts.isEmpty)
              _buildEmptyPlaceholder('Még nincs rögzített edzésszéria ma.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workouts.length,
                itemBuilder: (ctx, i) {
                  final setItem = _workouts[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1825),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF26364A)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2A3D),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.fitness_center,
                                  color: Color(0xFFFF356D), size: 16),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(setItem.exerciseName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(
                                  '${setItem.weightKg} kg × ${setItem.reps} ismétlés',
                                  style: const TextStyle(
                                      color: Color(0xFF91A2B5), fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFFFF356D), size: 18),
                          onPressed: () {
                            setState(() => _workouts.removeAt(i));
                            _saveDashboardData();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(
      String label, double current, double max, Color activeColor) {
    final progress = (current / max).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
            Text('${current.toStringAsFixed(1)} / ${max.toInt()}g',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF1B2A3D),
            color: activeColor,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlaceholder(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1825),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B2A3D)),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(color: Color(0xFF55687D), fontSize: 13)),
      ),
    );
  }
}
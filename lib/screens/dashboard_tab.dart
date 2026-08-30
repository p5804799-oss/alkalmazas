import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_presets.dart';
import '../services/gemini_food_service.dart';
import 'dev_designer_sheet.dart';
import 'settings_dialog.dart';

class FoodTemplate {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  const FoodTemplate({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

const List<FoodTemplate> kCommonFoodDatabase = [
  FoodTemplate(name: 'Csirkemell filé (sült, 100g)', calories: 165, protein: 31.0, carbs: 0.0, fat: 3.6),
  FoodTemplate(name: 'Basmati rizs (főtt, 100g)', calories: 130, protein: 2.7, carbs: 28.0, fat: 0.3),
  FoodTemplate(name: 'Jázmin rizs (főtt, 100g)', calories: 130, protein: 2.4, carbs: 28.5, fat: 0.2),
  FoodTemplate(name: 'Zabpehely (100g)', calories: 375, protein: 13.5, carbs: 60.0, fat: 7.0),
  FoodTemplate(name: 'Tejsavó fehérje (1 adag, 30g)', calories: 120, protein: 24.0, carbs: 2.0, fat: 1.5),
  FoodTemplate(name: 'Egész tojás (1 db L-es, ~60g)', calories: 85, protein: 7.5, carbs: 0.5, fat: 6.0),
  FoodTemplate(name: 'Sovány túró (100g)', calories: 80, protein: 14.0, carbs: 3.8, fat: 0.5),
  FoodTemplate(name: 'Tonhalkonzerv sós lében (100g)', calories: 110, protein: 25.5, carbs: 0.0, fat: 1.0),
];

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

class PlannedExerciseItem {
  final String name;
  final int targetSets;
  final int targetReps;
  double lastWeight;
  int completedSets;

  PlannedExerciseItem({
    required this.name,
    required this.targetSets,
    required this.targetReps,
    this.lastWeight = 0.0,
    this.completedSets = 0,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'targetSets': targetSets,
        'targetReps': targetReps,
        'lastWeight': lastWeight,
        'completedSets': completedSets,
      };

  factory PlannedExerciseItem.fromMap(Map<String, dynamic> map) => PlannedExerciseItem(
        name: map['name'] ?? '',
        targetSets: map['targetSets'] ?? 3,
        targetReps: map['targetReps'] ?? 10,
        lastWeight: (map['lastWeight'] as num?)?.toDouble() ?? 0.0,
        completedSets: map['completedSets'] ?? 0,
      );
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int _targetCalories = 2400;
  final double _targetProtein = 160.0;
  final double _targetCarbs = 250.0;
  final double _targetFat = 70.0;

  String _workoutDayType = 'Mell - Tricepsz 💪';
  List<MealItem> _meals = [];
  List<PlannedExerciseItem> _todayExercises = [];

  final List<String> _workoutTypeOptions = [
    'Pihenőnap 😴',
    'Mell - Tricepsz 💪',
    'Hát - Bicepsz 🏋️',
    'Láb - Váll 🦵',
    'Kardió - Has 🏃',
    'Teljes Test (Full Body) 🔥',
    'Egyedi Edzés ⚡',
  ];

  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isRestTimerActive = false;
  int _devSecretClicks = 0;
  bool _isAnalyzingPhoto = false;

  final ImagePicker _picker = ImagePicker();

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

  void _onLogoTapped() {
    _devSecretClicks++;
    if (_devSecretClicks >= 5) {
      _devSecretClicks = 0;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => const DevDesignerSheet(),
      );
    }
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    _targetCalories = prefs.getInt('daily_target_calories') ?? 2400;
    final String? mealData = prefs.getString('daily_meals_data');
    final String? exerciseData = prefs.getString('daily_planned_exercises');
    final String? savedWorkoutType = prefs.getString('daily_workout_type');

    setState(() {
      if (savedWorkoutType != null) {
        _workoutDayType = savedWorkoutType;
      }
      if (mealData != null && mealData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(mealData);
        _meals = decoded.map((m) => MealItem.fromMap(m)).toList();
      }
      if (exerciseData != null && exerciseData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(exerciseData);
        _todayExercises = decoded.map((e) => PlannedExerciseItem.fromMap(e)).toList();
      } else {
        _applyWorkoutTemplate(_workoutDayType, saveImmediately: false);
      }
    });
  }

  Future<void> _saveDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daily_workout_type', _workoutDayType);
    await prefs.setString('daily_meals_data', jsonEncode(_meals.map((m) => m.toMap()).toList()));
    await prefs.setString('daily_planned_exercises', jsonEncode(_todayExercises.map((e) => e.toMap()).toList()));
  }

  Future<double> _getLastLoggedWeightForExercise(String exerciseName) async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString('exercise_progress_logs');
    if (rawData != null && rawData.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(rawData);
      final matching = decoded.where((e) => (e['exerciseName'] as String).toLowerCase() == exerciseName.toLowerCase()).toList();
      if (matching.isNotEmpty) {
        matching.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        return (matching.first['weightKg'] as num).toDouble();
      }
    }
    return 0.0;
  }

  Future<void> _applyWorkoutTemplate(String type, {bool saveImmediately = true}) async {
    if (type == 'Pihenőnap 😴') {
      _todayExercises = [];
    } else if (kWorkoutPlanPresets.containsKey(type)) {
      final presets = kWorkoutPlanPresets[type]!;
      final List<PlannedExerciseItem> loaded = [];
      for (final p in presets) {
        final lastW = await _getLastLoggedWeightForExercise(p.name);
        loaded.add(PlannedExerciseItem(
          name: p.name,
          targetSets: p.sets,
          targetReps: p.reps,
          lastWeight: lastW,
          completedSets: 0,
        ));
      }
      _todayExercises = loaded;
    }

    if (saveImmediately) {
      await _saveDashboardData();
    }
  }

  int get _consumedCalories => _meals.fold(0, (sum, item) => sum + item.calories);
  double get _consumedProtein => _meals.fold(0.0, (sum, item) => sum + item.protein);
  double get _consumedCarbs => _meals.fold(0.0, (sum, item) => sum + item.carbs);
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

  void _logExerciseSet(PlannedExerciseItem exercise) async {
    final weightCtrl = TextEditingController(
      text: exercise.lastWeight > 0 ? exercise.lastWeight.toString() : '',
    );
    final repsCtrl = TextEditingController(text: exercise.targetReps.toString());

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
              Text(
                exercise.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Előzőleg használt súly: ${exercise.lastWeight > 0 ? "${exercise.lastWeight} kg" : "Még nincs mentve"}',
                style: const TextStyle(color: Color(0xFF28D5CF), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Súly (kg)',
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
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: repsCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Ismétlés',
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
                  ),
                ],
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
                  onPressed: () async {
                    final w = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
                    final r = int.tryParse(repsCtrl.text) ?? exercise.targetReps;

                    if (w <= 0) return;

                    final prefs = await SharedPreferences.getInstance();
                    final String? rawLogs = prefs.getString('exercise_progress_logs');
                    List<dynamic> logs = rawLogs != null ? jsonDecode(rawLogs) : [];
                    logs.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'exerciseName': exercise.name,
                      'weightKg': w,
                      'reps': r,
                      'date': DateTime.now().toIso8601String(),
                    });
                    await prefs.setString('exercise_progress_logs', jsonEncode(logs));

                    setState(() {
                      exercise.lastWeight = w;
                      if (exercise.completedSets < exercise.targetSets) {
                        exercise.completedSets++;
                      }
                    });
                    _saveDashboardData();

                    Navigator.of(ctx, rootNavigator: true).pop();
                    _startRestTimer(90);
                  },
                  child: const Text(
                    'SZÉRIA KÉSZ & PIHENŐ INDÍTÁSA',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeWorkoutTypeDialog() {
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Válassz Edzéstervet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),
                ..._workoutTypeOptions.map((type) {
                  final isSelected = type == _workoutDayType;
                  return InkWell(
                    onTap: () async {
                      setState(() {
                        _workoutDayType = type;
                      });
                      await _applyWorkoutTemplate(type);
                      Navigator.of(ctx, rootNavigator: true).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF166864) : const Color(0xFF0D1825),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF28D5CF) : const Color(0xFF26364A),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF28D5CF) : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Color(0xFF28D5CF), size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMealDialog({RecognizedFoodResult? initialAiData}) {
    final nameCtrl = TextEditingController(text: initialAiData?.foodName ?? '');
    final calCtrl = TextEditingController(text: initialAiData != null ? initialAiData.calories.toString() : '');
    final pCtrl = TextEditingController(text: initialAiData != null ? initialAiData.protein.toString() : '');
    final cCtrl = TextEditingController(text: initialAiData != null ? initialAiData.carbs.toString() : '');
    final fCtrl = TextEditingController(text: initialAiData != null ? initialAiData.fat.toString() : '');

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(initialAiData != null ? 'AI Felismerés - Ellenőrzés' : 'Étel Rögzítése',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (initialAiData != null)
                    const Icon(Icons.auto_awesome, color: Color(0xFF28D5CF), size: 20),
                ],
              ),
              const SizedBox(height: 14),
              _buildInputField(nameCtrl, 'Étel neve (pl. Csirkemell rizzsel)'),
              const SizedBox(height: 10),
              _buildInputField(calCtrl, 'Kalória (kcal)', isNumber: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInputField(pCtrl, 'Fehérje (g)', isNumber: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInputField(cCtrl, 'Szénhidrát (g)', isNumber: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInputField(fCtrl, 'Zsír (g)', isNumber: true)),
                ],
              ),
              if (initialAiData != null && initialAiData.notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  initialAiData.notes,
                  style: const TextStyle(color: Color(0xFF28D5CF), fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
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
                    Navigator.of(ctx, rootNavigator: true).pop();
                  },
                  child: const Text('MENTÉS NAPI ÉTKEZÉSHEZ',
                      style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndAnalyzeFoodImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() => _isAnalyzingPhoto = true);

      final result = await GeminiFoodService.analyzeFoodImage(File(picked.path));

      setState(() => _isAnalyzingPhoto = false);

      _showAddMealDialog(initialAiData: result);
    } catch (e) {
      setState(() => _isAnalyzingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hiba a kép beolvasásakor: $e'), backgroundColor: const Color(0xFFFF356D)),
      );
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF07101B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI Étel Fotózás & Felismerés ✨',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF28D5CF)),
              title: const Text('Fotó készítése kamerával', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndAnalyzeFoodImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFFFF356D)),
              title: const Text('Kép kiválasztása galériából', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndAnalyzeFoodImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0D1825),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    final calorieProgress = (_consumedCalories / _targetCalories).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B),
        elevation: 0,
        title: GestureDetector(
          onTap: _onLogoTapped,
          child: const Text(
            'Dagi app Vezérlőpult',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
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
              child: const Icon(Icons.settings_outlined, size: 20, color: Color(0xFF28D5CF)),
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
            if (_isAnalyzingPhoto)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1825),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF28D5CF)),
                ),
                child: const Row(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF28D5CF)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Ételfelismerés folyamatban...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('Makrók és kalória kiszámítása a fotó alapján', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (_isRestTimerActive)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        const Icon(Icons.timer_outlined, color: Color(0xFFFF356D)),
                        const SizedBox(width: 10),
                        Text(
                          'Pihenőidő hátra: $_restSecondsRemaining mp',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _startRestTimer(0),
                      child: const Text('Kész',
                          style: TextStyle(color: Color(0xFFFF356D), fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1825),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF26364A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A3D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.event_note, color: Color(0xFF28D5CF), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mai edzésprogram:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                          Text(
                            _workoutDayType,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF28D5CF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: _showChangeWorkoutTypeDialog,
                    child: const Text('Váltás',
                        style: TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.bold, fontSize: 12)),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Napi Kalóriakeret',
                              style: TextStyle(color: Color(0xFF91A2B5), fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '$remainingCalories kcal',
                            style: TextStyle(
                              color: remainingCalories >= 0 ? const Color(0xFF28D5CF) : const Color(0xFFFF356D),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Elfogyasztva: $_consumedCalories / $_targetCalories kcal',
                            style: const TextStyle(color: Color(0xFF55687D), fontSize: 12),
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
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF1B2A3D)),
                  const SizedBox(height: 12),
                  _buildMacroRow('Fehérje', _consumedProtein, _targetProtein, const Color(0xFF28D5CF)),
                  const SizedBox(height: 10),
                  _buildMacroRow('Szénhidrát', _consumedCarbs, _targetCarbs, const Color(0xFFFFB800)),
                  const SizedBox(height: 10),
                  _buildMacroRow('Zsír', _consumedFat, _targetFat, const Color(0xFFFF356D)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mai Gyakorlatok & Szériák',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                Text('${_todayExercises.where((e) => e.completedSets >= e.targetSets).length}/${_todayExercises.length} kész',
                    style: const TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            if (_todayExercises.isEmpty)
              _buildEmptyPlaceholder(_workoutDayType == 'Pihenőnap 😴'
                  ? 'A mai nap a regenerációé! Pihenj és egyél eleget! 😴'
                  : 'Nincs betöltött gyakorlat. Válassz egy edzéstervet fent!')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _todayExercises.length,
                itemBuilder: (ctx, i) {
                  final ex = _todayExercises[i];
                  final isDone = ex.completedSets >= ex.targetSets;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFF102624) : const Color(0xFF0D1825),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDone ? const Color(0xFF28D5CF) : const Color(0xFF26364A),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Cél: ${ex.targetSets} × ${ex.targetReps} ism.',
                                    style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Előző: ${ex.lastWeight > 0 ? "${ex.lastWeight} kg" : "---"}',
                                    style: const TextStyle(
                                        color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDone ? const Color(0xFF28D5CF) : const Color(0xFFFF356D),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _logExerciseSet(ex),
                          child: Text(
                            isDone ? 'KÉSZ (${ex.completedSets}/${ex.targetSets})' : 'SZÉRIA (${ex.completedSets}/${ex.targetSets})',
                            style: TextStyle(
                              color: isDone ? const Color(0xFF07101B) : Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Napi Ételek Szekció AI Fotó gombbal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mai Étkezések',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A3D),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF28D5CF)),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF28D5CF), size: 18),
                      ),
                      onPressed: _showImageSourcePicker,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF28D5CF), size: 28),
                      onPressed: () => _showAddMealDialog(),
                    ),
                  ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              '${item.calories} kcal | F: ${item.protein}g Sz: ${item.carbs}g Zs: ${item.fat}g',
                              style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFFF356D), size: 18),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, double current, double max, Color activeColor) {
    final progress = (current / max).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
            Text('${current.toStringAsFixed(1)} / ${max.toInt()}g',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
        child: Text(text, style: const TextStyle(color: Color(0xFF55687D), fontSize: 13)),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemini_food_service.dart';
import '../services/theme_service.dart';
import 'dev_designer_sheet.dart';
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
  final ThemeService _theme = ThemeService();
  DateTime _selectedDate = DateTime.now();
  int _targetCalories = 2400;
  int _recommendedTdee = 2400;
  final double _targetProtein = 160.0;
  final double _targetCarbs = 250.0;
  final double _targetFat = 70.0;

  String _workoutDayType = 'Pihenőnap 😴';
  List<MealItem> _meals = [];
  List<PlannedExerciseItem> _todayExercises = [];

  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isRestTimerActive = false;
  int _devSecretClicks = 0;
  bool _isAnalyzingPhoto = false;

  final ImagePicker _picker = ImagePicker();

  String get _dateKeyFormatted =>
      "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String _formatHungarianDate(DateTime d) {
    if (_isToday) {
      return "Ma (${d.month.toString().padLeft(2, '0')}. ${d.day.toString().padLeft(2, '0')}.)";
    }
    const days = ['Hétfő', 'Kedd', 'Szerda', 'Csütörtök', 'Péntek', 'Szombat', 'Vasárnap'];
    final dayName = days[d.weekday - 1];
    return "${d.year}. ${d.month.toString().padLeft(2, '0')}. ${d.day.toString().padLeft(2, '0')}. ($dayName)";
  }

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
    _recommendedTdee = prefs.getInt('daily_target_calories') ?? 2400;
    _targetCalories = prefs.getInt('custom_daily_target_calories') ?? _recommendedTdee;

    final String dateKey = _dateKeyFormatted;
    final String? mealData = prefs.getString('daily_meals_$dateKey');
    final String? exerciseData = prefs.getString('daily_planned_exercises_$dateKey');
    final String? savedWorkoutType = prefs.getString('daily_workout_type_$dateKey');

    setState(() {
      _workoutDayType = savedWorkoutType ?? 'Pihenőnap 😴';
      if (mealData != null && mealData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(mealData);
        _meals = decoded.map((m) => MealItem.fromMap(m)).toList();
      } else {
        _meals = [];
      }

      if (exerciseData != null && exerciseData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(exerciseData);
        _todayExercises = decoded.map((e) => PlannedExerciseItem.fromMap(e)).toList();
      } else {
        _todayExercises = [];
      }
    });
  }

  Future<void> _saveDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final String dateKey = _dateKeyFormatted;
    await prefs.setString('daily_workout_type_$dateKey', _workoutDayType);
    await prefs.setString('daily_meals_$dateKey', jsonEncode(_meals.map((m) => m.toMap()).toList()));
    await prefs.setString('daily_planned_exercises_$dateKey', jsonEncode(_todayExercises.map((e) => e.toMap()).toList()));
  }

  void _changeDate(int offsetDays) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offsetDays));
    });
    _loadDashboardData();
  }

  Future<void> _selectCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _theme.primaryColor,
              onPrimary: const Color(0xFF07101B),
              surface: _theme.cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDashboardData();
    }
  }

  void _sendWorkoutInviteDialog() {
    if (_todayExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Nincs aktív edzésed a mai napra! Állíts össze egyet az Edzés fülön.'), backgroundColor: _theme.secondaryColor),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Közös Edzés Meghívó Küldése 👥', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text('Mai edzés: $_workoutDayType (${_todayExercises.length} gyakorlat)', style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 14),
            const Text('Válassz barátot, akit meghívsz edzőpartnernek:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
            const SizedBox(height: 10),
            ListTile(
              leading: CircleAvatar(backgroundColor: _theme.primaryColor, child: const Text('B', style: TextStyle(color: Color(0xFF07101B)))),
              title: const Text('Balázs (#BALAZS_9912)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: Icon(Icons.send_rounded, color: _theme.primaryColor),
              onTap: () async {
                Navigator.pop(ctx);
                final prefs = await SharedPreferences.getInstance();
                final raw = prefs.getString('shared_workout_invites_queue');
                List<dynamic> list = raw != null ? jsonDecode(raw) : [];
                list.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'fromUser': 'Peti',
                  'workoutTitle': _workoutDayType,
                  'exercises': _todayExercises.map((e) => {'name': e.name, 'targetSets': e.targetSets, 'targetReps': e.targetReps}).toList(),
                  'date': DateTime.now().toIso8601String(),
                });
                await prefs.setString('shared_workout_invites_queue', jsonEncode(list));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Közös edzés meghívó sikeresen elküldve Balázsnak! 🔥'), backgroundColor: _theme.primaryColor),
                  );
                }
              },
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: _theme.secondaryColor, child: const Text('G', style: TextStyle(color: Colors.white))),
              title: const Text('Gergő (#GERGO_4411)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: Icon(Icons.send_rounded, color: _theme.primaryColor),
              onTap: () async {
                Navigator.pop(ctx);
                final prefs = await SharedPreferences.getInstance();
                final raw = prefs.getString('shared_workout_invites_queue');
                List<dynamic> list = raw != null ? jsonDecode(raw) : [];
                list.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'fromUser': 'Peti',
                  'workoutTitle': _workoutDayType,
                  'exercises': _todayExercises.map((e) => {'name': e.name, 'targetSets': e.targetSets, 'targetReps': e.targetReps}).toList(),
                  'date': DateTime.now().toIso8601String(),
                });
                await prefs.setString('shared_workout_invites_queue', jsonEncode(list));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Közös edzés meghívó sikeresen elküldve Gergőnek! 🔥'), backgroundColor: _theme.primaryColor),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCalorieTargetDialog() {
    final ctrl = TextEditingController(text: _targetCalories.toString());
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF26364A))),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Napi Kalóriakeret Módosítása', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Ajánlott (Profil TDEE alapján): $_recommendedTdee kcal', style: TextStyle(color: _theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Egyéni Kalóriacél (kcal)',
                  labelStyle: const TextStyle(color: Color(0xFF91A2B5)),
                  filled: true,
                  fillColor: _theme.cardColor,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  TextButton(
                    onPressed: () => ctrl.text = _recommendedTdee.toString(),
                    child: Text('TDEE visszaállítás', style: TextStyle(color: _theme.primaryColor, fontSize: 11)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor),
                    onPressed: () async {
                      final val = int.tryParse(ctrl.text) ?? _targetCalories;
                      if (val > 500) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('custom_daily_target_calories', val);
                        setState(() => _targetCalories = val);
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('MENTÉS', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int get _consumedCalories => _meals.fold(0, (sum, item) => sum + item.calories);
  double get _consumedProtein => _meals.fold(0.0, (sum, item) => sum + item.protein);
  double get _consumedCarbs => _meals.fold(0.0, (sum, item) => sum + item.carbs);
  double get _consumedFat => _meals.fold(0.0, (sum, item) => sum + item.fat);

  int get _totalPlannedSets => _todayExercises.fold(0, (sum, e) => sum + e.targetSets);
  int get _totalDoneSets => _todayExercises.fold(0, (sum, e) => sum + e.completedSets);

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
            SnackBar(
              content: const Text('Pihenőidő letelt! Következő széria! 💪'),
              backgroundColor: _theme.primaryColor,
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
        backgroundColor: _theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF26364A))),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exercise.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                'Cél: ${exercise.targetSets} széria × ${exercise.targetReps} ism. (Kész: ${exercise.completedSets})',
                style: TextStyle(color: _theme.primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
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
                        labelText: 'Súly ehhez a szériához (kg)',
                        labelStyle: const TextStyle(color: Color(0xFF91A2B5)),
                        filled: true,
                        fillColor: _theme.cardColor,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
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
                        fillColor: _theme.cardColor,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
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
                    backgroundColor: _theme.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final w = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
                    final r = int.tryParse(repsCtrl.text) ?? exercise.targetReps;

                    if (w <= 0) return;

                    final nav = Navigator.of(ctx, rootNavigator: true);
                    final prefs = await SharedPreferences.getInstance();
                    final String? rawLogs = prefs.getString('exercise_progress_logs');
                    List<dynamic> logs = rawLogs != null ? jsonDecode(rawLogs) : [];
                    logs.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'exerciseName': exercise.name,
                      'weightKg': w,
                      'reps': r,
                      'date': _selectedDate.toIso8601String(),
                    });
                    await prefs.setString('exercise_progress_logs', jsonEncode(logs));

                    setState(() {
                      exercise.lastWeight = w;
                      if (exercise.completedSets < exercise.targetSets) {
                        exercise.completedSets++;
                      }
                    });
                    _saveDashboardData();

                    nav.pop();
                    _startRestTimer(90);
                  },
                  child: const Text('SZÉRIA KÉSZ & SÚLY MENTÉSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
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
        backgroundColor: _theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF26364A))),
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
                  if (initialAiData != null) Icon(Icons.auto_awesome, color: _theme.primaryColor, size: 20),
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
                  child: const Text('MENTÉS NAPI ÉTKEZÉSHEZ', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
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
      final XFile? picked = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
      if (picked == null) return;

      setState(() => _isAnalyzingPhoto = true);
      final result = await GeminiFoodService.analyzeFoodImage(File(picked.path));
      if (!mounted) return;
      setState(() => _isAnalyzingPhoto = false);

      _showAddMealDialog(initialAiData: result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hiba a kép beolvasásakor: $e'), backgroundColor: _theme.secondaryColor));
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('AI Étel Fotózás & Felismerés ✨', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: _theme.primaryColor),
              title: const Text('Fotó készítése kamerával', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndAnalyzeFoodImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: _theme.secondaryColor),
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
        fillColor: _theme.cardColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        final remainingCalories = _targetCalories - _consumedCalories;
        final calorieProgress = (_consumedCalories / _targetCalories).clamp(0.0, 1.0);
        final workoutProgress = _totalPlannedSets > 0 ? (_totalDoneSets / _totalPlannedSets).clamp(0.0, 1.0) : 0.0;
        final String displayDateStr = _formatHungarianDate(_selectedDate);

        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: _theme.backgroundColor,
            elevation: 0,
            title: GestureDetector(
              onTap: _onLogoTapped,
              child: const Text('Dagi app Vezérlőpult', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    border: Border.all(color: const Color(0xFF26364A)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.settings_outlined, size: 20, color: _theme.primaryColor),
                ),
                onPressed: () {
                  showDialog(context: context, builder: (BuildContext ctx) => const SettingsDialog());
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
                // Dátumválasztó Bar
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: Icon(Icons.chevron_left_rounded, color: _theme.primaryColor, size: 28), onPressed: () => _changeDate(-1)),
                      InkWell(
                        onTap: _selectCustomDate,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, size: 18, color: _theme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                displayDateStr,
                                style: TextStyle(color: _isToday ? _theme.primaryColor : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(icon: Icon(Icons.chevron_right_rounded, color: _theme.primaryColor, size: 28), onPressed: () => _changeDate(1)),
                    ],
                  ),
                ),

                if (_isAnalyzingPhoto)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _theme.primaryColor),
                    ),
                    child: Row(
                      children: [
                        CircularProgressIndicator(color: _theme.primaryColor),
                        const SizedBox(width: 16),
                        const Expanded(
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
                      color: _theme.secondaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _theme.secondaryColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, color: _theme.secondaryColor),
                            const SizedBox(width: 10),
                            Text('Pihenőidő hátra: $_restSecondsRemaining mp', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        TextButton(onPressed: () => _startRestTimer(0), child: Text('Kész', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),

                // MAI EDZÉS FEJLÉC, HALADÁS ÉS KÖZÖS EDZÉS MEGHÍVÓ GOMB
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
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
                              Icon(Icons.fitness_center_rounded, color: _theme.primaryColor, size: 22),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Mai edzésprogram:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                                  Text(_workoutDayType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (_todayExercises.isNotEmpty)
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _theme.primaryColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _theme.primaryColor),
                                    ),
                                    child: Icon(Icons.group_add_rounded, color: _theme.primaryColor, size: 18),
                                  ),
                                  tooltip: 'Barát meghívása erre az edzésre',
                                  onPressed: _sendWorkoutInviteDialog,
                                ),
                              if (_totalPlannedSets > 0)
                                Text('$_totalDoneSets / $_totalPlannedSets széria', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      if (_totalPlannedSets > 0) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: workoutProgress,
                            minHeight: 8,
                            backgroundColor: const Color(0xFF1B2A3D),
                            color: _theme.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Kalória Kártya
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
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
                              Row(
                                children: [
                                  const Text('Napi Kalóriakeret', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  InkWell(onTap: _showEditCalorieTargetDialog, child: Icon(Icons.edit, size: 14, color: _theme.primaryColor)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$remainingCalories kcal',
                                style: TextStyle(color: remainingCalories >= 0 ? _theme.primaryColor : _theme.secondaryColor, fontSize: 26, fontWeight: FontWeight.w900),
                              ),
                              Text('Elfogyasztva: $_consumedCalories / $_targetCalories kcal (TDEE: $_recommendedTdee)', style: const TextStyle(color: Color(0xFF55687D), fontSize: 11)),
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
                                  color: _theme.primaryColor,
                                ),
                              ),
                              Text('${(calorieProgress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFF1B2A3D)),
                      const SizedBox(height: 12),
                      _buildMacroRow('Fehérje', _consumedProtein, _targetProtein, _theme.primaryColor),
                      const SizedBox(height: 10),
                      _buildMacroRow('Szénhidrát', _consumedCarbs, _targetCarbs, const Color(0xFFFFB800)),
                      const SizedBox(height: 10),
                      _buildMacroRow('Zsír', _consumedFat, _targetFat, _theme.secondaryColor),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Gyakorlatok & Szériák', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('${_todayExercises.where((e) => e.completedSets >= e.targetSets).length}/${_todayExercises.length} feladat kész', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                if (_todayExercises.isEmpty)
                  _buildEmptyPlaceholder('Erre a napra nincs edzés beállítva (Pihenőnap 😴).\nÁllítsd össze a gyakorlataidat az Edzés fülön!')
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
                          color: isDone ? const Color(0xFF102624) : _theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDone ? _theme.primaryColor : const Color(0xFF26364A)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ex.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, decoration: isDone ? TextDecoration.lineThrough : null)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text('Cél: ${ex.targetSets} × ${ex.targetReps} ism.', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                                      const SizedBox(width: 10),
                                      Text('Súly: ${ex.lastWeight > 0 ? "${ex.lastWeight} kg" : "---"}', style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDone ? _theme.primaryColor : _theme.secondaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _logExerciseSet(ex),
                              child: Text(
                                isDone ? 'KÉSZ (${ex.completedSets}/${ex.targetSets})' : 'SZÉRIA (${ex.completedSets}/${ex.targetSets})',
                                style: TextStyle(color: isDone ? const Color(0xFF07101B) : Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Étkezések', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: const Color(0xFF1B2A3D), borderRadius: BorderRadius.circular(10), border: Border.all(color: _theme.primaryColor)),
                            child: Icon(Icons.camera_alt_rounded, color: _theme.primaryColor, size: 18),
                          ),
                          onPressed: _showImageSourcePicker,
                        ),
                        const SizedBox(width: 4),
                        IconButton(icon: Icon(Icons.add_circle, color: _theme.primaryColor, size: 28), onPressed: () => _showAddMealDialog()),
                      ],
                    ),
                  ],
                ),
                if (_meals.isEmpty)
                  _buildEmptyPlaceholder('Erre a napra még nincs rögzített étkezés.')
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
                        decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF26364A))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('${item.calories} kcal | F: ${item.protein}g Sz: ${item.carbs}g Zs: ${item.fat}g', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: _theme.secondaryColor, size: 18),
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
      },
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
            Text('${current.toStringAsFixed(1)} / ${max.toInt()}g', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFF1B2A3D), color: activeColor, minHeight: 6),
        ),
      ],
    );
  }

  Widget _buildEmptyPlaceholder(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1B2A3D))),
      child: Center(
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF55687D), fontSize: 13, height: 1.4)),
      ),
    );
  }
}

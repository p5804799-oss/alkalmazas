import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineExercise {
  final String name;
  final int defaultSets;
  final int defaultReps;

  const RoutineExercise({
    required this.name,
    required this.defaultSets,
    required this.defaultReps,
  });
}

class WorkoutCategory {
  final String id;
  final String title;
  final String subtitle;
  final String iconBadge;
  final List<RoutineExercise> exercises;

  const WorkoutCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconBadge,
    required this.exercises,
  });
}

const List<WorkoutCategory> kWorkoutCategories = [
  WorkoutCategory(
    id: 'push',
    title: 'PUSH',
    subtitle: 'Mell • Váll • Tricepsz',
    iconBadge: '↗',
    exercises: [
      RoutineExercise(name: 'Fekvenyomás rúddal', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Döntött padú kézisúlyzós nyomás', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Tárogatás alsó/felső csigán', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Vállból nyomás kézisúlyzóval', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Oldalemelés kézisúlyzóval', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Tolódzkodás padon/korláton', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tricepsz letolás csigán kötéllel', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Koponyatörő (Francia nyomás)', defaultSets: 3, defaultReps: 10),
    ],
  ),
  WorkoutCategory(
    id: 'pull',
    title: 'PULL',
    subtitle: 'Hát • Trapéz • Bicepsz',
    iconBadge: '↙',
    exercises: [
      RoutineExercise(name: 'Húzódzkodás / Széles lehúzás', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Döntött törzsű evezés', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Evezés alsó csigán szűken', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Fűnyíró evezés egykezessel', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Face pull kötéllel', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Bicepsz állva francia rúddal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Kalapács bicepsz kézisúlyzóval', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Scott pados bicepsz', defaultSets: 3, defaultReps: 10),
    ],
  ),
  WorkoutCategory(
    id: 'leg',
    title: 'LEG',
    subtitle: 'Comb • Vádli • Has',
    iconBadge: '⚡',
    exercises: [
      RoutineExercise(name: 'Guggolás rúddal', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Lábtoló gép', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Combhajlító gép fekve', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Combfeszítő gép', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Bolgár guggolás', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Álló vádliemelés', defaultSets: 5, defaultReps: 15),
      RoutineExercise(name: 'Függeszkedve lábemelés', defaultSets: 4, defaultReps: 15),
    ],
  ),
  WorkoutCategory(
    id: 'upper',
    title: 'UPPER',
    subtitle: 'PUSH + PULL bankból • 1 terv',
    iconBadge: '◆',
    exercises: [
      RoutineExercise(name: 'Fekvenyomás rúddal', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Döntött törzsű evezés', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Vállból nyomás kézisúlyzóval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Lehúzás mellhez szélesen', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Bicepsz állva rúddal', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Tricepsz letolás csigán', defaultSets: 3, defaultReps: 12),
    ],
  ),
  WorkoutCategory(
    id: 'lower',
    title: 'LOWER',
    subtitle: 'Alsótest & Törzserő • 1 terv',
    iconBadge: '▼',
    exercises: [
      RoutineExercise(name: 'Guggolás rúddal', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Román felhúzás', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Lábtoló gép', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Ülő vádliemelés', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Plank súllyal', defaultSets: 3, defaultReps: 60),
    ],
  ),
];

class WorkoutTrackerTab extends StatefulWidget {
  const WorkoutTrackerTab({super.key});

  @override
  State<WorkoutTrackerTab> createState() => _WorkoutTrackerTabState();
}

class _WorkoutTrackerTabState extends State<WorkoutTrackerTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B),
        elevation: 0,
        title: Row(
          children: [
            RichText(
              text: const TextSpan(
                text: 'Füty',
                style: TextStyle(color: Color(0xFF28D5CF), fontSize: 22, fontWeight: FontWeight.w900),
                children: [
                  TextSpan(text: 'fürütty', style: TextStyle(color: Color(0xFFFF356D))),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Milyen pusztítást végzünk ma?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 18),
            ...kWorkoutCategories.map((cat) => _buildWorkoutCard(context, cat)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, WorkoutCategory cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1825),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1F2F42), width: 1.5),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF142233),
            const Color(0xFF0A121D).withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => WorkoutDetailScreen(category: cat),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cat.exercises.length} gyakorlat • ${cat.subtitle}',
                      style: const TextStyle(
                        color: Color(0xFF91A2B5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      cat.iconBadge,
                      style: const TextStyle(
                        color: Color(0xFF28D5CF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF28D5CF),
                      size: 26,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutCategory category;

  const WorkoutDetailScreen({super.key, required this.category});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Map<String, double> _lastWeights = {};
  Map<String, int> _completedSets = {};
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isRestActive = false;

  @override
  void initState() {
    super.initState();
    _loadPreviousWeights();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPreviousWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawLogs = prefs.getString('exercise_progress_logs');
    final Map<String, double> weights = {};

    if (rawLogs != null && rawLogs.isNotEmpty) {
      final List<dynamic> logs = jsonDecode(rawLogs);
      for (final ex in widget.category.exercises) {
        final matches = logs.where((e) =>
            (e['exerciseName'] as String).toLowerCase() == ex.name.toLowerCase()).toList();
        if (matches.isNotEmpty) {
          matches.sort((a, b) =>
              DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
          weights[ex.name] = (matches.first['weightKg'] as num).toDouble();
        }
      }
    }

    setState(() {
      _lastWeights = weights;
    });
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = seconds;
      _isRestActive = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 0) {
        setState(() {
          _restSecondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRestActive = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pihenőidő letelt! Mehet a következő széria! 💪'),
              backgroundColor: Color(0xFF28D5CF),
            ),
          );
        }
      }
    });
  }

  void _logSetDialog(RoutineExercise exercise) {
    final lastW = _lastWeights[exercise.name] ?? 0.0;
    final weightCtrl = TextEditingController(text: lastW > 0 ? lastW.toString() : '');
    final repsCtrl = TextEditingController(text: exercise.defaultReps.toString());

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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(height: 6),
              Text(
                'Előző használt súly: ${lastW > 0 ? "$lastW kg" : "Még nincs rögzítve"}',
                style: const TextStyle(color: Color(0xFF28D5CF), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
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
                      style: const TextStyle(color: Colors.white),
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
                    final r = int.tryParse(repsCtrl.text) ?? exercise.defaultReps;

                    if (w <= 0) return;

                    final prefs = await SharedPreferences.getInstance();
                    final String? raw = prefs.getString('exercise_progress_logs');
                    List<dynamic> logs = raw != null ? jsonDecode(raw) : [];
                    logs.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'exerciseName': exercise.name,
                      'weightKg': w,
                      'reps': r,
                      'date': DateTime.now().toIso8601String(),
                    });
                    await prefs.setString('exercise_progress_logs', jsonEncode(logs));

                    setState(() {
                      _lastWeights[exercise.name] = w;
                      _completedSets[exercise.name] = (_completedSets[exercise.name] ?? 0) + 1;
                    });

                    Navigator.of(ctx, rootNavigator: true).pop();
                    _startRestTimer(90);
                  },
                  child: const Text('SZÉRIA MENTÉSE & PIHENŐ (90s)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF28D5CF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.category.title} Edzésterv',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isRestActive)
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
                      child: const Text('Kész', style: TextStyle(color: Color(0xFFFF356D), fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.category.exercises.length,
              itemBuilder: (ctx, i) {
                final ex = widget.category.exercises[i];
                final completed = _completedSets[ex.name] ?? 0;
                final isFinished = completed >= ex.defaultSets;
                final lastW = _lastWeights[ex.name] ?? 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isFinished ? const Color(0xFF102624) : const Color(0xFF0D1825),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFinished ? const Color(0xFF28D5CF) : const Color(0xFF26364A),
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
                                decoration: isFinished ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Cél: ${ex.defaultSets} × ${ex.defaultReps} ism.',
                                  style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Előző: ${lastW > 0 ? "$lastW kg" : "---"}',
                                  style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFinished ? const Color(0xFF28D5CF) : const Color(0xFFFF356D),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _logSetDialog(ex),
                        child: Text(
                          isFinished ? 'KÉSZ ($completed/${ex.defaultSets})' : 'SZÉRIA ($completed/${ex.defaultSets})',
                          style: TextStyle(
                            color: isFinished ? const Color(0xFF07101B) : Colors.white,
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
          ],
        ),
      ),
    );
  }
}
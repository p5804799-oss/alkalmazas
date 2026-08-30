import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class RoutineExercise {
  final String name;
  int defaultSets;
  int defaultReps;

  RoutineExercise({
    required this.name,
    required this.defaultSets,
    required this.defaultReps,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'defaultSets': defaultSets,
        'defaultReps': defaultReps,
      };

  factory RoutineExercise.fromMap(Map<String, dynamic> map) => RoutineExercise(
        name: map['name'] ?? '',
        defaultSets: map['defaultSets'] ?? 3,
        defaultReps: map['defaultReps'] ?? 10,
      );
}

class WorkoutCategory {
  final String id;
  final String title;
  final String subtitle;
  final String iconBadge;
  final String imageUrl;
  final List<RoutineExercise> exercises;

  WorkoutCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconBadge,
    required this.imageUrl,
    required this.exercises,
  });
}

List<WorkoutCategory> getInitialWorkoutCategories() => [
  WorkoutCategory(
    id: 'push',
    title: 'PUSH',
    subtitle: 'Mell • Váll • Tricepsz',
    iconBadge: '↗',
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Fekvenyomás rúddal (vízszintes)', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Fekvenyomás kézisúlyzóval', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Döntött padú nyomás rúddal', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Döntött padú nyomás kézisúlyzóval', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Negatív dőlésű fekvenyomás', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tolódzkodás párhuzamos korláton', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tárogatás kézisúlyzóval', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Tárogatás csigán', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Mellprés gép ülve', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Pec Deck gép', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Katonai nyomás állva rúddal (OHP)', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Vállból nyomás kézisúlyzóval', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Arnold nyomás', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Oldalemelés kézisúlyzóval', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Oldalemelés alsó csigán', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Előreemelés súlytárcsával', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Tricepsz letolás csigán kötéllel', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Tricepsz letolás rúddal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Francia nyomás EZ rúddal', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tricepsznyújtás fej felett', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Szűkfogású fekvenyomás', defaultSets: 3, defaultReps: 8),
    ],
  ),
  WorkoutCategory(
    id: 'pull',
    title: 'PULL',
    subtitle: 'Hát • Trapéz • Bicepsz',
    iconBadge: '↙',
    imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Húzódzkodás széles fogással', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Húzódzkodás szűk alsó fogással', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Lehúzás mellhez szélesen csigán', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Lehúzás szűk párhuzamos fogantyúval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Döntött törzsű evezés rúddal', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Egykezes evezés kézisúlyzóval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Evezés alsó csigán V-fogantyúval', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'T-rudas evezés', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Felhúzás (Deadlift)', defaultSets: 4, defaultReps: 6),
      RoutineExercise(name: 'Hipernyújtás', defaultSets: 3, defaultReps: 15),
      RoutineExercise(name: 'Face pull kötéllel', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Döntött oldalemelés hátsó vállra', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Vállvonogatás rúddal', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Bicepsz állva EZ rúddal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Bicepsz kézisúlyzóval váltva', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Kalapács bicepsz', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Scott pados bicepsz', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Koncentrált bicepsz', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Bicepsz alsó csigán', defaultSets: 3, defaultReps: 12),
    ],
  ),
  WorkoutCategory(
    id: 'leg',
    title: 'LEG',
    subtitle: 'Comb • Fenék • Vádli',
    iconBadge: '⚡',
    imageUrl: 'https://images.unsplash.com/photo-1434757436912-79ed740e7003?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Guggolás rúddal tarkón', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Elölguggolás rúddal', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Lábtoló gép 45 fok', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Hack guggolás', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Bolgár guggolás', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Sétáló kitörés', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Combfeszítő gép', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Combhajlító gép fekve', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Combhajlító gép ülve', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Román felhúzás (RDL)', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Hip Thrust gépen / rúddal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Álló vádliemelés', defaultSets: 5, defaultReps: 15),
      RoutineExercise(name: 'Ülő vádligép', defaultSets: 4, defaultReps: 15),
    ],
  ),
  WorkoutCategory(
    id: 'cardio',
    title: 'CARDIO & HIIT',
    subtitle: 'Állóképesség • Zsírégetés',
    iconBadge: '🏃',
    imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Futópad egyenletes futás (Zone 2)', defaultSets: 1, defaultReps: 30),
      RoutineExercise(name: 'Futópad dőlésszög gyaloglás (12-3-30)', defaultSets: 1, defaultReps: 30),
      RoutineExercise(name: 'Spinning kerékpár', defaultSets: 1, defaultReps: 25),
      RoutineExercise(name: 'Evezőgép intervallum', defaultSets: 4, defaultReps: 2),
      RoutineExercise(name: 'Lépcsőzőgép (StairMaster)', defaultSets: 1, defaultReps: 20),
      RoutineExercise(name: 'Ugrókötelezés', defaultSets: 5, defaultReps: 60),
      RoutineExercise(name: 'AirBike sprint', defaultSets: 6, defaultReps: 30),
      RoutineExercise(name: 'HIIT Tabata köredzés', defaultSets: 4, defaultReps: 4),
    ],
  ),
  WorkoutCategory(
    id: 'upper',
    title: 'UPPER BODY',
    subtitle: 'Felsőtest Átmozgatás',
    iconBadge: '◆',
    imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Fekvenyomás rúddal', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Döntött törzsű evezés', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Vállból nyomás kézisúlyzóval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Lehúzás mellhez', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Oldalemelés', defaultSets: 3, defaultReps: 15),
      RoutineExercise(name: 'Bicepsz állva', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tricepsz letolás', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Face pull', defaultSets: 3, defaultReps: 15),
    ],
  ),
  WorkoutCategory(
    id: 'lower',
    title: 'LOWER & CORE',
    subtitle: 'Alsótest & Törzs',
    iconBadge: '▼',
    imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Guggolás', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Román felhúzás', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Lábtoló', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Combhajlító', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Lábemelés függeszkedve', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Harangozás csigán', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Plank tartás', defaultSets: 3, defaultReps: 60),
    ],
  ),
];

class WorkoutTrackerTab extends StatefulWidget {
  const WorkoutTrackerTab({super.key});

  @override
  State<WorkoutTrackerTab> createState() => _WorkoutTrackerTabState();
}

class _WorkoutTrackerTabState extends State<WorkoutTrackerTab> {
  final ThemeService _theme = ThemeService();
  final ImagePicker _picker = ImagePicker();
  final Map<String, String> _customImagePaths = {};
  late final List<WorkoutCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = getInitialWorkoutCategories();
    _loadCustomCoverImages();
  }

  Future<void> _loadCustomCoverImages() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> paths = {};
    for (var cat in _categories) {
      final savedPath = prefs.getString('workout_cover_${cat.id}');
      if (savedPath != null && File(savedPath).existsSync()) {
        paths[cat.id] = savedPath;
      }
    }
    setState(() {
      _customImagePaths.addAll(paths);
    });
  }

  Future<void> _pickImageForCategory(String categoryId, ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('workout_cover_$categoryId', picked.path);
        setState(() {
          _customImagePaths[categoryId] = picked.path;
        });
      }
    } catch (_) {}
  }

  ImageProvider _getImageProvider(WorkoutCategory cat) {
    final customPath = _customImagePaths[cat.id];
    if (customPath != null && File(customPath).existsSync()) {
      return FileImage(File(customPath));
    }
    return NetworkImage(cat.imageUrl);
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
            elevation: 0,
            title: const Text('Dagi app • Edzés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                height: 120,
                decoration: BoxDecoration(
                  color: _theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1F2F42), width: 1.5),
                  image: DecorationImage(
                    image: _getImageProvider(cat),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(_theme.backgroundColor.withValues(alpha: 0.72), BlendMode.darken),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => WorkoutDetailScreen(category: cat)));
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
                              Text(cat.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text('${cat.exercises.length} gyakorlat • ${cat.subtitle}', style: const TextStyle(color: Color(0xFFD3E0EA), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Icon(Icons.arrow_forward_rounded, color: _theme.primaryColor, size: 26),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
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
  final ThemeService _theme = ThemeService();
  late List<RoutineExercise> _exercises;
  final Set<String> _selectedExerciseNames = {};

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.category.exercises);
  }

  Future<void> _activateWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedList = _exercises.where((e) => _selectedExerciseNames.contains(e.name)).toList();

    final plannedItems = selectedList.map((e) => {
      'name': e.name,
      'targetSets': e.defaultSets,
      'targetReps': e.defaultReps,
      'completedSets': 0,
    }).toList();

    final workoutTitle = selectedList.isNotEmpty
        ? "${widget.category.title} (${selectedList.length} gyakorlat)"
        : "${widget.category.title} (Szabad edzés)";

    await prefs.setString('daily_workout_type', workoutTitle);
    await prefs.setString('daily_planned_exercises', jsonEncode(plannedItems));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$workoutTitle sikeresen aktiválva! 💪'), backgroundColor: _theme.primaryColor),
      );
      Navigator.pop(context);
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
            title: Text(widget.category.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            color: _theme.cardColor,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _activateWorkout,
              icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF07101B)),
              label: Text(
                _selectedExerciseNames.isNotEmpty ? 'EDZÉS AKTIVÁLÁSA (${_selectedExerciseNames.length})' : 'SZABAD EDZÉS INDÍTÁSA',
                style: const TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900),
              ),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _exercises.length,
            itemBuilder: (context, idx) {
              final ex = _exercises[idx];
              final isSelected = _selectedExerciseNames.contains(ex.name);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _theme.primaryColor.withValues(alpha: 0.12) : _theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? _theme.primaryColor : const Color(0xFF26364A)),
                ),
                child: CheckboxListTile(
                  activeColor: _theme.primaryColor,
                  checkColor: const Color(0xFF07101B),
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedExerciseNames.add(ex.name);
                      } else {
                        _selectedExerciseNames.remove(ex.name);
                      }
                    });
                  },
                  title: Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${ex.defaultSets} széria × ${ex.defaultReps} ismétlés', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

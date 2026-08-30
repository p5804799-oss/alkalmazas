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
      RoutineExercise(name: 'Fekvenyomás kézisúlyzóval (vízszintes)', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Döntött padú nyomás rúddal (felső mell)', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Döntött padú nyomás kézisúlyzóval', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Negatív dőlésű fekvenyomás', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tolódzkodás párhuzamos korláton', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tárogatás kézisúlyzóval', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Tárogatás csigán (közép/felső mell)', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Mellprés gép ülve', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Pec Deck (Mellgép)', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Katonai nyomás állva rúddal (OHP)', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Vállból nyomás kézisúlyzóval ülve', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Arnold nyomás kézisúlyzóval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Oldalemelés kézisúlyzóval állva', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Oldalemelés alsó csigán', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Előreemelés súlytárcsával / rúddal', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Tricepsz letolás csigán kötéllel', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Tricepsz letolás egyenes rúddal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Francia nyomás (Koponyatörő EZ rúddal)', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tricepsznyújtás fej felett kézisúlyzóval', defaultSets: 3, defaultReps: 12),
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
      RoutineExercise(name: 'Húzódzkodás széles felső fogással', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Húzódzkodás szűk alsó fogással (Chin-up)', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Lehúzás mellhez széles fogással csigán', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Lehúzás szűk párhuzamos fogantyúval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Döntött törzsű evezés rúddal', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Fűnyíró evezés egykezes súlyzóval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Evezés alsó csigán szűk V-fogantyúval', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'T-rudas evezés mellkastámasszal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Felhúzás rúddal (Deadlift)', defaultSets: 4, defaultReps: 6),
      RoutineExercise(name: 'Hipernyújtás padon (Alsó hát)', defaultSets: 3, defaultReps: 15),
      RoutineExercise(name: 'Face pull kötéllel felső csigán', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Döntött törzsű oldalemelés (Hátsó váll)', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Vállvonogatás rúddal / súlyzóval', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Bicepsz állva francia EZ rúddal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Bicepsz kézisúlyzóval váltva', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Kalapács bicepsz kézisúlyzóval', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Scott pados bicepszhajlítás', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Koncentrált bicepsz kézisúlyzóval', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Bicepsz alsó csigán rúddal', defaultSets: 3, defaultReps: 12),
    ],
  ),
  WorkoutCategory(
    id: 'leg',
    title: 'LEG',
    subtitle: 'Comb • Fenék • Vádli',
    iconBadge: '⚡',
    imageUrl: 'https://images.unsplash.com/photo-1434757436912-79ed740e7003?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Guggolás rúddal tarkón (Back Squat)', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Elölguggolás rúddal (Front Squat)', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Lábtoló gép 45 fokos szögben', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Hack guggolás gépen', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Bolgár guggolás kézisúlyzóval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Sétáló kitörés kézisúlyzókkal', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Combfeszítő gép ülve', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Combhajlító gép fekve', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Combhajlító gép ülve', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Román felhúzás súlyzóval (RDL)', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Csípőemelés rúddal / gépen (Hip Thrust)', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Álló vádliemelés gépen / lépcsőn', defaultSets: 5, defaultReps: 15),
      RoutineExercise(name: 'Ülő vádligép', defaultSets: 4, defaultReps: 15),
    ],
  ),
  WorkoutCategory(
    id: 'cardio',
    title: 'CARDIO & HIIT',
    subtitle: 'Állóképesség • Zsírégetés • Kondi',
    iconBadge: '🏃',
    imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Futópad – Egyenletes tempójú futás (Zone 2)', defaultSets: 1, defaultReps: 30),
      RoutineExercise(name: 'Futópad – Döntött emelkedős gyaloglás (12-3-30)', defaultSets: 1, defaultReps: 30),
      RoutineExercise(name: 'Konditerem teremkerékpár (Spinning)', defaultSets: 1, defaultReps: 25),
      RoutineExercise(name: 'Evezőgép intervallumok (500m sprint)', defaultSets: 4, defaultReps: 2),
      RoutineExercise(name: 'Lépcsőzőgép (StairMaster) folyamatos ritmus', defaultSets: 1, defaultReps: 20),
      RoutineExercise(name: 'Ugrókötelezés intervallumokban', defaultSets: 5, defaultReps: 60),
      RoutineExercise(name: 'AirBike (Assault Bike) max sprint', defaultSets: 6, defaultReps: 30),
      RoutineExercise(name: 'HIIT Tabata köredzés (Burpee, Mountain Climber)', defaultSets: 4, defaultReps: 4),
    ],
  ),
  WorkoutCategory(
    id: 'upper',
    title: 'UPPER BODY',
    subtitle: 'Teljes Felsőtest Átmozgatás',
    iconBadge: '◆',
    imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Fekvenyomás rúddal', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Döntött törzsű evezés rúddal', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Vállból nyomás kézisúlyzóval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Lehúzás mellhez szélesen', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Oldalemelés kézisúlyzóval', defaultSets: 3, defaultReps: 15),
      RoutineExercise(name: 'Bicepsz állva francia rúddal', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tricepsz letolás csigán', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Face pull kötéllel', defaultSets: 3, defaultReps: 15),
    ],
  ),
  WorkoutCategory(
    id: 'lower',
    title: 'LOWER & CORE',
    subtitle: 'Alsótest & Törzserő',
    iconBadge: '▼',
    imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Guggolás rúddal', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Román felhúzás rúddal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Lábtoló gép', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Combhajlító gép', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Combfeszítő gép', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Függeszkedve lábemelés kereten', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Harangozás csigán (Cable Crunch)', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Plank tartás testsúllyal', defaultSets: 3, defaultReps: 60),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Egyéni borítókép sikeresen beállítva! 📸'), backgroundColor: _theme.primaryColor),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba a kép beállításakor: $e'), backgroundColor: _theme.secondaryColor),
        );
      }
    }
  }

  void _showChangeCoverSheet(WorkoutCategory cat) {
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
            Text('${cat.title} Borítókép Módosítása 📸', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            const Text('Válassz fotót az edzéskártya hátterének:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: _theme.primaryColor),
              title: const Text('Kép kiválasztása galériából', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImageForCategory(cat.id, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: _theme.secondaryColor),
              title: const Text('Új fotó készítése kamerával', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImageForCategory(cat.id, ImageSource.camera);
              },
            ),
            if (_customImagePaths.containsKey(cat.id))
              ListTile(
                leading: const Icon(Icons.refresh_rounded, color: Color(0xFF91A2B5)),
                title: const Text('Alapértelmezett kép visszaállítása', style: TextStyle(color: Color(0xFF91A2B5))),
                onTap: () async {
                  Navigator.pop(ctx);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('workout_cover_${cat.id}');
                  setState(() {
                    _customImagePaths.remove(cat.id);
                  });
                },
              ),
          ],
        ),
      ),
    );
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
            title: Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Füty',
                    style: TextStyle(color: _theme.primaryColor, fontSize: 22, fontWeight: FontWeight.w900),
                    children: [
                      TextSpan(text: 'fürütty', style: TextStyle(color: _theme.secondaryColor)),
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
                  'Edzéstervező & Kategóriák',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Válassz tetszőleges kategóriát, vagy állítsd össze szabadon!',
                  style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12),
                ),
                const SizedBox(height: 18),
                ..._categories.map((cat) => _buildWorkoutCard(context, cat)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutCard(BuildContext context, WorkoutCategory cat) {
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
          colorFilter: ColorFilter.mode(
            _theme.backgroundColor.withValues(alpha: 0.72),
            BlendMode.darken,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => WorkoutDetailScreen(category: cat)),
            );
          },
          onLongPress: () => _showChangeCoverSheet(cat),
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
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cat.exercises.length} gyakorlat • ${cat.subtitle}',
                      style: const TextStyle(color: Color(0xFFD3E0EA), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_rounded, color: _theme.primaryColor, size: 26),
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
  final ThemeService _theme = ThemeService();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<RoutineExercise> _exercises = [];
  Set<String> _selectedExerciseNames = {};

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.category.exercises);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _activateWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final selectedList = _exercises.where((e) => _selectedExerciseNames.contains(e.name)).toList();

    final plannedItems = selectedList.map((e) {
      return {
        'name': e.name,
        'targetSets': e.defaultSets,
        'targetReps': e.defaultReps,
        'completedSets': 0,
      };
    }).toList();

    final workoutTitle = selectedList.isNotEmpty
        ? "${widget.category.title} (${selectedList.length} gyakorlat)"
        : "${widget.category.title} (Szabad edzés)";

    await prefs.setString('daily_workout_type_$dateKey', workoutTitle);
    await prefs.setString('daily_planned_exercises_$dateKey', jsonEncode(plannedItems));
    await prefs.setString('daily_workout_type', workoutTitle);
    await prefs.setString('daily_planned_exercises', jsonEncode(plannedItems));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$workoutTitle sikeresen beállítva a Dashboardra! 💪'),
          backgroundColor: _theme.primaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        final filteredList = _exercises.where((e) {
          if (_searchQuery.isEmpty) return true;
          return e.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: _theme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: _theme.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(widget.category.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _theme.cardColor,
              border: const Border(top: BorderSide(color: Color(0xFF26364A))),
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _activateWorkout,
              icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF07101B)),
              label: Text(
                _selectedExerciseNames.isNotEmpty
                    ? 'EDZÉS AKTIVÁLÁSA (${_selectedExerciseNames.length} GYAKORLAT)'
                    : 'EDZÉS INDÍTÁSA (SZABADON)',
                style: const TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Keresés a gyakorlatok között...',
                    hintStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: _theme.primaryColor, size: 20),
                    filled: true,
                    fillColor: _theme.cardColor,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF26364A))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _theme.primaryColor)),
                  ),
                ),
                const SizedBox(height: 14),
                ...filteredList.map((ex) {
                  final isSelected = _selectedExerciseNames.contains(ex.name);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _theme.primaryColor.withValues(alpha: 0.12) : _theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? _theme.primaryColor : const Color(0xFF26364A)),
                    ),
                    child: ListTile(
                      leading: Checkbox(
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
                      ),
                      title: Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('${ex.defaultSets} széria × ${ex.defaultReps} ismétlés', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

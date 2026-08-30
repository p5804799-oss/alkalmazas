import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class RoutineExercise {
  final String name;
  final int defaultSets;
  final int defaultReps;

  const RoutineExercise({
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

  const WorkoutCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconBadge,
    required this.imageUrl,
    required this.exercises,
  });
}

const List<WorkoutCategory> kInitialWorkoutCategories = [
  WorkoutCategory(
    id: 'push',
    title: 'PUSH',
    subtitle: 'Mell • Váll • Tricepsz',
    iconBadge: '↗',
    imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Fekvenyomás rúddal (Vízszintes)', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Döntött padú kézisúlyzós nyomás', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Tárogatás alsó/felső csigán', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Tolódzkodás súllyal/testsúllyal', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Vállból nyomás kézisúlyzóval ülve', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Oldalemelés kézisúlyzóval állva', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Oldalemelés alsó csigán', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Tricepsz letolás csigán kötéllel', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Koponyatörő (Francia nyomás)', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Tricepsznyújtás fej felett egykezessel', defaultSets: 3, defaultReps: 12),
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
      RoutineExercise(name: 'Lehúzás mellhez széles fogással', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Döntött törzsű evezés rúddal', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Evezés alsó csigán szűk V-fogantyúval', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Fűnyíró evezés egykezessel támaszkodva', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Face pull kötéllel felső csigán', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Bicepsz állva francia rúddal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Kalapács bicepsz kézisúlyzóval', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Scott pados bicepszhajlítás', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Koncentrált bicepsz ülve', defaultSets: 3, defaultReps: 12),
    ],
  ),
  WorkoutCategory(
    id: 'leg',
    title: 'LEG',
    subtitle: 'Comb • Vádli • Has',
    iconBadge: '⚡',
    imageUrl: 'https://images.unsplash.com/photo-1434757436912-79ed740e7003?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Guggolás rúddal tarkón', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Lábtoló gép 45 fokban', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Hack guggolás gépen', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Bolgár guggolás kézisúlyzóval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Combhajlító gép fekve', defaultSets: 4, defaultReps: 12),
      RoutineExercise(name: 'Román felhúzás kézisúlyzóval', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Combfeszítő gép ülve', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Álló vádliemelés gépen/lépcsőn', defaultSets: 5, defaultReps: 15),
      RoutineExercise(name: 'Függeszkedve lábemelés kereten', defaultSets: 4, defaultReps: 15),
    ],
  ),
  WorkoutCategory(
    id: 'upper',
    title: 'UPPER',
    subtitle: 'Teljes Felsőtest Átmozgatás',
    iconBadge: '◆',
    imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Fekvenyomás rúddal', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Döntött törzsű evezés rúddal', defaultSets: 3, defaultReps: 8),
      RoutineExercise(name: 'Vállból nyomás kézisúlyzóval', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Lehúzás mellhez szélesen', defaultSets: 3, defaultReps: 10),
      RoutineExercise(name: 'Bicepsz állva kétkezessel', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Tricepsz letolás csigán', defaultSets: 3, defaultReps: 12),
    ],
  ),
  WorkoutCategory(
    id: 'lower',
    title: 'LOWER',
    subtitle: 'Alsótest & Törzserő',
    iconBadge: '▼',
    imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&q=80',
    exercises: [
      RoutineExercise(name: 'Guggolás rúddal', defaultSets: 4, defaultReps: 8),
      RoutineExercise(name: 'Román felhúzás rúddal', defaultSets: 4, defaultReps: 10),
      RoutineExercise(name: 'Lábtoló gép', defaultSets: 3, defaultReps: 12),
      RoutineExercise(name: 'Ülő vádliemelés', defaultSets: 4, defaultReps: 15),
      RoutineExercise(name: 'Plank súlytárcsával a háton', defaultSets: 3, defaultReps: 60),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF07101B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF07101B),
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
                  'Milyen edzést állítunk össze ma?',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Válassz kategóriát, keress a gyakorlatok között és pipáld be őket!',
                  style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12),
                ),
                const SizedBox(height: 18),
                ...kInitialWorkoutCategories.map((cat) => _buildWorkoutCard(context, cat)),
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
      height: 125,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1825),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1F2F42), width: 1.5),
        image: DecorationImage(
          image: NetworkImage(cat.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF07101B).withValues(alpha: 0.72),
            BlendMode.darken,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => WorkoutDetailScreen(category: cat)),
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
                        shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 2))],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cat.exercises.length} gyakorlat a bankban • ${cat.subtitle}',
                      style: const TextStyle(color: Color(0xFFD3E0EA), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(cat.iconBadge, style: TextStyle(color: _theme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: _theme.primaryColor, size: 26),
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
  final ThemeService _theme = ThemeService();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<RoutineExercise> _exercises = [];
  Set<String> _selectedExerciseNames = {};
  Map<String, double> _lastWeights = {};

  @override
  void initState() {
    super.initState();
    _loadExercisesAndHistory();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExercisesAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final customKey = 'custom_exercises_${widget.category.id}';
    final rawCustom = prefs.getString(customKey);

    List<RoutineExercise> loadedList = [];
    if (rawCustom != null && rawCustom.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(rawCustom);
      loadedList = decoded.map((e) => RoutineExercise.fromMap(e)).toList();
    } else {
      loadedList = List.from(widget.category.exercises);
    }

    final String? rawLogs = prefs.getString('exercise_progress_logs');
    final Map<String, double> weights = {};

    if (rawLogs != null && rawLogs.isNotEmpty) {
      final List<dynamic> logs = jsonDecode(rawLogs);
      for (final ex in loadedList) {
        final matches = logs.where((e) => (e['exerciseName'] as String).toLowerCase() == ex.name.toLowerCase()).toList();
        if (matches.isNotEmpty) {
          matches.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
          weights[ex.name] = (matches.first['weightKg'] as num).toDouble();
        }
      }
    }

    setState(() {
      _exercises = loadedList;
      _lastWeights = weights;
      _selectedExerciseNames = loadedList.take(5).map((e) => e.name).toSet();
    });
  }

  Future<void> _saveCustomExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final customKey = 'custom_exercises_${widget.category.id}';
    final data = jsonEncode(_exercises.map((e) => e.toMap()).toList());
    await prefs.setString(customKey, data);
  }

  Future<void> _activateSelectedAsTodayWorkout() async {
    if (_selectedExerciseNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Válassz ki legalább 1 gyakorlatot az edzéshez!'),
          backgroundColor: _theme.secondaryColor,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final selectedList = _exercises.where((e) => _selectedExerciseNames.contains(e.name)).toList();

    final plannedItems = selectedList.map((e) {
      return {
        'name': e.name,
        'targetSets': e.defaultSets,
        'targetReps': e.defaultReps,
        'lastWeight': _lastWeights[e.name] ?? 0.0,
        'completedSets': 0,
      };
    }).toList();

    final workoutTitle = "${widget.category.title} (${selectedList.length} gyakorlat)";

    await prefs.setString('daily_workout_type_$dateKey', workoutTitle);
    await prefs.setString('daily_planned_exercises_$dateKey', jsonEncode(plannedItems));
    await prefs.setString('daily_workout_type', workoutTitle);
    await prefs.setString('daily_planned_exercises', jsonEncode(plannedItems));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sikeresen átküldve a Dashboardra! (${selectedList.length} gyakorlat)'),
          backgroundColor: _theme.primaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showAddCustomExerciseDialog() {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');

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
              Text('Új Gyakorlat Hozzáadása (${widget.category.title})',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Gyakorlat pontos neve',
                  labelStyle: const TextStyle(color: Color(0xFF91A2B5)),
                  filled: true,
                  fillColor: const Color(0xFF0D1825),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Széria',
                        labelStyle: const TextStyle(color: Color(0xFF91A2B5)),
                        filled: true,
                        fillColor: const Color(0xFF0D1825),
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
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Ismétlés',
                        labelStyle: const TextStyle(color: Color(0xFF91A2B5)),
                        filled: true,
                        fillColor: const Color(0xFF0D1825),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final n = nameCtrl.text.trim();
                    final s = int.tryParse(setsCtrl.text) ?? 3;
                    final r = int.tryParse(repsCtrl.text) ?? 10;
                    if (n.isNotEmpty) {
                      setState(() {
                        _exercises.add(RoutineExercise(name: n, defaultSets: s, defaultReps: r));
                        _selectedExerciseNames.add(n);
                      });
                      _saveCustomExercises();
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('MENTÉS GYAKORLATKÉNT', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedExerciseNames.length == _exercises.length) {
        _selectedExerciseNames.clear();
      } else {
        _selectedExerciseNames = _exercises.map((e) => e.name).toSet();
      }
    });
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

        final allSelected = _selectedExerciseNames.length == _exercises.length && _exercises.isNotEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFF07101B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF07101B),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: _theme.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('${widget.category.title} Gyakorlatbank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            actions: [
              IconButton(
                icon: Icon(Icons.add_circle_outline_rounded, color: _theme.primaryColor, size: 26),
                onPressed: _showAddCustomExerciseDialog,
              ),
              const SizedBox(width: 8),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1825),
              border: Border(top: BorderSide(color: Color(0xFF26364A))),
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedExerciseNames.isNotEmpty ? _theme.primaryColor : const Color(0xFF26364A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _activateSelectedAsTodayWorkout,
              icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF07101B)),
              label: Text(
                'KIVÁLASZTOTT GYAKORLATOK AKTIVÁLÁSA (${_selectedExerciseNames.length})',
                style: const TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ÉLŐ KERESŐ MEZŐ
                TextField(
                  controller: _searchCtrl,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Keresés a gyakorlatok között...',
                    hintStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: _theme.primaryColor, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF91A2B5), size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF0D1825),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF26364A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _theme.primaryColor),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchQuery.isEmpty ? 'Válassz gyakorlatokat:' : 'Találatok (${filteredList.length}):',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (_searchQuery.isEmpty)
                      TextButton(
                        onPressed: _toggleSelectAll,
                        child: Text(
                          allSelected ? 'Összes törlése' : 'Összes kijelölése',
                          style: TextStyle(color: _theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (filteredList.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1825),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1B2A3D)),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, color: Color(0xFF55687D), size: 36),
                          const SizedBox(height: 8),
                          Text('Nincs találat a következőre: "$_searchQuery"',
                              style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (ctx, i) {
                      final ex = filteredList[i];
                      final isSelected = _selectedExerciseNames.contains(ex.name);
                      final lastW = _lastWeights[ex.name] ?? 0.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF102624) : const Color(0xFF0D1825),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? _theme.primaryColor : const Color(0xFF26364A),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          activeColor: _theme.primaryColor,
                          checkColor: const Color(0xFF07101B),
                          value: isSelected,
                          onChanged: (bool? val) {
                            setState(() {
                              if (val == true) {
                                _selectedExerciseNames.add(ex.name);
                              } else {
                                _selectedExerciseNames.remove(ex.name);
                              }
                            });
                          },
                          title: Text(
                            ex.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text('Cél: ${ex.defaultSets} × ${ex.defaultReps} ism.', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                              const SizedBox(width: 10),
                              Text(
                                'Előző: ${lastW > 0 ? "$lastW kg" : "---"}',
                                style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

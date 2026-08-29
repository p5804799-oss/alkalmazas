import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseLogEntry {
  final String id;
  final String exerciseName;
  final double weightKg;
  final int reps;
  final DateTime date;

  ExerciseLogEntry({
    required this.id,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'exerciseName': exerciseName,
        'weightKg': weightKg,
        'reps': reps,
        'date': date.toIso8601String(),
      };

  factory ExerciseLogEntry.fromMap(Map<String, dynamic> map) => ExerciseLogEntry(
        id: map['id'] ?? UniqueKey().toString(),
        exerciseName: map['exerciseName'] ?? 'Ismeretlen',
        weightKg: (map['weightKg'] as num).toDouble(),
        reps: map['reps'] ?? 0,
        date: DateTime.parse(map['date']),
      );
}

class WorkoutTrackerTab extends StatefulWidget {
  const WorkoutTrackerTab({super.key});

  @override
  State<WorkoutTrackerTab> createState() => _WorkoutTrackerTabState();
}

class _WorkoutTrackerTabState extends State<WorkoutTrackerTab> {
  final List<ExerciseLogEntry> _allEntries = [];
  String _selectedExercise = 'Fekvenyomás';
  bool _isLoading = true;

  final List<String> _defaultExercises = [
    'Fekvenyomás',
    'Guggolás',
    'Felhúzás',
    'Vállból nyomás',
    'Bicepsz állva',
    'Tricepsz letolás',
    'Húzódzkodás',
    'Evezés döntött törzzsel',
  ];

  @override
  void initState() {
    super.initState();
    _loadExerciseLogs();
  }

  Future<void> _loadExerciseLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString('exercise_progress_logs');
    if (rawData != null && rawData.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(rawData);
      _allEntries.clear();
      _allEntries.addAll(decoded.map((e) => ExerciseLogEntry.fromMap(e)).toList());
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveExerciseLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String rawData = jsonEncode(_allEntries.map((e) => e.toMap()).toList());
    await prefs.setString('exercise_progress_logs', rawData);
  }

  List<ExerciseLogEntry> get _filteredEntries {
    final list = _allEntries
        .where((e) => e.exerciseName.toLowerCase() == _selectedExercise.toLowerCase())
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<String> get _availableExercises {
    final set = <String>{..._defaultExercises};
    for (final e in _allEntries) {
      set.add(e.exerciseName);
    }
    return set.toList();
  }

  void _showAddLogDialog() {
    final nameCtrl = TextEditingController(text: _selectedExercise);
    final weightCtrl = TextEditingController();
    final repsCtrl = TextEditingController(text: '8');

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
                'Új Súly Rögzítése Gyakorlathoz',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Gyakorlat neve (pl. Fekvenyomás)',
                  hintStyle: const TextStyle(color: Color(0xFF55687D)),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Súly (kg)',
                        hintStyle: const TextStyle(color: Color(0xFF55687D)),
                        suffixText: 'kg',
                        suffixStyle: const TextStyle(color: Color(0xFF28D5CF)),
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
                        hintText: 'Ismétlés',
                        hintStyle: const TextStyle(color: Color(0xFF55687D)),
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
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final weight = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
                    final reps = int.tryParse(repsCtrl.text) ?? 0;

                    if (name.isEmpty || weight <= 0) return;

                    final newEntry = ExerciseLogEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      exerciseName: name,
                      weightKg: weight,
                      reps: reps,
                      date: DateTime.now(),
                    );

                    setState(() {
                      _allEntries.add(newEntry);
                      _selectedExercise = name;
                    });

                    _saveExerciseLogs();
                    Navigator.of(ctx, rootNavigator: true).pop();
                  },
                  child: const Text(
                    'MENTÉS & DIAGRAM FRISSÍTÉSE',
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF07101B),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF28D5CF))),
      );
    }

    final filtered = _filteredEntries;
    final chartEntries = List<ExerciseLogEntry>.from(filtered)
      ..sort((a, b) => a.date.compareTo(b.date));

    final double maxWeight = filtered.isEmpty
        ? 0.0
        : filtered.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
    final double latestWeight = filtered.isEmpty ? 0.0 : filtered.first.weightKg;

    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B),
        elevation: 0,
        title: const Text(
          'Edzés Fejlődés & Súlyok',
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
              child: const Icon(Icons.add, color: Color(0xFF28D5CF), size: 20),
            ),
            onPressed: _showAddLogDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1825),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF26364A)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _availableExercises.contains(_selectedExercise)
                      ? _selectedExercise
                      : _availableExercises.first,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0D1825),
                  style: const TextStyle(
                      color: Color(0xFF28D5CF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  items: _availableExercises.map((ex) {
                    return DropdownMenuItem<String>(
                      value: ex,
                      child: Text(ex),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedExercise = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                      'Legutóbbi súly', '$latestWeight kg', const Color(0xFF28D5CF)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                      'Egyéni rekord (PR)', '$maxWeight kg', const Color(0xFFFF356D)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1825),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF26364A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedExercise fejlődési görbe',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: chartEntries.isEmpty
                        ? const Center(
                            child: Text(
                              'Ehhez a gyakorlathoz még nincs felvitt adat.',
                              style: TextStyle(color: Color(0xFF55687D), fontSize: 13),
                            ),
                          )
                        : CustomPaint(
                            painter: ExerciseProgressPainter(entries: chartEntries),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gyakorlat Előzmények',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${filtered.length} mérés',
                  style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1825),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1B2A3D)),
                ),
                child: const Center(
                  child: Text(
                    'Koppints a jobb felső + gombra az első súly felviteléhez!',
                    style: TextStyle(color: Color(0xFF55687D), fontSize: 13),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1825),
                      borderRadius: BorderRadius.circular(14),
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
                              child: const Icon(Icons.fitness_center,
                                  color: Color(0xFFFF356D), size: 18),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.weightKg} kg × ${item.reps} ism.',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  DateFormat('yyyy. MM. dd. - HH:mm').format(item.date),
                                  style: const TextStyle(
                                      color: Color(0xFF91A2B5), fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFFFF356D), size: 20),
                          onPressed: () {
                            setState(() {
                              _allEntries.removeWhere((e) => e.id == item.id);
                            });
                            _saveExerciseLogs();
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

  Widget _buildMetricCard(String title, String val, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1825),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26364A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
          const SizedBox(height: 4),
          Text(val,
              style: TextStyle(
                  color: accent, fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }
}

class ExerciseProgressPainter extends CustomPainter {
  final List<ExerciseLogEntry> entries;

  ExerciseProgressPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFFFF356D)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF28D5CF)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = const Color(0xFF26364A).withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (entries.length == 1) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6, dotPaint);
      return;
    }

    double minW = entries.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
    double maxW = entries.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);

    if (minW == maxW) {
      minW -= 2;
      maxW += 2;
    } else {
      final pad = (maxW - minW) * 0.15;
      minW -= pad;
      maxW += pad;
    }

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      final x = (size.width / (entries.length - 1)) * i;
      final y = size.height - ((entries[i].weightKg - minW) / (maxW - minW) * size.height);
      final pt = Offset(x, y);
      points.add(pt);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    for (final pt in points) {
      canvas.drawCircle(pt, 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ExerciseProgressPainter oldDelegate) => true;
}

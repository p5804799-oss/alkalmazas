import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class ProgressLogItem {
  final String id;
  final String exerciseName;
  final double weightKg;
  final int reps;
  final DateTime date;

  ProgressLogItem({
    required this.id,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.date,
  });

  factory ProgressLogItem.fromJson(Map<String, dynamic> json) => ProgressLogItem(
        id: json['id'] ?? '',
        exerciseName: json['exerciseName'] ?? '',
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
        reps: json['reps'] ?? 0,
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );
}

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  final ThemeService _theme = ThemeService();
  List<ProgressLogItem> _logs = [];
  String _selectedExercise = 'Összes';
  List<String> _exerciseNames = ['Összes'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawLogs = prefs.getString('exercise_progress_logs');
    List<ProgressLogItem> loaded = [];
    Set<String> names = {'Összes'};

    if (rawLogs != null && rawLogs.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(rawLogs);
      loaded = decoded.map((e) => ProgressLogItem.fromJson(e)).toList();
      loaded.sort((a, b) => b.date.compareTo(a.date));
      for (var l in loaded) {
        if (l.exerciseName.isNotEmpty) names.add(l.exerciseName);
      }
    }

    setState(() {
      _logs = loaded;
      _exerciseNames = names.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        final filteredLogs = _selectedExercise == 'Összes'
            ? _logs
            : _logs.where((l) => l.exerciseName == _selectedExercise).toList();

        // Diagramhoz pontok kinyerése
        final chartLogs = filteredLogs.take(10).toList().reversed.toList();

        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: _theme.backgroundColor,
            elevation: 0,
            title: const Text('Edzés & Súly Fejlődés 📈', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: _theme.primaryColor))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gyakorlat választó szűrő
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: _theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF26364A)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _exerciseNames.contains(_selectedExercise) ? _selectedExercise : 'Összes',
                            dropdownColor: _theme.cardColor,
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            items: _exerciseNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedExercise = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fejlődési Vonaldiagram kártya
                      if (_selectedExercise != 'Összes' && chartLogs.length >= 2)
                        Container(
                          padding: const EdgeInsets.all(18),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: _theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF26364A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Súly Trend ($_selectedExercise)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(
                                    'Legutóbbi: ${chartLogs.last.weightKg} kg',
                                    style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 110,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: ExerciseChartPainter(
                                    logs: chartLogs,
                                    lineColor: _theme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Text('Elvégzett Szériák Előzményei', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),

                      if (filteredLogs.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF1B2A3D)),
                          ),
                          child: const Center(
                            child: Text('Még nincs rögzített edzésnapló.', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 13)),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredLogs.length,
                          itemBuilder: (ctx, i) {
                            final log = filteredLogs[i];
                            final dateStr = "${log.date.year}.${log.date.month.toString().padLeft(2, '0')}.${log.date.day.toString().padLeft(2, '0')} ${log.date.hour.toString().padLeft(2, '0')}:${log.date.minute.toString().padLeft(2, '0')}";
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _theme.cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF26364A)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(log.exerciseName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(dateStr, style: const TextStyle(color: Color(0xFF55687D), fontSize: 11)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _theme.primaryColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: _theme.primaryColor),
                                    ),
                                    child: Text(
                                      '${log.weightKg} kg × ${log.reps} ism.',
                                      style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 13),
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
      },
    );
  }
}

class ExerciseChartPainter extends CustomPainter {
  final List<ProgressLogItem> logs;
  final Color lineColor;

  ExerciseChartPainter({required this.logs, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.length < 2) return;

    final minW = logs.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
    final maxW = logs.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
    final range = (maxW - minW == 0) ? 1.0 : (maxW - minW);

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..color = Colors.white;

    final path = Path();
    for (int i = 0; i < logs.length; i++) {
      final x = (size.width / (logs.length - 1)) * i;
      final normalizedY = (logs[i].weightKg - minW) / range;
      final y = size.height - (normalizedY * (size.height - 20) + 10);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

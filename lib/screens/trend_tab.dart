import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightEntry {
  final String id;
  final double weight;
  final DateTime date;

  WeightEntry({
    required this.id,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'weight': weight,
        'date': date.toIso8601String(),
      };

  factory WeightEntry.fromMap(Map<String, dynamic> map) => WeightEntry(
        id: map['id'] ?? UniqueKey().toString(),
        weight: (map['weight'] as num).toDouble(),
        date: DateTime.parse(map['date']),
      );
}

class TrendTab extends StatefulWidget {
  const TrendTab({super.key});

  @override
  State<TrendTab> createState() => _TrendTabState();
}

class _TrendTabState extends State<TrendTab> {
  final List<WeightEntry> _entries = [];
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  double _targetWeight = 80.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString('trend_weight_entries');
    _targetWeight = prefs.getDouble('trend_target_weight') ?? 80.0;

    if (rawData != null && rawData.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(rawData);
      _entries.clear();
      _entries.addAll(decoded.map((e) => WeightEntry.fromMap(e)).toList());
      _entries.sort((a, b) => b.date.compareTo(a.date));
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String rawData = jsonEncode(_entries.map((e) => e.toMap()).toList());
    await prefs.setString('trend_weight_entries', rawData);
  }

  Future<void> _saveTargetWeight(double target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('trend_target_weight', target);
    setState(() {
      _targetWeight = target;
    });
  }

  double? get _weeklyAverage {
    if (_entries.isEmpty) return null;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final recent = _entries.where((e) => e.date.isAfter(sevenDaysAgo)).toList();
    if (recent.isEmpty) return _entries.first.weight;
    final sum = recent.fold(0.0, (s, item) => s + item.weight);
    return sum / recent.length;
  }

  void _addEntry() {
    final double? weight =
        double.tryParse(_weightController.text.replaceAll(',', '.'));
    if (weight == null || weight <= 0) return;

    final newEntry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: weight,
      date: DateTime.now(),
    );

    setState(() {
      _entries.insert(0, newEntry);
      _entries.sort((a, b) => b.date.compareTo(a.date));
      _weightController.clear();
    });

    _saveEntries();
    Navigator.pop(context);
  }

  void _showAddDialog() {
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
              const Text('Új Testsúly Mérés',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pl. 83.4',
                  hintStyle: const TextStyle(color: Color(0xFF55687D)),
                  suffixText: 'kg',
                  suffixStyle: const TextStyle(
                      color: Color(0xFF28D5CF), fontWeight: FontWeight.bold),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _addEntry,
                  child: const Text('RÖGZÍTÉS',
                      style: TextStyle(
                          color: Color(0xFF07101B),
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTargetWeightDialog() {
    _targetWeightController.text = _targetWeight.toString();
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
              const Text('Célsúly Módosítása',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: _targetWeightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pl. 75.0',
                  hintStyle: const TextStyle(color: Color(0xFF55687D)),
                  suffixText: 'kg',
                  suffixStyle: const TextStyle(
                      color: Color(0xFFFF356D), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0xFF0D1825),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF26364A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF356D)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final t = double.tryParse(
                        _targetWeightController.text.replaceAll(',', '.'));
                    if (t != null && t > 0) {
                      _saveTargetWeight(t);
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('CÉL MENTÉSE',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
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
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF28D5CF))),
      );
    }

    final sortedForChart = List<WeightEntry>.from(_entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B),
        elevation: 0,
        title: const Text(
          'Súlykövetés & Trend',
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
              child: const Icon(Icons.flag_outlined,
                  color: Color(0xFFFF356D), size: 20),
            ),
            onPressed: _showTargetWeightDialog,
          ),
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
            onPressed: _showAddDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _entries.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28D5CF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, color: Color(0xFF07101B)),
                label: const Text('Első súly rögzítése',
                    style: TextStyle(
                        color: Color(0xFF07101B),
                        fontWeight: FontWeight.bold)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statisztikai kártyák
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Aktuális Súly',
                          '${_entries.first.weight} kg',
                          const Color(0xFF28D5CF),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Heti Átlag',
                          _weeklyAverage != null
                              ? '${_weeklyAverage!.toStringAsFixed(1)} kg'
                              : '-',
                          const Color(0xFFFFB800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Célsúly',
                          '$_targetWeight kg',
                          const Color(0xFFFF356D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Diagram Kártya
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Súlygörbe és Célvonal',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Row(
                              children: [
                                Container(
                                    width: 10,
                                    height: 3,
                                    color: const Color(0xFFFF356D)),
                                const SizedBox(width: 4),
                                const Text('Cél',
                                    style: TextStyle(
                                        color: Color(0xFF91A2B5),
                                        fontSize: 11)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: AdvancedWeightChartPainter(
                              entries: sortedForChart,
                              targetWeight: _targetWeight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Mérési Napló',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final item = _entries[index];
                      final diffToTarget = item.weight - _targetWeight;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1825),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF26364A)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.weight} kg',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(
                                  DateFormat('yyyy. MM. dd. - HH:mm')
                                      .format(item.date),
                                  style: const TextStyle(
                                      color: Color(0xFF91A2B5), fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${diffToTarget >= 0 ? "+" : ""}${diffToTarget.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                    color: diffToTarget > 0
                                        ? const Color(0xFFFFB800)
                                        : const Color(0xFF28D5CF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Color(0xFFFF356D), size: 20),
                                  onPressed: () {
                                    setState(() => _entries.removeAt(index));
                                    _saveEntries();
                                  },
                                ),
                              ],
                            )
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

  Widget _buildStatCard(String title, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1825),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26364A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 15)),
        ],
      ),
    );
  }
}

class AdvancedWeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final double targetWeight;

  AdvancedWeightChartPainter(
      {required this.entries, required this.targetWeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFF28D5CF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF28D5CF)
      ..style = PaintingStyle.fill;

    final targetPaint = Paint()
      ..color = const Color(0xFFFF356D)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = const Color(0xFF26364A).withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    double minVal = entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    double maxVal = entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b);

    minVal = minVal < targetWeight ? minVal : targetWeight;
    maxVal = maxVal > targetWeight ? maxVal : targetWeight;

    final pad = (maxVal - minVal == 0) ? 2.0 : (maxVal - minVal) * 0.15;
    minVal -= pad;
    maxVal += pad;

    // Célsúly szaggatott vonal kirajzolása
    final targetY = size.height - ((targetWeight - minVal) / (maxVal - minVal) * size.height);
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(startX + dashWidth, targetY),
        targetPaint,
      );
      startX += dashWidth + dashSpace;
    }

    if (entries.length == 1) {
      final y = size.height - ((entries[0].weight - minVal) / (maxVal - minVal) * size.height);
      canvas.drawCircle(Offset(size.width / 2, y), 6, dotPaint);
      return;
    }

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      final x = (size.width / (entries.length - 1)) * i;
      final y = size.height - ((entries[i].weight - minVal) / (maxVal - minVal) * size.height);
      final point = Offset(x, y);
      points.add(point);

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
  bool shouldRepaint(covariant AdvancedWeightChartPainter oldDelegate) => true;
}
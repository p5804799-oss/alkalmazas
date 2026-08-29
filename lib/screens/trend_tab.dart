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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] ?? UniqueKey().toString(),
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }
}

class TrendTab extends StatefulWidget {
  const TrendTab({super.key});

  @override
  State<TrendTab> createState() => _TrendTabState();
}

class _TrendTabState extends State<TrendTab> {
  final List<WeightEntry> _entries = [];
  final TextEditingController _weightController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString('trend_weight_entries');
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

  void _addEntry() {
    final double? weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kérlek valós testsúlyt adj meg!'),
          backgroundColor: Color(0xFFFF356D),
        ),
      );
      return;
    }

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

  void _deleteEntry(String id) {
    setState(() {
      _entries.removeWhere((item) => item.id == id);
    });
    _saveEntries();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mérés sikeresen törölve!'),
        backgroundColor: Color(0xFF0D1825),
      ),
    );
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
              const Text(
                'Új Súly Rögzítése',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pl. 84.5',
                  hintStyle: const TextStyle(color: Color(0xFF55687D)),
                  suffixText: 'kg',
                  suffixStyle: const TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.bold),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _addEntry,
                  child: const Text(
                    'RÖGZÍTÉS',
                    style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold),
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

    final sortedForChart = List<WeightEntry>.from(_entries)..sort((a, b) => a.date.compareTo(b.date));

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
              child: const Icon(Icons.add, color: Color(0xFF28D5CF), size: 20),
            ),
            onPressed: _showAddDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.show_chart, size: 60, color: Color(0xFF26364A)),
                  const SizedBox(height: 16),
                  const Text(
                    'Még nincs rögzített adatod',
                    style: TextStyle(color: Color(0xFF91A2B5), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28D5CF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add, color: Color(0xFF07101B)),
                    label: const Text('Első súly rögzítése', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            const Text(
                              'Időbeli Változás',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              'Aktuális: ${_entries.first.weight} kg',
                              style: const TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: WeightChartPainter(entries: sortedForChart),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mérési Előzmények',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final item = _entries[index];
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
                                    color: const Color(0xFF111F2E),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.monitor_weight_outlined, color: Color(0xFF28D5CF), size: 20),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.weight} kg',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      DateFormat('yyyy. MM. dd. - HH:mm').format(item.date),
                                      style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF356D), size: 20),
                              onPressed: () => _deleteEntry(item.id),
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

class WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;

  WeightChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFF28D5CF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFFF356D)
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

    double minWeight = entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    double maxWeight = entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b);

    if (minWeight == maxWeight) {
      minWeight -= 1;
      maxWeight += 1;
    } else {
      final pad = (maxWeight - minWeight) * 0.1;
      minWeight -= pad;
      maxWeight += pad;
    }

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      final x = (size.width / (entries.length - 1)) * i;
      final normalized = (entries[i].weight - minWeight) / (maxWeight - minWeight);
      final y = size.height - (normalized * size.height);
      final point = Offset(x, y);
      points.add(point);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WeightChartPainter oldDelegate) => true;
}
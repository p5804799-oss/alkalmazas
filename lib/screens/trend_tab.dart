import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class TrendTab extends StatefulWidget {
  const TrendTab({super.key});

  @override
  State<TrendTab> createState() => _TrendTabState();
}

class _TrendTabState extends State<TrendTab> {
  List<DailyWeightLog> _weights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await StorageService.getWeights();
    setState(() {
      _weights = list;
      _isLoading = false;
    });
  }

  void _showAddWeightDialog() {
    final weightCtrl = TextEditingController();
    String workoutType = 'Push';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Napi súly & Edzés', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Testsúly (kg)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: workoutType,
                dropdownColor: const Color(0xFF334155),
                decoration: const InputDecoration(labelText: 'Edzésnap', border: OutlineInputBorder()),
                items: ['Push', 'Pull', 'Legs', 'Upper', 'Lower', 'Full Body', 'Cardio', 'Pihenőnap'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setDlgState(() => workoutType = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Mégse')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () async {
                final w = double.tryParse(weightCtrl.text);
                if (w != null) {
                  final item = DailyWeightLog(
                    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    weight: w,
                    workoutType: workoutType,
                  );
                  await StorageService.saveWeight(item);
                  Navigator.pop(ctx);
                  _load();
                }
              },
              child: const Text('Mentés', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));

    return Scaffold(
      appBar: AppBar(title: const Text('Súly & Edzéskövető')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        onPressed: _showAddWeightDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Súlymérés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _weights.isEmpty
          ? const Center(child: Text('Még nincs rögzített testsúlyadat.', style: TextStyle(color: Colors.white54)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _weights.length,
              itemBuilder: (ctx, i) {
                final w = _weights[_weights.length - 1 - i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFF10B981), child: Icon(Icons.fitness_center, color: Colors.white, size: 18)),
                    title: Text('${w.weight} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                    subtitle: Text('${w.date}  •  Edzés: ${w.workoutType}', style: const TextStyle(color: Colors.white60)),
                  ),
                );
              },
            ),
    );
  }
}

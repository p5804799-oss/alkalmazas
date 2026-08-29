import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class FoodsTab extends StatefulWidget {
  const FoodsTab({super.key});

  @override
  State<FoodsTab> createState() => _FoodsTabState();
}

class _FoodsTabState extends State<FoodsTab> {
  List<FoodItem> _allFoods = [];
  List<FoodItem> _filteredFoods = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final foods = await StorageService.loadFoods();
    setState(() {
      _allFoods = foods;
      _filteredFoods = foods;
      _isLoading = false;
    });
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query;
      _filteredFoods = _allFoods.where((f) =>
          f.name.toLowerCase().contains(query.toLowerCase()) ||
          f.category.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void _showLogFoodDialog(FoodItem food) {
    final amountCtrl = TextEditingController(text: '100');
    String mealType = 'Ebéd';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final amt = double.tryParse(amountCtrl.text) ?? 100.0;
          final ratio = amt / 100.0;

          return AlertDialog(
            backgroundColor: const Color(0xFF131B2E),
            title: Text(food.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: mealType,
                  dropdownColor: const Color(0xFF1E293B),
                  decoration: const InputDecoration(labelText: 'Étkezés', border: OutlineInputBorder()),
                  items: ['Reggeli', 'Ebéd', 'Vacsora', 'Nasi']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => setDlgState(() => mealType = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Mennyiség (${food.unit})', border: const OutlineInputBorder()),
                  onChanged: (v) => setDlgState(() {}),
                ),
                const SizedBox(height: 12),
                Text(
                  'Összesen: ${(food.kcal * ratio).toInt()} kcal • ${(food.protein * ratio).toStringAsFixed(1)} g P',
                  style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Mégse')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2E63)),
                onPressed: () async {
                  final meal = LoggedMeal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: DateTime.now().toIso8601String().substring(0, 10),
                    mealType: mealType,
                    name: food.name,
                    amount: amt,
                    unit: food.unit,
                    kcal: food.kcal * ratio,
                    protein: food.protein * ratio,
                    carbs: food.carbs * ratio,
                    fat: food.fat * ratio,
                  );
                  await StorageService.saveMeal(meal);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('🥗 ${food.name} rögzítve!')),
                  );
                },
                child: const Text('Naplózás', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF2E63)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lidl Adatbázis (104 tétel)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Keresés Lidl termék szerint...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF131B2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredFoods.length,
              itemBuilder: (ctx, i) {
                final f = _filteredFoods[i];
                return Card(
                  color: const Color(0xFF131B2E),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(
                      '${f.category} • ${f.kcal.toInt()} kcal / ${f.unit} • P: ${f.protein}g | CH: ${f.carbs}g | Zs: ${f.fat}g',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF00E5FF)),
                      onPressed: () => _showLogFoodDialog(f),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
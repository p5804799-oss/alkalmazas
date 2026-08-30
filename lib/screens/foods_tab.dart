import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class FoodItem {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
        id: map['id'] ?? UniqueKey().toString(),
        name: map['name'] ?? '',
        calories: map['calories'] ?? 0,
        protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      );
}

class FoodsTab extends StatefulWidget {
  const FoodsTab({super.key});

  @override
  State<FoodsTab> createState() => _FoodsTabState();
}

class _FoodsTabState extends State<FoodsTab> {
  final ThemeService _theme = ThemeService();
  final List<FoodItem> _foods = [];
  String _searchQuery = '';

  final List<FoodItem> _defaultFoods = [
    FoodItem(id: '1', name: 'Csirkemell filé (sült, 100g)', calories: 165, protein: 31.0, carbs: 0.0, fat: 3.6),
    FoodItem(id: '2', name: 'Basmati rizs (főtt, 100g)', calories: 130, protein: 2.7, carbs: 28.0, fat: 0.3),
    FoodItem(id: '3', name: 'Zabpehely (100g)', calories: 375, protein: 13.5, carbs: 60.0, fat: 7.0),
    FoodItem(id: '4', name: 'Tejsavó fehérje (1 adag, 30g)', calories: 120, protein: 24.0, carbs: 2.0, fat: 1.5),
    FoodItem(id: '5', name: 'Egész tojás (1 db L-es, ~60g)', calories: 85, protein: 7.5, carbs: 0.5, fat: 6.0),
    FoodItem(id: '6', name: 'Sovány túró (100g)', calories: 80, protein: 14.0, carbs: 3.8, fat: 0.5),
    FoodItem(id: '7', name: 'Tonhalkonzerv sós lében (100g)', calories: 110, protein: 25.5, carbs: 0.0, fat: 1.0),
    FoodItem(id: '8', name: 'Avokádó (100g)', calories: 160, protein: 2.0, carbs: 8.5, fat: 14.7),
  ];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString('custom_food_database');
    setState(() {
      _foods.clear();
      if (rawData != null && rawData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawData);
        _foods.addAll(decoded.map((f) => FoodItem.fromMap(f)).toList());
      } else {
        _foods.addAll(_defaultFoods);
        _saveFoods();
      }
    });
  }

  Future<void> _saveFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_foods.map((f) => f.toMap()).toList());
    await prefs.setString('custom_food_database', data);
  }

  void _showAddFoodDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

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
              const Text('Új Étel Hozzáadása', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Étel megnevezése',
                  labelStyle: const TextStyle(color: Color(0xFF91A2B5)),
                  filled: true,
                  fillColor: const Color(0xFF0D1825),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Kalória (kcal / adag)',
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
                      controller: proteinCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Fehérje (g)',
                        labelStyle: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFF0D1825),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: carbsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Szénhidrát (g)',
                        labelStyle: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFF0D1825),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: fatCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Zsír (g)',
                        labelStyle: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11),
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
                    final c = int.tryParse(calCtrl.text) ?? 0;
                    final p = double.tryParse(proteinCtrl.text) ?? 0.0;
                    final ch = double.tryParse(carbsCtrl.text) ?? 0.0;
                    final f = double.tryParse(fatCtrl.text) ?? 0.0;
                    if (n.isNotEmpty && c > 0) {
                      setState(() {
                        _foods.insert(
                          0,
                          FoodItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: n,
                            calories: c,
                            protein: p,
                            carbs: ch,
                            fat: f,
                          ),
                        );
                      });
                      _saveFoods();
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('MENTÉS ADATBÁZISBA', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
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
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        final filteredFoods = _foods.where((f) {
          if (_searchQuery.isEmpty) return true;
          return f.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFF07101B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF07101B),
            elevation: 0,
            title: const Text('Étel Adatbázis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1825),
                    border: Border.all(color: const Color(0xFF26364A)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.add, color: _theme.primaryColor, size: 20),
                ),
                onPressed: _showAddFoodDialog,
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Keresés az ételek között...',
                    hintStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: _theme.primaryColor, size: 20),
                    filled: true,
                    fillColor: const Color(0xFF0D1825),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF26364A))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _theme.primaryColor)),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFoods.length,
                    itemBuilder: (ctx, i) {
                      final item = filteredFoods[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1825),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF26364A)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.calories} kcal  •  F: ${item.protein}g  Sz: ${item.carbs}g  Zs: ${item.fat}g',
                                    style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: _theme.secondaryColor, size: 18),
                              onPressed: () {
                                setState(() => _foods.remove(item));
                                _saveFoods();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

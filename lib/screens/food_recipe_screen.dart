import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../models/food_item.dart';
import '../providers/app_state.dart';

class FoodRecipeScreen extends StatefulWidget {
  const FoodRecipeScreen({super.key});

  @override
  State<FoodRecipeScreen> createState() => _FoodRecipeScreenState();
}

class _FoodRecipeScreenState extends State<FoodRecipeScreen> {
  late List<FoodItem> _foods;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _foods = FoodDatabase.excelLidlRecipes;
  }

  void _toggleFavorite(FoodItem food) {
    setState(() {
      food.isFavorite = !food.isFavorite;
    });
  }

  void _showAddFoodModal() {
    final theme = ThemeService();
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final pController = TextEditingController();
    final cController = TextEditingController();
    final fController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🍳 Új Étel / Recept Rögzítése', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Étel neve',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: theme.backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMacroInput('Kalória (kcal)', calController, theme)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMacroInput('Fehérje (g)', pController, theme)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildMacroInput('Szénhidrát (g)', cController, theme)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMacroInput('Zsír (g)', fController, theme)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.black),
                  onPressed: () {
                    if (nameController.text.isNotEmpty && calController.text.isNotEmpty) {
                      final newFood = FoodItem(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
                        category: 'Egyéni',
                        calories: int.tryParse(calController.text) ?? 0,
                        protein: int.tryParse(pController.text) ?? 0,
                        carbs: int.tryParse(cController.text) ?? 0,
                        fat: int.tryParse(fController.text) ?? 0,
                      );
                      setState(() {
                        _foods.add(newFood);
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Új étel sikeresen rögzítve!')));
                    }
                  },
                  child: const Text('Mentés az Adatbázisba', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroInput(String label, TextEditingController controller, ThemeService theme) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: theme.backgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();
    final appState = context.watch<AppState>();
    
    final filteredFoods = _foods.where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final favoriteFoods = filteredFoods.where((f) => f.isFavorite).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Keresés a Lidl/Excel receptekben...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Összes Recept'),
              Tab(text: '⭐ Kedvencek'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFoodList(filteredFoods, theme, appState),
                _buildFoodList(favoriteFoods, theme, appState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<FoodItem> foodList, ThemeService theme, AppState appState) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: _showAddFoodModal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: foodList.length,
        itemBuilder: (context, index) {
          final food = foodList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(food.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                    IconButton(
                      icon: Icon(food.isFavorite ? Icons.star : Icons.star_border, color: food.isFavorite ? Colors.amber : Colors.grey),
                      onPressed: () => _toggleFavorite(food),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor.withValues(alpha: 0.2), foregroundColor: theme.primaryColor, elevation: 0, minimumSize: const Size(80, 32)),
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Megevés', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        appState.addFoodMeal(food.calories, food.protein, food.carbs, food.fat);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🍽️ Rögzítve: ${food.name} (+${food.calories} kcal)')));
                      },
                    )
                  ],
                ),
                Text(food.category, style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🔥 ${food.calories} kcal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('🥩 ${food.protein}g', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('🍚 ${food.carbs}g', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('🥑 ${food.fat}g', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

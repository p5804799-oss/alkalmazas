import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../models/food_item.dart';

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

  void _shareRecipe(FoodItem food) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📲 "${food.name}" megosztva a barátokkal!'),
        backgroundColor: const Color(0xFF00E676),
      ),
    );
  }

  void _showAddFoodModal() {
    final theme = ThemeService();
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Új Étel / Recept Rögzítése', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Étel neve',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.primaryColor.withValues(alpha: 0.5))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMacroInput('Kcal', theme)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroInput('Fehérje (g)', theme)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMacroInput('Szénh. (g)', theme)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroInput('Zsír (g)', theme)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.black),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Rögzítés az Adatbázisba', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInput(String label, ThemeService theme) {
    return TextField(
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();
    
    // Szűrés keresés alapján
    final filteredFoods = _foods.where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    // Kedvencek külön listázva
    final favoriteFoods = filteredFoods.where((f) => f.isFavorite).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Kereső sáv
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
          
          // Tabok
          TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Összes Recept'),
              Tab(text: '⭐ Kedvencek'),
            ],
          ),
          
          // Listák
          Expanded(
            child: TabBarView(
              children: [
                _buildFoodList(filteredFoods, theme),
                _buildFoodList(favoriteFoods, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<FoodItem> foodList, ThemeService theme) {
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
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.blueAccent),
                      onPressed: () => _shareRecipe(food),
                    ),
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

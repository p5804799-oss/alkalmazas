import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class RecipesTab extends StatefulWidget {
  const RecipesTab({super.key});

  @override
  State<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<RecipesTab> {
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  String _searchQuery = '';
  String _selectedCategory = 'Összes';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final recipes = await StorageService.loadRecipes();
    setState(() {
      _allRecipes = recipes;
      _filteredRecipes = recipes;
      _isLoading = false;
    });
  }

  void _filter() {
    setState(() {
      _filteredRecipes = _allRecipes.where((r) {
        final matchesSearch = r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.ingredients.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCat = _selectedCategory == 'Összes' || r.category == _selectedCategory;
        return matchesSearch && matchesCat;
      }).toList();
    });
  }

  void _showLogRecipeDialog(Recipe recipe) {
    String mealType = 'Ebéd';
    double portions = 1.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF131B2E),
          title: Text(recipe.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Adag:', style: TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: portions > 0.5 ? () => setDlgState(() => portions -= 0.5) : null,
                      ),
                      Text('$portions', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setDlgState(() => portions += 0.5),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Bevitel: ${(recipe.kcal * portions).toInt()} kcal • ${(recipe.protein * portions).toStringAsFixed(1)} g P',
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
                  name: recipe.name,
                  amount: portions,
                  unit: 'adag',
                  kcal: recipe.kcal * portions,
                  protein: recipe.protein * portions,
                  carbs: recipe.carbs * portions,
                  fat: recipe.fat * portions,
                );
                await StorageService.saveMeal(meal);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🍽 ${recipe.name} rögzítve!')),
                );
              },
              child: const Text('Naplózás', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF2E63)));
    }

    final categories = ['Összes', ..._allRecipes.map((r) => r.category).where((c) => c.isNotEmpty).toSet()];

    return Scaffold(
      appBar: AppBar(title: const Text('Recepttár (55 recept)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) {
                _searchQuery = val;
                _filter();
              },
              decoration: InputDecoration(
                hintText: 'Keresés recept vagy hozzávaló alapján...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF131B2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFF2E63),
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                      _filter();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRecipes.length,
              itemBuilder: (ctx, i) {
                final r = _filteredRecipes[i];
                return Card(
                  color: const Color(0xFF131B2E),
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ExpansionTile(
                    title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(
                      '🔥 ${r.kcal.toInt()} kcal  •  🥩 ${r.protein.toStringAsFixed(1)} g P  •  ${r.servings.toInt()} adag',
                      style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 13),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🥗 Hozzávalók:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(r.ingredients.replaceAll('•', '\n•'), style: const TextStyle(color: Colors.white60, fontSize: 13)),
                            const SizedBox(height: 12),
                            const Text('👨‍🍳 Elkészítés:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(r.instructions, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                            if (r.note.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text('💡 Megjegyzés: ${r.note}', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2E63)),
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text('Megeszem / Naplózás', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                onPressed: () => _showLogRecipeDialog(r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
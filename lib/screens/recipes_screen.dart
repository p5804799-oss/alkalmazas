import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/theme_service.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final ThemeService _theme = ThemeService();
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'Összes';
  String _searchQuery = '';

  final List<String> _categories = ['Összes', 'Reggeli', 'Ebéd / Vacsora', 'Snack / Esti étkezés'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openRecipeDetailSheet(RecipeItem recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFF26364A), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _theme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(recipe.category, style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Text('⏱ ${recipe.prepTime}', style: const TextStyle(color: Color(0xFF91A2B5), fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(recipe.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1F2F42)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroTag('Kalória', '${recipe.calories} kcal', Colors.white),
                      _buildMacroTag('Fehérje', '${recipe.protein}g', _theme.primaryColor),
                      _buildMacroTag('Szénhidrát', '${recipe.carbs}g', _theme.secondaryColor),
                      _buildMacroTag('Zsír', '${recipe.fat}g', const Color(0xFFFFB300)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text('HOZZÁVALÓK', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8)),
                const SizedBox(height: 10),
                ...recipe.ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: _theme.primaryColor, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ing, style: const TextStyle(color: Color(0xFFD3E0EA), fontSize: 14))),
                        ],
                      ),
                    )),
                const SizedBox(height: 22),
                Text('ELKÉSZÍTÉS', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8)),
                const SizedBox(height: 10),
                Text(
                  recipe.instructions,
                  style: const TextStyle(color: Color(0xFFD3E0EA), fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMacroTag(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        final filteredList = kBuiltInRecipes.where((rec) {
          final matchesCat = _selectedCategory == 'Összes' || rec.category.contains(_selectedCategory);
          final matchesQuery = _searchQuery.isEmpty ||
              rec.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              rec.ingredients.any((i) => i.toLowerCase().contains(_searchQuery.toLowerCase()));
          return matchesCat && matchesQuery;
        }).toList();

        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: _theme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: _theme.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Fitnesz Recepttár', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Keresés ételnév vagy alapanyag alapján...',
                    hintStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: _theme.primaryColor, size: 20),
                    filled: true,
                    fillColor: _theme.cardColor,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF26364A))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _theme.primaryColor)),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: _categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat, style: TextStyle(color: isSel ? const Color(0xFF07101B) : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        selected: isSel,
                        selectedColor: _theme.primaryColor,
                        backgroundColor: _theme.cardColor,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(child: Text('Nincs találat.', style: TextStyle(color: Color(0xFF91A2B5))))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, idx) {
                          final rec = filteredList[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: _theme.cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFF1F2F42)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              title: Text(rec.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '⏱ ${rec.prepTime}  •  🔥 ${rec.calories} kcal  •  💪 ${rec.protein}g Fehérje',
                                  style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12),
                                ),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios_rounded, color: _theme.primaryColor, size: 16),
                              onTap: () => _openRecipeDetailSheet(rec),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

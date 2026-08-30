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
  String _selectedCategory = 'Összes';
  final List<String> _categories = ['Összes', 'Reggeli', 'Ebéd / Vacsora', 'Snack'];

  @override
  Widget build(BuildContext context) {
    final filteredList = kLidlExcelRecipes.where((rec) {
      if (_selectedCategory == 'Összes') return true;
      return rec.category.contains(_selectedCategory);
    }).toList();

    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(backgroundColor: _theme.backgroundColor, title: const Text('Lidl & Excel Recepttár', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          body: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: _categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat, style: TextStyle(color: isSel ? const Color(0xFF07101B) : Colors.white, fontWeight: FontWeight.bold)),
                        selected: isSel,
                        selectedColor: _theme.primaryColor,
                        backgroundColor: _theme.cardColor,
                        onSelected: (val) { if (val) setState(() => _selectedCategory = cat); },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, idx) {
                    final rec = filteredList[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(rec.category, style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text('⏱ ${rec.prepTime}', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(rec.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                          const SizedBox(height: 8),
                          Text('🔥 ${rec.calories} kcal  •  💪 ${rec.protein}g Fehérje  •  🍞 ${rec.carbs}g Szénhidrát', style: const TextStyle(color: Color(0xFFD3E0EA), fontSize: 12)),
                        ],
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

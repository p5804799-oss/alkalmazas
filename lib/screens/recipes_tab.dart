import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeItem {
  final String id;
  final String title;
  final String author;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> ingredients;
  final String instructions;

  RecipeItem({
    required this.id,
    required this.title,
    this.author = 'Én',
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.instructions,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'author': author,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'ingredients': ingredients,
        'instructions': instructions,
      };

  factory RecipeItem.fromMap(Map<String, dynamic> map) => RecipeItem(
        id: map['id'] ?? UniqueKey().toString(),
        title: map['title'] ?? 'Névtelen recept',
        author: map['author'] ?? 'Én',
        calories: map['calories'] ?? 0,
        protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
        ingredients: List<String>.from(map['ingredients'] ?? []),
        instructions: map['instructions'] ?? '',
      );
}

class RecipesTab extends StatefulWidget {
  const RecipesTab({super.key});

  @override
  State<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<RecipesTab> {
  final List<RecipeItem> _recipes = [];
  bool _isLoading = true;

  final List<RecipeItem> _defaultPresets = [
    RecipeItem(
      id: 'default_1',
      title: 'Anabolikus Zabkása',
      author: 'Fütyfürütty Séf',
      calories: 450,
      protein: 38.0,
      carbs: 55.0,
      fat: 8.0,
      ingredients: [
        '80g finomszemű zabpehely',
        '30g tejsavófehérje (csokis vagy vaníliás)',
        '150ml mandulatej vagy víz',
        '10g mogyoróvaj a tetejére',
      ],
      instructions:
          'A zabpelyhet öntsd le meleg vízzel vagy növényi tejjel, hagyd állni 3 percig. Keverd hozzá a fehérjeport és díszítsd mogyoróvajjal!',
    ),
    RecipeItem(
      id: 'default_2',
      title: 'Fitnesz Csirkemell & Játszi Rizs',
      author: 'Fütyfürütty Séf',
      calories: 520,
      protein: 52.0,
      carbs: 60.0,
      fat: 6.0,
      ingredients: [
        '200g csirkemell filé kockázva',
        '80g basmati rizs (nyersen mérve)',
        'Só, bors, fokhagymapor, füstölt paprika',
        '100g párolt brokkoli',
      ],
      instructions:
          'A rizst kétszeres vízben megfőzzük. A csirkemellet fűszerezzük, majd tapadásmentes serpenyőben aranybarnára pirítjuk. Brokkolival tálaljuk.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString('custom_recipes_list');

    setState(() {
      _recipes.clear();
      if (rawData != null && rawData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawData);
        _recipes.addAll(decoded.map((r) => RecipeItem.fromMap(r)).toList());
      } else {
        _recipes.addAll(_defaultPresets);
      }
      _isLoading = false;
    });
  }

  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_recipes.map((r) => r.toMap()).toList());
    await prefs.setString('custom_recipes_list', data);
  }

  void _showAddRecipeDialog() {
    final titleCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    final ingredientsCtrl = TextEditingController();
    final instructionsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF07101B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF26364A)),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Új Recept Létrehozása',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF91A2B5)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInputField(titleCtrl, 'Recept neve (pl. Fehérjés Palacsinta)'),
              const SizedBox(height: 10),
              _buildInputField(calCtrl, 'Összes kalória (kcal)', isNumber: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _buildInputField(proteinCtrl, 'Fehérje (g)',
                          isNumber: true)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildInputField(carbsCtrl, 'Szénhidrát (g)',
                          isNumber: true)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildInputField(fatCtrl, 'Zsír (g)',
                          isNumber: true)),
                ],
              ),
              const SizedBox(height: 12),
              _buildInputField(
                ingredientsCtrl,
                'Hozzávalók (minden hozzávalót új sorba írj)',
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                instructionsCtrl,
                'Elkészítés leírása (lépések részletesen)',
                maxLines: 4,
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
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    final cal = int.tryParse(calCtrl.text) ?? 0;
                    final p = double.tryParse(proteinCtrl.text) ?? 0.0;
                    final c = double.tryParse(carbsCtrl.text) ?? 0.0;
                    final f = double.tryParse(fatCtrl.text) ?? 0.0;
                    final ingText = ingredientsCtrl.text.trim();
                    final instText = instructionsCtrl.text.trim();

                    if (title.isEmpty) return;

                    final ingList = ingText.isNotEmpty
                        ? ingText
                            .split('\n')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList()
                        : <String>[];

                    final newRecipe = RecipeItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      author: 'Én',
                      calories: cal,
                      protein: p,
                      carbs: c,
                      fat: f,
                      ingredients: ingList,
                      instructions: instText,
                    );

                    setState(() {
                      _recipes.insert(0, newRecipe);
                    });
                    _saveRecipes();
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'RECEPT MENTÉSE',
                    style: TextStyle(
                        color: Color(0xFF07101B),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecipeDetails(RecipeItem recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF07101B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF91A2B5)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: Color(0xFF28D5CF)),
                  const SizedBox(width: 6),
                  Text(
                    'Készítő: ${recipe.author}',
                    style: const TextStyle(
                        color: Color(0xFF28D5CF),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1825),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF26364A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroPill('${recipe.calories} kcal', 'Kalória',
                        const Color(0xFF28D5CF)),
                    _buildMacroPill('${recipe.protein}g', 'Fehérje',
                        const Color(0xFF28D5CF)),
                    _buildMacroPill('${recipe.carbs}g', 'Szénhidrát',
                        const Color(0xFFFFB800)),
                    _buildMacroPill('${recipe.fat}g', 'Zsír',
                        const Color(0xFFFF356D)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Hozzávalók',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              if (recipe.ingredients.isEmpty)
                const Text('Nincsenek megadva hozzávalók.',
                    style: TextStyle(color: Color(0xFF55687D), fontSize: 13))
              else
                ...recipe.ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(
                                  color: Color(0xFF28D5CF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(ing,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 20),
              const Text('Elkészítés',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                recipe.instructions.isNotEmpty
                    ? recipe.instructions
                    : 'Nincs megadva elkészítési leírás.',
                style: const TextStyle(
                    color: Color(0xFF91A2B5), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2A3D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF28D5CF)),
                  ),
                ),
                icon: const Icon(Icons.share_rounded, color: Color(0xFF28D5CF)),
                label: const Text(
                  'MEGOSZTÁS BARÁTTAL (Előkészítve)',
                  style: TextStyle(
                      color: Color(0xFF28D5CF), fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'A recept (${recipe.title}, Készítő: ${recipe.author}) megosztásra kész a barátlistádhoz!'),
                      backgroundColor: const Color(0xFF28D5CF),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroPill(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Color(0xFF55687D), fontSize: 10)),
      ],
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String hint,
      {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType:
          isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0D1825),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF26364A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF28D5CF)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF07101B),
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF28D5CF))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B),
        elevation: 0,
        title: const Text(
          'Receptek & Étrend',
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
              child:
                  const Icon(Icons.add, color: Color(0xFF28D5CF), size: 20),
            ),
            onPressed: _showAddRecipeDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _recipes.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28D5CF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showAddRecipeDialog,
                icon: const Icon(Icons.add, color: Color(0xFF07101B)),
                label: const Text('Első recept hozzáadása',
                    style: TextStyle(
                        color: Color(0xFF07101B),
                        fontWeight: FontWeight.bold)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recipes.length,
              itemBuilder: (ctx, i) {
                final recipe = _recipes[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1825),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showRecipeDetails(recipe),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  recipe.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Color(0xFFFF356D), size: 18),
                                onPressed: () {
                                  setState(() => _recipes.removeAt(i));
                                  _saveRecipes();
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 13, color: Color(0xFF28D5CF)),
                              const SizedBox(width: 4),
                              Text(
                                recipe.author,
                                style: const TextStyle(
                                    color: Color(0xFF28D5CF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${recipe.calories} kcal',
                                style: const TextStyle(
                                    color: Color(0xFFFFB800),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14),
                              ),
                              Text(
                                'F: ${recipe.protein}g | Sz: ${recipe.carbs}g | Zs: ${recipe.fat}g',
                                style: const TextStyle(
                                    color: Color(0xFF91A2B5), fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
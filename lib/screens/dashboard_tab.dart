import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recipes_screen.dart';
import '../services/theme_service.dart';
import '../models/recipe_model.dart';
import 'dart:convert';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final ThemeService _theme = ThemeService();

  List<String> _cardOrder = [
    'summary',
    'macro_chart',
    'food_log',
    'workout',
    'water',
    'recipes',
    'weight',
  ];

  String _todayWorkoutType = 'Nincs mára tervezett edzés';
  List<Map<String, dynamic>> _plannedExercises = [];
  List<Map<String, dynamic>> _loggedMeals = [];
  int _waterGlasses = 4;
  double _currentWeight = 78.5;
  double _targetWeight = 75.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList('dashboard_card_order');
    if (savedOrder != null && savedOrder.isNotEmpty) {
      _cardOrder = savedOrder;
    }

    _todayWorkoutType = prefs.getString('daily_workout_type') ?? 'Nincs mára tervezett edzés';
    final rawExercises = prefs.getString('daily_planned_exercises');
    if (rawExercises != null && rawExercises.isNotEmpty) {
      _plannedExercises = List<Map<String, dynamic>>.from(jsonDecode(rawExercises));
    }

    final rawMeals = prefs.getString('daily_logged_meals');
    if (rawMeals != null && rawMeals.isNotEmpty) {
      _loggedMeals = List<Map<String, dynamic>>.from(jsonDecode(rawMeals));
    }

    _waterGlasses = prefs.getInt('daily_water_glasses') ?? 4;
    _currentWeight = prefs.getDouble('user_current_weight') ?? 78.5;
    _targetWeight = prefs.getDouble('user_target_weight') ?? 75.0;

    setState(() {});
  }

  int get _totalConsumedCalories {
    return _loggedMeals.fold(0, (sum, item) => sum + (item['calories'] as int? ?? 0));
  }

  int get _totalConsumedProtein {
    return _loggedMeals.fold(0, (sum, item) => sum + (item['protein'] as int? ?? 0));
  }

  int get _totalConsumedCarbs {
    return _loggedMeals.fold(0, (sum, item) => sum + (item['carbs'] as int? ?? 0));
  }

  int get _totalConsumedFat {
    return _loggedMeals.fold(0, (sum, item) => sum + (item['fat'] as int? ?? 0));
  }

  Future<void> _updateWater(int delta) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _waterGlasses = (_waterGlasses + delta).clamp(0, 20));
    await prefs.setInt('daily_water_glasses', _waterGlasses);
  }

  void _toggleExerciseSet(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final current = _plannedExercises[index]['completedSets'] ?? 0;
      final target = _plannedExercises[index]['targetSets'] ?? 3;
      _plannedExercises[index]['completedSets'] = (current + 1) > target ? 0 : current + 1;
    });
    await prefs.setString('daily_planned_exercises', jsonEncode(_plannedExercises));
  }

  void _showAddMealDialog() {
    String selectedMealType = 'Reggeli';
    RecipeItem? selectedRecipe = kLidlExcelRecipes.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Étkezés Hozzáadása 🍽️', style: TextStyle(color: _theme.primaryColor, fontSize: 18, fontWeight: FontWeight.w900)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('ÉTKEZÉS TÍPUSA:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['Reggeli', 'Ebéd', 'Vacsora', 'Snack'].map((type) {
                    final isSel = selectedMealType == type;
                    return ChoiceChip(
                      label: Text(type, style: TextStyle(color: isSel ? const Color(0xFF07101B) : Colors.white, fontWeight: FontWeight.bold)),
                      selected: isSel,
                      selectedColor: _theme.primaryColor,
                      backgroundColor: _theme.cardColor,
                      onSelected: (val) {
                        if (val) setSheetState(() => selectedMealType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('VÁLASSZ A LIDL / EXCEL RECEPTEKBŐL:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RecipeItem>(
                      value: selectedRecipe,
                      dropdownColor: _theme.cardColor,
                      isExpanded: true,
                      items: kLidlExcelRecipes.map((rec) {
                        return DropdownMenuItem(
                          value: rec,
                          child: Text('${rec.name} (${rec.calories} kcal)', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setSheetState(() => selectedRecipe = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () async {
                      if (selectedRecipe != null) {
                        final newMeal = {
                          'type': selectedMealType,
                          'name': selectedRecipe!.name,
                          'calories': selectedRecipe!.calories,
                          'protein': selectedRecipe!.protein,
                          'carbs': selectedRecipe!.carbs,
                          'fat': selectedRecipe!.fat,
                        };
                        setState(() {
                          _loggedMeals.add(newMeal);
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('daily_logged_meals', jsonEncode(_loggedMeals));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${selectedRecipe!.name} rögzítve! 🚀'), backgroundColor: _theme.primaryColor),
                        );
                      }
                    },
                    child: const Text('HOZZÁADÁS A NAPLÓHOZ ➕', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: _theme.backgroundColor,
            elevation: 0,
            title: RichText(
              text: TextSpan(
                text: 'Dagi',
                style: TextStyle(color: _theme.primaryColor, fontSize: 22, fontWeight: FontWeight.w900),
                children: [
                  TextSpan(text: ' app', style: TextStyle(color: _theme.secondaryColor)),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _cardOrder.map((key) => _buildCardByKey(key)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardByKey(String key) {
    switch (key) {
      case 'summary': return _buildSummaryCard();
      case 'macro_chart': return _buildMacroChartCard();
      case 'food_log': return _buildFoodLogCard();
      case 'workout': return _buildWorkoutCard();
      case 'water': return _buildWaterCard();
      case 'recipes': return _buildRecipesCard();
      case 'weight': return _buildWeightCard();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildSummaryCard() {
    const targetCalories = 2450;
    final calProgress = (_totalConsumedCalories / targetCalories).clamp(0.0, 1.0);

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
              Text('NAPI KALÓRIA & CÉLOK', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 12)),
              Text('$_totalConsumedCalories / $targetCalories kcal', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: calProgress,
            backgroundColor: const Color(0xFF1F2F42),
            color: _theme.primaryColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroItem('Fehérje', '$_totalConsumedProtein g / 180g', (_totalConsumedProtein / 180).clamp(0.0, 1.0), _theme.primaryColor),
              _buildMacroItem('Szénhidrát', '$_totalConsumedCarbs g / 250g', (_totalConsumedCarbs / 250).clamp(0.0, 1.0), _theme.secondaryColor),
              _buildMacroItem('Zsír', '$_totalConsumedFat g / 65g', (_totalConsumedFat / 65).clamp(0.0, 1.0), const Color(0xFFFFB300)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        SizedBox(
          width: 85,
          child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFF1F2F42), color: color, minHeight: 4),
        ),
      ],
    );
  }

  Widget _buildMacroChartCard() {
    final totalP = _totalConsumedProtein == 0 && _totalConsumedCarbs == 0 && _totalConsumedFat == 0 ? 1 : _totalConsumedProtein;
    final totalC = _totalConsumedProtein == 0 && _totalConsumedCarbs == 0 && _totalConsumedFat == 0 ? 1 : _totalConsumedCarbs;
    final totalF = _totalConsumedProtein == 0 && _totalConsumedCarbs == 0 && _totalConsumedFat == 0 ? 1 : _totalConsumedFat;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Icon(Icons.pie_chart_rounded, color: _theme.secondaryColor),
          title: const Text('Valós Makró Eloszlás & Kalória', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text('Bevitt: $_totalConsumedCalories kcal', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _legendDot('Fehérje (${_totalConsumedProtein}g)', _theme.primaryColor),
                      _legendDot('Szénhidrát (${_totalConsumedCarbs}g)', _theme.secondaryColor),
                      _legendDot('Zsír (${_totalConsumedFat}g)', const Color(0xFFFFB300)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 14,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Row(
                        children: [
                          Expanded(flex: totalP, child: Container(color: _theme.primaryColor)),
                          Expanded(flex: totalC, child: Container(color: _theme.secondaryColor)),
                          Expanded(flex: totalF, child: Container(color: const Color(0xFFFFB300))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(String text, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFoodLogCard() {
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
              Text('NAPI ÉTKEZÉSI NAPLÓ', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.w900, fontSize: 12)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                onPressed: _showAddMealDialog,
                icon: const Icon(Icons.add_rounded, color: Color(0xFF07101B), size: 16),
                label: const Text('ETEL HOZZÁADÁSA', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loggedMeals.isEmpty)
            const Text('Még nincs rögzített étkezés ma.', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12))
          else
            Column(
              children: _loggedMeals.asMap().entries.map((entry) {
                final idx = entry.key;
                final meal = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _theme.backgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${meal['type']}: ${meal['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${meal['calories']} kcal • P: ${meal['protein']}g | C: ${meal['carbs']}g | F: ${meal['fat']}g', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () async {
                          setState(() => _loggedMeals.removeAt(idx));
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('daily_logged_meals', jsonEncode(_loggedMeals));
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Icon(Icons.fitness_center_rounded, color: _theme.primaryColor),
          title: Text(_todayWorkoutType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text('${_plannedExercises.length} gyakorlat', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
          children: [
            if (_plannedExercises.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _plannedExercises.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ex = entry.value;
                    final completed = ex['completedSets'] ?? 0;
                    final target = ex['targetSets'] ?? 3;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: _theme.backgroundColor, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(ex['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                          InkWell(
                            onTap: () => _toggleExerciseSet(idx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: completed >= target ? _theme.primaryColor : const Color(0xFF1F2F42), borderRadius: BorderRadius.circular(8)),
                              child: Text('$completed / $target', style: TextStyle(color: completed >= target ? const Color(0xFF07101B) : Colors.white, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_rounded, color: _theme.primaryColor, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vízbevitel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('$_waterGlasses pohár (~${_waterGlasses * 2.5 / 10} L)', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white70), onPressed: () => _updateWater(-1)),
              IconButton(icon: Icon(Icons.add_circle_rounded, color: _theme.primaryColor), onPressed: () => _updateWater(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesCard() {
    final sampleRecipe = kLidlExcelRecipes.first;
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
              Text('LIDL RECEPTAJÁNLÓ', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.w900, fontSize: 11)),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const RecipesScreen())),
                child: Text('ÖSSZES RECEPT', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(sampleRecipe.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text('${sampleRecipe.prepTime} • ${sampleRecipe.protein}g Fehérje • ${sampleRecipe.calories} kcal', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWeightCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_weight_rounded, color: _theme.secondaryColor, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aktuális Súly', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('$_currentWeight kg (Cél: $_targetWeight kg)', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                ],
              ),
            ],
          ),
          Icon(Icons.trending_down_rounded, color: _theme.primaryColor, size: 24),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'recipes_screen.dart';
import '../services/theme_service.dart';
import '../models/recipe_model.dart';
import 'dart:convert';
import 'shared_preferences_helper.dart'; // stub or standard

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final ThemeService _theme = ThemeService();

  List<String> _cardOrder = [
    'summary',
    'workout',
    'water',
    'recipes',
    'weight',
  ];

  bool _isReordering = false;
  String _todayWorkoutType = 'Nincs mára tervezett edzés';
  List<Map<String, dynamic>> _plannedExercises = [];
  int _waterGlasses = 0;
  double _currentWeight = 78.5;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // SharedPreferences betöltés
    final prefs = await import_shared_preferences();
    final savedOrder = prefs.getStringList('dashboard_card_order');
    if (savedOrder != null && savedOrder.isNotEmpty) {
      _cardOrder = savedOrder;
    }

    _todayWorkoutType = prefs.getString('daily_workout_type') ?? 'Nincs mára tervezett edzés';
    final rawExercises = prefs.getString('daily_planned_exercises');
    if (rawExercises != null && rawExercises.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(rawExercises);
      _plannedExercises = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    _waterGlasses = prefs.getInt('daily_water_glasses') ?? 4;
    _currentWeight = prefs.getDouble('user_current_weight') ?? 78.5;

    setState(() {});
  }

  Future<dynamic> import_shared_preferences() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> _saveCardOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('dashboard_card_order', _cardOrder);
  }

  Future<void> _updateWater(int delta) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterGlasses = (_waterGlasses + delta).clamp(0, 20);
    });
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
            actions: [
              IconButton(
                icon: Icon(
                  _isReordering ? Icons.check_circle_rounded : Icons.tune_rounded,
                  color: _isReordering ? _theme.primaryColor : const Color(0xFF91A2B5),
                ),
                tooltip: _isReordering ? 'Kész' : 'Kártyák átrendezése',
                onPressed: () {
                  setState(() {
                    _isReordering = !_isReordering;
                  });
                  if (!_isReordering) {
                    _saveCardOrder();
                  }
                },
              ),
            ],
          ),
          body: _isReordering ? _buildReorderableList() : _buildNormalDashboard(),
        );
      },
    );
  }

  Widget _buildNormalDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _cardOrder.map((key) => _buildCardByKey(key)).toList(),
      ),
    );
  }

  Widget _buildReorderableList() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: _theme.cardColor,
          child: const Text(
            'Húzd a kártyákat a kívánt sorrendbe!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = _cardOrder.removeAt(oldIndex);
                _cardOrder.insert(newIndex, item);
              });
              _saveCardOrder();
            },
            children: _cardOrder.map((key) {
              return Container(
                key: ValueKey(key),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _theme.primaryColor.withValues(alpha: 0.4)),
                ),
                child: ListTile(
                  leading: Icon(_getCardIcon(key), color: _theme.primaryColor),
                  title: Text(_getCardTitle(key), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.drag_handle_rounded, color: Colors.white54),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getCardIcon(String key) {
    switch (key) {
      case 'summary': return Icons.bolt_rounded;
      case 'workout': return Icons.fitness_center_rounded;
      case 'water': return Icons.water_drop_rounded;
      case 'recipes': return Icons.restaurant_menu_rounded;
      case 'weight': return Icons.monitor_weight_rounded;
      default: return Icons.dashboard_rounded;
    }
  }

  String _getCardTitle(String key) {
    switch (key) {
      case 'summary': return 'Napi Állapot & Makrók';
      case 'workout': return 'Napi Edzés (Lenyitható)';
      case 'water': return 'Vízfogyasztás Követő';
      case 'recipes': return 'Fitnesz Receptajánló';
      case 'weight': return 'Testsúly & Formakövetés';
      default: return 'Modul';
    }
  }

  Widget _buildCardByKey(String key) {
    switch (key) {
      case 'summary': return _buildSummaryCard();
      case 'workout': return _buildWorkoutCard();
      case 'water': return _buildWaterCard();
      case 'recipes': return _buildRecipesCard();
      case 'weight': return _buildWeightCard();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2F42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NAPI CÉLOK', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8)),
              Text('2,450 kcal', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroItem('Fehérje', '165g / 180g', 0.91, _theme.primaryColor),
              _buildMacroItem('Szénhidrát', '210g / 250g', 0.84, _theme.secondaryColor),
              _buildMacroItem('Zsír', '55g / 65g', 0.85, const Color(0xFFFFB300)),
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
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF1F2F42),
            color: color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2F42)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Icon(Icons.fitness_center_rounded, color: _theme.primaryColor),
          title: Text(_todayWorkoutType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text('${_plannedExercises.length} betárazott gyakorlat', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
          children: [
            if (_plannedExercises.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('Nincs aktív gyakorlat kiválasztva.', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: _plannedExercises.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ex = entry.value;
                    final completed = ex['completedSets'] ?? 0;
                    final target = ex['targetSets'] ?? 3;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _theme.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('$target széria × ${ex['targetReps'] ?? 10} ismétlés', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _toggleExerciseSet(idx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: completed >= target ? _theme.primaryColor : const Color(0xFF1F2F42),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$completed / $target',
                                style: TextStyle(color: completed >= target ? const Color(0xFF07101B) : Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                              ),
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
      decoration: BoxDecoration(
        color: _theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2F42)),
      ),
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
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white70),
                onPressed: () => _updateWater(-1),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_rounded, color: _theme.primaryColor),
                onPressed: () => _updateWater(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesCard() {
    final sampleRecipe = kBuiltInRecipes.first;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2F42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AJÁNLOTT RECEPT', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8)),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const RecipesScreen()),
                  );
                },
                child: Row(
                  children: [
                    Text('ÖSSZES RECEPT', style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: _theme.primaryColor, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(sampleRecipe.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Elkészítés: ${sampleRecipe.prepTime} • ${sampleRecipe.protein}g Fehérje • ${sampleRecipe.calories} kcal', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWeightCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2F42)),
      ),
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
                  Text('$_currentWeight kg (Cél: 75.0 kg)', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
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

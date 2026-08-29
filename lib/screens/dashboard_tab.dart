import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class DashboardTab extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const DashboardTab({super.key, this.onNavigateTab});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  DateTime _selectedDate = DateTime.now();
  List<LoggedMeal> _dayMeals = [];
  double _targetKcal = 2200;
  double _targetProtein = 190;
  bool _isLoading = true;
  int _xp = 10;
  int _streak = 1;
  String _workout = 'Rest day';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get _dateString => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final targetK = await StorageService.getTargetKcal();
    final targetP = await StorageService.getTargetProtein();
    final allMeals = await StorageService.getMeals();
    final dayMeals = allMeals.where((m) => m.date == _dateString).toList();
    final allWeights = await StorageService.getWeights();
    final todayLog = allWeights.where((w) => w.date == _dateString).toList();

    String currentWorkout = 'Rest day';
    if (todayLog.isNotEmpty && todayLog.first.workoutType.isNotEmpty) {
      currentWorkout = todayLog.first.workoutType;
    }

    if (!mounted) return;
    setState(() {
      _targetKcal = targetK;
      _targetProtein = targetP;
      _dayMeals = dayMeals;
      _workout = currentWorkout;
      _xp = min(25, 5 + (dayMeals.length * 5));
      _isLoading = false;
    });
  }

  double get _consumedKcal => _dayMeals.fold(0.0, (sum, item) => sum + item.kcal);
  double get _consumedProtein => _dayMeals.fold(0.0, (sum, item) => sum + item.protein);

  void _showAddMealModal() {
    final nameCtrl = TextEditingController();
    final kcalCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    String mealType = 'Ebéd';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('➕ Étel hozzáadása', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white60), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: mealType,
                  dropdownColor: const Color(0xFF1E293B),
                  decoration: InputDecoration(
                    labelText: 'Étkezés típusa',
                    filled: true,
                    fillColor: const Color(0xFF0B101B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF222F4C))),
                  ),
                  items: ['Reggeli', 'Ebéd', 'Vacsora', 'Nasi'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setModalState(() => mealType = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Étel / Recept neve',
                    hintText: 'pl. Lucskos darált húsos tortilla',
                    filled: true,
                    fillColor: const Color(0xFF0B101B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF222F4C))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: kcalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Kalória (kcal)',
                          filled: true,
                          fillColor: const Color(0xFF0B101B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF222F4C))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: proteinCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Fehérje (g)',
                          filled: true,
                          fillColor: const Color(0xFF0B101B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF222F4C))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'CH (g)',
                          filled: true,
                          fillColor: const Color(0xFF0B101B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF222F4C))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: fatCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Zsír (g)',
                          filled: true,
                          fillColor: const Color(0xFF0B101B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF222F4C))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2E63),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty) return;
                      final meal = LoggedMeal(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        date: _dateString,
                        mealType: mealType,
                        name: nameCtrl.text,
                        amount: 1,
                        unit: 'adag',
                        kcal: double.tryParse(kcalCtrl.text) ?? 0.0,
                        protein: double.tryParse(proteinCtrl.text) ?? 0.0,
                        carbs: double.tryParse(carbsCtrl.text) ?? 0.0,
                        fat: double.tryParse(fatCtrl.text) ?? 0.0,
                      );
                      await StorageService.saveMeal(meal);
                      if (ctx.mounted) Navigator.pop(ctx);
                      _loadData();
                    },
                    child: const Text('Rögzítés a mai napra', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF2E63))),
      );
    }

    final remainingKcal = (_targetKcal - _consumedKcal).toInt();
    final remainingProtein = (_targetProtein - _consumedProtein).toInt();
    final kcalProgress = (_consumedKcal / _targetKcal).clamp(0.0, 1.0);
    final proteinProgress = (_consumedProtein / _targetProtein).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFFFF2E63),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            children: [
                              TextSpan(text: 'Füty', style: TextStyle(color: Color(0xFF00E5FF))),
                              TextSpan(text: 'fürütty', style: TextStyle(color: Color(0xFFFF2E63))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'NUTRITION • TRAINING • CHECK-IN',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white54),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildCircleIconBtn(Icons.info_outline, () {}),
                        const SizedBox(width: 8),
                        _buildCircleIconBtn(Icons.settings_outlined, () {
                          if (widget.onNavigateTab != null) widget.onNavigateTab!(4);
                        }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, yyyy. MM. dd.', 'hu_HU').format(_selectedDate),
                      style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2E63).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF2E63).withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Nap 1/28 • 1. hét',
                        style: TextStyle(color: Color(0xFFFF4D79), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mai nap',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _buildGaugeCard(
                        title: 'KCAL',
                        current: _consumedKcal.toInt(),
                        target: _targetKcal.toInt(),
                        progress: kcalProgress,
                        arcColor: const Color(0xFFFF2E63),
                        unit: 'kcal',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildGaugeCard(
                        title: 'PROTEIN',
                        current: _consumedProtein.toInt(),
                        target: _targetProtein.toInt(),
                        progress: proteinProgress,
                        arcColor: const Color(0xFF00E5FF),
                        unit: 'g',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E2B48)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🩷', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(
                        remainingProtein > 0
                            ? '$remainingKcal kcal maradt • $remainingProtein g protein hiányzik.'
                            : '$remainingKcal kcal maradt • Protein cél kipipálva! 🎉',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        'XP MA',
                        '$_xp / 25 XP',
                        extraWidget: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _xp / 25.0,
                            backgroundColor: const Color(0xFF222F4C),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF2E63)),
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMiniStatCard(
                        'STREAK',
                        '🔥 $_streak nap',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMiniStatCard(
                        'EDZÉS',
                        _workout,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mai étkezések',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.onNavigateTab != null) widget.onNavigateTab!(2);
                      },
                      child: const Text(
                        'Összes →',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_dayMeals.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E2B48)),
                    ),
                    child: const Center(
                      child: Text('Még nem rögzítettél ételt mára.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ),
                  )
                else
                  ..._dayMeals.map((meal) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E2B48)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(meal.mealType, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 3),
                                  Text(
                                    meal.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${meal.amount.toInt()} ${meal.unit}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text('${meal.kcal.toInt()} kcal', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2E63),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 6,
                    ),
                    onPressed: _showAddMealModal,
                    child: const Text(
                      '+ ÉTEL HOZZÁADÁSA',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIconBtn(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2B48)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 20),
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildGaugeCard({
    required String title,
    required int current,
    required int target,
    required double progress,
    required Color arcColor,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2B48)),
      ),
      child: Column(
        children: [
          CustomPaint(
            size: const Size(110, 80),
            painter: GaugePainter(progress: progress, color: arcColor),
            child: SizedBox(
              width: 110,
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    '$current',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  Text(
                    '/ $target $unit',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, {Widget? extraWidget}) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2B48)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (extraWidget != null) ...[
            const SizedBox(height: 6),
            extraWidget,
          ],
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    final radius = size.width * 0.44;

    const startAngle = pi * 0.8;
    const sweepAngle = pi * 1.4;

    final bgPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, bgPaint);

    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle * progress, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
import 'package:flutter/material.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // Napi célértékek és aktuális állapot
  int calorieGoal = 2200;
  int caloriesConsumed = 1450;
  int caloriesBurned = 320;

  double proteinConsumed = 110.0;
  double proteinGoal = 160.0;

  double carbsConsumed = 165.0;
  double carbsGoal = 220.0;

  double fatConsumed = 42.0;
  double fatGoal = 65.0;

  int waterGlasses = 4;
  final int waterGoal = 8;

  void _addWater() {
    setState(() {
      if (waterGlasses < 15) waterGlasses++;
    });
  }

  void _removeWater() {
    setState(() {
      if (waterGlasses > 0) waterGlasses--;
    });
  }

  void _quickAddCalories(int amount, String title) {
    setState(() {
      caloriesConsumed += amount;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E2230),
        content: Text(
          '+$amount kcal hozzáadva ($title)',
          style: const TextStyle(color: Colors.greenAccent),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingCalories = (calorieGoal - caloriesConsumed + caloriesBurned);
    final progress = (caloriesConsumed / calorieGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Szia, Peti! 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Mai összesítés',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FŐ KALÓRIA KÁRTYA (Kördiagrammal)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2235), Color(0xFF141724)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Kördiagram
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$remainingCalories',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'kcal maradt',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Részletek oszlop
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalorieStatRow('Cél:', '$calorieGoal kcal', Colors.grey),
                        const SizedBox(height: 8),
                        _buildCalorieStatRow('Elfogyasztva:', '$caloriesConsumed kcal', Colors.cyanAccent),
                        const SizedBox(height: 8),
                        _buildCalorieStatRow('Elégetve:', '$caloriesBurned kcal', Colors.orangeAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. MAKRÓ TÁPANYAGOK
            const Text(
              'Makrotápanyagok',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMacroCard(
                    'Fehérje',
                    '${proteinConsumed.toInt()} / ${proteinGoal.toInt()}g',
                    proteinConsumed / proteinGoal,
                    const Color(0xFFFF5252),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMacroCard(
                    'Szénhidrát',
                    '${carbsConsumed.toInt()} / ${carbsGoal.toInt()}g',
                    carbsConsumed / carbsGoal,
                    const Color(0xFFFFD740),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMacroCard(
                    'Zsír',
                    '${fatConsumed.toInt()} / ${fatGoal.toInt()}g',
                    fatConsumed / fatGoal,
                    const Color(0xFF69F0AE),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. VÍZIVÁS SZÁMLÁLÓ (Interaktív)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF171B26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.water_drop, color: Colors.blueAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vízfogyasztás',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$waterGlasses / $waterGoal pohár (${waterGlasses * 2.5 / 10} L)',
                          style: const TextStyle(fontSize: 13, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ),
                  // Mínusz gomb
                  IconButton(
                    onPressed: _removeWater,
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                  ),
                  // Plusz gomb
                  IconButton(
                    onPressed: _addWater,
                    icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 32),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. GYORS ÉTELHOZZÁADÁS GOMBOK
            const Text(
              'Gyors étkezés rögzítés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAddButton('Reggeli', '+350 kcal', Icons.free_breakfast, () {
                    _quickAddCalories(350, 'Reggeli');
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickAddButton('Ebéd', '+650 kcal', Icons.lunch_dining, () {
                    _quickAddCalories(650, 'Ebéd');
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickAddButton('Vacsora', '+450 kcal', Icons.dinner_dining, () {
                    _quickAddCalories(450, 'Vacsora');
                  }),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMacroCard(String title, String value, double percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171B26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF171B26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 24),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
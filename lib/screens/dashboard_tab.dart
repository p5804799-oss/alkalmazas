import 'package:flutter/material.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // Alapbeállítások
  int kcalGoal = 2200;
  int proteinGoal = 190;
  int programDay = 1;

  // Mai étkezések
  List<Map<String, dynamic>> todayLogs = [
    {"id": "1", "meal": "Reggeli", "name": "Sonkás-cottage rántotta toasttal", "qty": "1 adag", "kcal": 625, "p": 67.2},
    {"id": "2", "meal": "Ebéd", "name": "Lucskos darált húsos tortilla", "qty": "1 adag", "kcal": 582, "p": 47.6},
  ];

  // Napi Edzésterv modell (Példa: Push nap)
  String workoutSplitName = "Push Nap (Mell - Váll - Tricepsz)";
  List<Map<String, dynamic>> exercises = [
    {
      "id": "e1",
      "name": "Fekvenyomás rúddal",
      "target": "4 széria × 8-10 ism (75 kg)",
      "setsTotal": 4,
      "setsDone": 2,
    },
    {
      "id": "e2",
      "name": "Kézisúlyzós ferdepados nyomás",
      "target": "3 széria × 10-12 ism (26 kg)",
      "setsTotal": 3,
      "setsDone": 0,
    },
    {
      "id": "e3",
      "name": "Oldalemelés kézisúlyzóval",
      "target": "4 széria × 12-15 ism (10 kg)",
      "setsTotal": 4,
      "setsDone": 0,
    },
    {
      "id": "e4",
      "name": "Csigás tricepsz letolás",
      "target": "3 széria × 12 ism (30 kg)",
      "setsTotal": 3,
      "setsDone": 0,
    },
  ];

  // Számított tápanyag értékek
  int get totalKcal => todayLogs.fold(0, (sum, item) => sum + (item['kcal'] as int));
  double get totalProtein => todayLogs.fold(0.0, (sum, item) => sum + (item['p'] as double));

  // Számított Edzés %-os haladás
  int get totalSets => exercises.fold(0, (sum, item) => sum + (item['setsTotal'] as int));
  int get completedSets => exercises.fold(0, (sum, item) => sum + (item['setsDone'] as int));
  double get workoutProgress => totalSets == 0 ? 0.0 : (completedSets / totalSets).clamp(0.0, 1.0);
  int get workoutPercent => (workoutProgress * 100).toInt();

  // Számított XP
  int get xp {
    int x = 0;
    if (totalProtein >= proteinGoal * 0.9) x += 10;
    if (todayLogs.isNotEmpty && totalKcal <= kcalGoal) x += 5;
    if (todayLogs.length >= 3) x += 5;
    if (workoutProgress > 0) x += (workoutProgress * 5).toInt();
    return x;
  }

  void _incrementSet(String id) {
    setState(() {
      final index = exercises.indexWhere((e) => e['id'] == id);
      if (index != -1 && exercises[index]['setsDone'] < exercises[index]['setsTotal']) {
        exercises[index]['setsDone']++;
      }
    });
  }

  void _decrementSet(String id) {
    setState(() {
      final index = exercises.indexWhere((e) => e['id'] == id);
      if (index != -1 && exercises[index]['setsDone'] > 0) {
        exercises[index]['setsDone']--;
      }
    });
  }

  void _addNewExerciseDialog() {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: "3");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1825),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF26364A)),
        ),
        title: const Text("Új gyakorlat hozzáadása", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Gyakorlat neve (pl. Guggolás)", labelStyle: TextStyle(color: Color(0xFF91A2B5))),
            ),
            TextField(
              controller: targetCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Cél (pl. 4x8 90kg)", labelStyle: TextStyle(color: Color(0xFF91A2B5))),
            ),
            TextField(
              controller: setsCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Összes széria száma", labelStyle: TextStyle(color: Color(0xFF91A2B5))),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Mégse", style: TextStyle(color: Color(0xFF91A2B5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF28D5CF)),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  exercises.add({
                    "id": DateTime.now().millisecondsSinceEpoch.toString(),
                    "name": nameCtrl.text,
                    "target": targetCtrl.text.isEmpty ? "Standard széria" : targetCtrl.text,
                    "setsTotal": int.tryParse(setsCtrl.text) ?? 3,
                    "setsDone": 0,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Mentés", style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _addSampleMeal() {
    setState(() {
      todayLogs.add({
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "meal": "Vacsora",
        "name": "Tonhalas-cottage melegszendvics",
        "qty": "1 adag",
        "kcal": 642,
        "p": 72.0,
      });
    });
  }

  void _deleteMeal(String id) {
    setState(() {
      todayLogs.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final remKcal = (kcalGoal - totalKcal);
    final remProtein = (proteinGoal - totalProtein);

    final kcalPct = (totalKcal / kcalGoal).clamp(0.0, 1.0);
    final proteinPct = (totalProtein / proteinGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B).withOpacity(0.85),
        elevation: 0,
        title: Row(
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.8),
                children: [
                  TextSpan(text: 'Füty', style: TextStyle(color: Color(0xFF28D5CF))),
                  TextSpan(text: 'fürütty', style: TextStyle(color: Color(0xFFFF356D))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1724),
                border: Border.all(color: const Color(0xFF26364A)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings_outlined, size: 20, color: Colors.white),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Címsor + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('szombat, 2026. 08. 29.', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                    SizedBox(height: 2),
                    Text('Mai nap', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFF5F8FB))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27101B),
                    border: Border.all(color: const Color(0xFF64243C)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Nap $programDay / 28',
                    style: const TextStyle(color: Color(0xFFFF94B1), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // HERO RINGS (KCAL & PROTEIN)
            Row(
              children: [
                Expanded(
                  child: _buildHeroRing(
                    title: 'KCAL',
                    current: '$totalKcal',
                    target: '$kcalGoal kcal',
                    progress: kcalPct,
                    color: const Color(0xFFFF356D),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: _buildHeroRing(
                    title: 'PROTEIN',
                    current: '${totalProtein.toInt()}',
                    target: '$proteinGoal g',
                    progress: proteinPct,
                    color: const Color(0xFF24D17C),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // DINAMIKUS STÁTUSZ SÁV
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111F2E),
                border: Border.all(color: const Color(0xFF26364A)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                totalKcal > kcalGoal
                    ? '🔴 ${totalKcal - kcalGoal} kcal keret felett.'
                    : remProtein > 0
                        ? '🩷 $remKcal kcal maradt • ${remProtein.toInt()} g protein hiányzik.'
                        : '✅ Protein kipipálva • $remKcal kcal maradt.',
                style: const TextStyle(color: Color(0xFFF5F8FB), fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 12),

            // MINI STATS (XP / STREAK / EDZÉS %)
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    label: 'XP MA',
                    value: '$xp/25',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: xp / 25,
                        minHeight: 5,
                        backgroundColor: const Color(0xFF243246),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFFF356D)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniStat(
                    label: 'STREAK',
                    value: '🔥 1 nap',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniStat(
                    label: 'EDZÉS KÉSZ',
                    value: '$workoutPercent%',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: workoutProgress,
                        minHeight: 5,
                        backgroundColor: const Color(0xFF243246),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF28D5CF)),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- NAPI EDZÉSTERV & PROGRESSZIÓ SZEKCIÓ ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mai Edzésterv', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFF5F8FB))),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF28D5CF), size: 22),
                  onPressed: _addNewExerciseDialog,
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Edzés Kártya Fejléc és Progressziós csík
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF111E2D), Color(0xFF0D1825)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFF26364A)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          workoutSplitName,
                          style: const TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                      Text(
                        '$completedSets / $totalSets széria ($workoutPercent%)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: workoutProgress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF243246),
                      valueColor: AlwaysStoppedAnimation(
                        workoutPercent == 100 ? const Color(0xFF24D17C) : const Color(0xFF28D5CF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Gyakorlatok listája
                  ...exercises.map((e) => _buildExerciseRow(e)),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ÉTKEZÉSEK SZEKCIÓ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mai étkezések', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFF5F8FB))),
                TextButton(
                  onPressed: () {},
                  child: const Text('Összes →', style: TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ÉTKEZÉS LISTA KÁRTYA
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1825),
                border: Border.all(color: const Color(0xFF26364A)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: todayLogs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(25),
                      child: Center(child: Text('Még nincs mai étkezés.', style: TextStyle(color: Color(0xFF91A2B5)))),
                    )
                  : Column(
                      children: todayLogs.map((log) => _buildMealRow(log)).toList(),
                    ),
            ),

            const SizedBox(height: 16),

            // GYORS ÉTELHOZZÁADÁS GOMB
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: const Color(0xFFFF356D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _addSampleMeal,
                child: const Text(
                  '+ ÉTEL HOZZÁADÁSA',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroRing({required String title, required String current, required String target, required double progress, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111E2D), Color(0xFF0A1420)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF26364A)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 105,
                height: 105,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 9,
                  backgroundColor: const Color(0xFF243246),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(current, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFF5F8FB))),
                  Text('/ $target', style: const TextStyle(fontSize: 10, color: Color(0xFFCAD5E0))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 10, letterSpacing: 1.5, color: Color(0xFF91A2B5), fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildMiniStat({required String label, required String value, Widget? child}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1825),
        border: Border.all(color: const Color(0xFF26364A)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 8, letterSpacing: 1, color: Color(0xFF91A2B5), fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFF5F8FB))),
          if (child != null) ...[
            const SizedBox(height: 7),
            child,
          ]
        ],
      ),
    );
  }

  Widget _buildExerciseRow(Map<String, dynamic> item) {
    final bool isDone = item['setsDone'] >= item['setsTotal'];

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFF071B1B) : const Color(0xFF08121D),
        border: Border.all(color: isDone ? const Color(0xFF166864) : const Color(0xFF26364A)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDone ? const Color(0xFF24D17C) : const Color(0xFFF5F8FB),
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(item['target'], style: const TextStyle(fontSize: 11, color: Color(0xFF91A2B5))),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF91A2B5), size: 22),
                onPressed: () => _decrementSet(item['id']),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF24D17C) : const Color(0xFF142235),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item['setsDone']} / ${item['setsTotal']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDone ? const Color(0xFF07101B) : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.add_circle,
                  color: isDone ? const Color(0xFF24D17C) : const Color(0xFF28D5CF),
                  size: 24,
                ),
                onPressed: () => _incrementSet(item['id']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealRow(Map<String, dynamic> log) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF26364A), width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log['meal'], style: const TextStyle(fontSize: 11, color: Color(0xFF91A2B5))),
                const SizedBox(height: 2),
                Text(log['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF5F8FB))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(log['qty'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF5F8FB))),
              Text('${log['kcal']} kcal', style: const TextStyle(fontSize: 11, color: Color(0xFF91A2B5))),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF8091A6)),
            onPressed: () => _deleteMeal(log['id']),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final String _myInviteCode = 'FUTY-PETI-9842';

  final List<FriendProfile> _friends = [
    FriendProfile(
      id: '1',
      inviteCode: 'FUTY-Imre-1102',
      name: 'Füty Imre',
      avatar: 'KB',
      currentWeight: 84.2,
      weightChange: -1.6,
      lastWeighInDate: 'Ma reggel',
      todayKcal: 1840,
      targetKcal: 2200,
      todayProtein: 165,
      targetProtein: 190,
      todayWorkout: 'Push day 💪',
      todayMeals: [
        LoggedMeal(
          id: 'm1',
          date: '2026-08-29',
          mealType: 'Reggeli',
          name: 'Sonkás-cottage rántotta toasttal',
          amount: 1,
          unit: 'adag',
          kcal: 625,
          protein: 67.2,
          carbs: 43.8,
          fat: 18.4,
        ),
      ],
    ),
    FriendProfile(
      id: '2',
      inviteCode: 'FUTY-KAL-3391',
      name: 'Kala Pál',
      avatar: 'NZS',
      currentWeight: 67.1,
      weightChange: -0.9,
      lastWeighInDate: 'Tegnap',
      todayKcal: 1420,
      targetKcal: 1650,
      todayProtein: 125,
      targetProtein: 135,
      todayWorkout: 'Legs / Fenék 🔥',
      todayMeals: [
        LoggedMeal(
          id: 'm2',
          date: '2026-08-29',
          mealType: 'Reggeli',
          name: 'Áfonyás overnight oats protein krémmel',
          amount: 1,
          unit: 'adag',
          kcal: 605,
          protein: 60.6,
          carbs: 70.9,
          fat: 7.6,
        ),
      ],
    ),
  ];

  void _showAddFriendDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ismerős összekapcsolása', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Írd be a barátod meghívó kódját, hogy láthasd a mérlegelését és a napi étkezéseit tápértékekkel:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeCtrl,
              decoration: InputDecoration(
                labelText: 'Meghívó kód (pl. FUTY-BALA-1102)',
                filled: true,
                fillColor: const Color(0xFF0B101B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Ismerős neve',
                filled: true,
                fillColor: const Color(0xFF0B101B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Mégse', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2E63)),
            onPressed: () {
              if (codeCtrl.text.isEmpty) return;
              final name = nameCtrl.text.isNotEmpty ? nameCtrl.text : codeCtrl.text;
              setState(() {
                _friends.add(FriendProfile(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  inviteCode: codeCtrl.text,
                  name: name,
                  avatar: name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                  currentWeight: 78.5,
                  weightChange: -1.2,
                  lastWeighInDate: 'Ma',
                  todayKcal: 1750,
                  targetKcal: 2100,
                  todayProtein: 150,
                  targetProtein: 180,
                  todayWorkout: 'Full Body 🔥',
                  todayMeals: [],
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Hozzáadás', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFriendDetailModal(FriendProfile friend) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: const Color(0xFF222F4C), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    child: Text(friend.avatar, style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(friend.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Edzés: ${friend.todayWorkout}', style: const TextStyle(color: Color(0xFFFF2E63), fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B101B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2B48)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('AKTUÁLIS SÚLY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
                        const SizedBox(height: 4),
                        Text('${friend.currentWeight} kg', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text(friend.lastWeighInDate, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                      ],
                    ),
                    Container(height: 35, width: 1, color: const Color(0xFF222F4C)),
                    Column(
                      children: [
                        const Text('VÁLTOZÁS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
                        const SizedBox(height: 4),
                        Text('${friend.weightChange > 0 ? "+" : ""}${friend.weightChange} kg',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF00E5FF))),
                        const Text('4 hetes cél', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B101B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2B48)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kalória: ${friend.todayKcal.toInt()} / ${friend.targetKcal.toInt()} kcal',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${(friend.todayKcal / friend.targetKcal * 100).toInt()}%',
                            style: const TextStyle(color: Color(0xFFFF2E63), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (friend.todayKcal / friend.targetKcal).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFF222F4C),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF2E63)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fehérje: ${friend.todayProtein.toInt()} / ${friend.targetProtein.toInt()} g',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${(friend.todayProtein / friend.targetProtein * 100).toInt()}%',
                            style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (friend.todayProtein / friend.targetProtein).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFF222F4C),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Mit evett ma részletesen?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              if (friend.todayMeals.isEmpty)
                const Text('Még nincs rögzített étkezés.', style: TextStyle(color: Colors.white54))
              else
                ...friend.todayMeals.map((meal) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B101B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E2B48)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(meal.mealType, style: const TextStyle(color: Color(0xFFFF4D79), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('${meal.amount.toInt()} ${meal.unit} • ${meal.kcal.toInt()} kcal',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(meal.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF131B2E), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              '🥩 P: ${meal.protein.toStringAsFixed(1)}g | 🍞 CH: ${meal.carbs.toStringAsFixed(1)}g | 🥑 Zs: ${meal.fat.toStringAsFixed(1)}g',
                              style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Csapat & Ismerősök', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF00E5FF)),
            onPressed: _showAddFriendDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('A TE MEGHÍVÓ KÓDOD', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_myInviteCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                        foregroundColor: const Color(0xFF00E5FF),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Másolás'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _myInviteCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📋 Kód a vágólapra másolva!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Közösségi állapot ma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18, color: Color(0xFFFF2E63)),
                label: const Text('Új Ismerős', style: TextStyle(color: Color(0xFFFF2E63))),
                onPressed: _showAddFriendDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._friends.map((friend) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF1E2B48)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showFriendDetailModal(friend),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFFF2E63).withValues(alpha: 0.18),
                                child: Text(friend.avatar, style: const TextStyle(color: Color(0xFFFF2E63), fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(friend.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text('Edzés: ${friend.todayWorkout}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${friend.currentWeight} kg', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                                  Text('${friend.weightChange > 0 ? "+" : ""}${friend.weightChange} kg',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFF0B101B), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('🔥 ${friend.todayKcal.toInt()} kcal', style: const TextStyle(color: Color(0xFFFF2E63), fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('🥩 ${friend.todayProtein.toInt()} g P', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold)),
                                const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
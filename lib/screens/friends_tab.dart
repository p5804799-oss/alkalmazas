import 'package:flutter/material.dart';

class FriendUser {
  final String id;
  final String name;
  final String tag;
  final String currentWorkout;
  final int todayCalories;
  final double currentWeight;
  final List<double> weightProgress;
  final bool shareWeight;
  final bool shareMeals;

  FriendUser({
    required this.id,
    required this.name,
    required this.tag,
    required this.currentWorkout,
    required this.todayCalories,
    required this.currentWeight,
    required this.weightProgress,
    this.shareWeight = true,
    this.shareMeals = true,
  });
}

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final List<FriendUser> _friends = [
    FriendUser(
      id: 'f1',
      name: 'Balázs',
      tag: '#BALAZS_9912',
      currentWorkout: 'PUSH (Mell-Váll-Tri)',
      todayCalories: 2340,
      currentWeight: 82.5,
      weightProgress: [84.0, 83.5, 83.1, 82.8, 82.5],
      shareWeight: true,
      shareMeals: true,
    ),
    FriendUser(
      id: 'f2',
      name: 'Gergő',
      tag: '#GERGO_4411',
      currentWorkout: 'PULL (Hát-Bi)',
      todayCalories: 2600,
      currentWeight: 78.0,
      weightProgress: [76.0, 76.5, 77.0, 77.4, 78.0],
      shareWeight: false,
      shareMeals: true,
    ),
  ];

  final List<String> _pendingRequests = ['#BENCE_1204'];

  void _showAddFriendDialog() {
    final tagCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF07101B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF26364A)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Barát Felkérése',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add meg a barátod Dagi Tag-jét (pl. #BENCE_1204)',
                  hintStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0D1825),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF26364A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF28D5CF)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28D5CF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final tag = tagCtrl.text.trim();
                    if (tag.isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Felkérés elküldve a következőnek: $tag!'),
                          backgroundColor: const Color(0xFF28D5CF),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'FELKÉRÉS KÜLDÉSE',
                    style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompareDialog(FriendUser friend) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF07101B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Összehasonlítás: ${friend.name}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF91A2B5)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1825),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF26364A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Te', style: TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Súly: 85.0 kg', style: TextStyle(color: Colors.white, fontSize: 13)),
                        const Text('Kaja: 2400 kcal', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1825),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF26364A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(friend.name, style: const TextStyle(color: Color(0xFFFF356D), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          friend.shareWeight ? 'Súly: ${friend.currentWeight} kg' : 'Súly: 🔒 Rejtve',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        Text(
                          friend.shareMeals ? 'Kaja: ${friend.todayCalories} kcal' : 'Kaja: 🔒 Rejtve',
                          style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1825),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF26364A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Összehasonlító Trend Vonal',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(width: 12, height: 3, color: const Color(0xFF28D5CF)),
                      const SizedBox(width: 4),
                      const Text('Te', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                      const SizedBox(width: 12),
                      Container(width: 12, height: 3, color: const Color(0xFFFF356D)),
                      const SizedBox(width: 4),
                      Text(friend.name, style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: FriendComparePainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07101B),
        elevation: 0,
        title: const Text('Közösség & Barátok', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1825),
                border: Border.all(color: const Color(0xFF26364A)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF28D5CF), size: 20),
            ),
            onPressed: _showAddFriendDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_pendingRequests.isNotEmpty) ...[
              const Text('Függőben lévő felkérések', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ..._pendingRequests.map((tag) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1825),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF26364A)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tag, style: const TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Color(0xFF28D5CF)),
                              onPressed: () {
                                setState(() => _pendingRequests.remove(tag));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Color(0xFFFF356D)),
                              onPressed: () {
                                setState(() => _pendingRequests.remove(tag));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            const Text('Barátaid', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ..._friends.map((friend) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1825),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF26364A)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF1B2A3D),
                            child: Text(friend.name[0], style: const TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(friend.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(friend.currentWorkout, style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2A3D),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFF28D5CF)),
                          ),
                        ),
                        onPressed: () => _showCompareDialog(friend),
                        child: const Text('Mérés ⚡', style: TextStyle(color: Color(0xFF28D5CF), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class FriendComparePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = const Color(0xFF28D5CF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final p2 = Paint()
      ..color = const Color(0xFFFF356D)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.lineTo(size.width * 0.3, size.height * 0.6);
    path1.lineTo(size.width * 0.7, size.height * 0.4);
    path1.lineTo(size.width, size.height * 0.2);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.lineTo(size.width * 0.3, size.height * 0.75);
    path2.lineTo(size.width * 0.7, size.height * 0.55);
    path2.lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path1, p1);
    canvas.drawPath(path2, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

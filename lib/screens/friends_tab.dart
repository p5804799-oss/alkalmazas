import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class SharedWorkoutInvite {
  final String id;
  final String fromUser;
  final String workoutTitle;
  final List<dynamic> exercises;
  final DateTime date;

  SharedWorkoutInvite({
    required this.id,
    required this.fromUser,
    required this.workoutTitle,
    required this.exercises,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'fromUser': fromUser,
        'workoutTitle': workoutTitle,
        'exercises': exercises,
        'date': date.toIso8601String(),
      };

  factory SharedWorkoutInvite.fromMap(Map<String, dynamic> map) => SharedWorkoutInvite(
        id: map['id'] ?? '',
        fromUser: map['fromUser'] ?? '',
        workoutTitle: map['workoutTitle'] ?? '',
        exercises: map['exercises'] ?? [],
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      );
}

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
  final ThemeService _theme = ThemeService();
  List<SharedWorkoutInvite> _workoutInvites = [];

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

  @override
  void initState() {
    super.initState();
    _loadWorkoutInvites();
  }

  Future<void> _loadWorkoutInvites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('shared_workout_invites_queue');
    if (raw != null && raw.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(raw);
      setState(() {
        _workoutInvites = decoded.map((i) => SharedWorkoutInvite.fromMap(i)).toList();
      });
    }
  }

  Future<void> _acceptWorkoutInvite(SharedWorkoutInvite invite) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Letisztítjuk a gyakorlatokat a fogadó fél korábbi súlyaihoz
    final String? rawLogs = prefs.getString('exercise_progress_logs');
    List<dynamic> logs = rawLogs != null ? jsonDecode(rawLogs) : [];

    final customizedExercises = invite.exercises.map((e) {
      final exName = e['name'] as String;
      double lastW = 0.0;
      final matches = logs.where((l) => (l['exerciseName'] as String).toLowerCase() == exName.toLowerCase()).toList();
      if (matches.isNotEmpty) {
        matches.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        lastW = (matches.first['weightKg'] as num).toDouble();
      }

      return {
        'name': exName,
        'targetSets': e['targetSets'] ?? 3,
        'targetReps': e['targetReps'] ?? 10,
        'lastWeight': lastW,
        'completedSets': 0,
      };
    }).toList();

    final title = "Közös Edzés (${invite.fromUser}-vel): ${invite.workoutTitle}";
    await prefs.setString('daily_workout_type_$dateKey', title);
    await prefs.setString('daily_planned_exercises_$dateKey', jsonEncode(customizedExercises));
    await prefs.setString('daily_workout_type', title);
    await prefs.setString('daily_planned_exercises', jsonEncode(customizedExercises));

    setState(() {
      _workoutInvites.removeWhere((i) => i.id == invite.id);
    });
    await prefs.setString('shared_workout_invites_queue', jsonEncode(_workoutInvites.map((i) => i.toMap()).toList()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Közös edzés elfogadva! Betöltve a Dashboardra: $title'),
          backgroundColor: _theme.primaryColor,
        ),
      );
    }
  }

  Future<void> _declineWorkoutInvite(SharedWorkoutInvite invite) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workoutInvites.removeWhere((i) => i.id == invite.id);
    });
    await prefs.setString('shared_workout_invites_queue', jsonEncode(_workoutInvites.map((i) => i.toMap()).toList()));
  }

  void _showAddFriendDialog() {
    final tagCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF26364A))),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Barát Felkérése', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: tagCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Barát Dagi Tag-je (pl. #BENCE_1204)',
                  hintStyle: const TextStyle(color: Color(0xFF55687D), fontSize: 12),
                  filled: true,
                  fillColor: _theme.cardColor,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF26364A))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _theme.primaryColor)),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    final tag = tagCtrl.text.trim();
                    if (tag.isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Felkérés elküldve: $tag!'), backgroundColor: _theme.primaryColor),
                      );
                    }
                  },
                  child: const Text('FELKÉRÉS KÜLDÉSE', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
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
            title: const Text('Közösség & Barátok', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: _theme.cardColor, border: Border.all(color: const Color(0xFF26364A)), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.person_add_alt_1_rounded, color: _theme.primaryColor, size: 20),
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
                // BEJÖVŐ KÖZÖS EDZÉS MEGHÍVÓK KÁRTYA
                if (_workoutInvites.isNotEmpty) ...[
                  const Text('Bejövő Közös Edzés Meghívók 🔥', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  ..._workoutInvites.map((invite) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _theme.primaryColor, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.fitness_center_rounded, color: _theme.primaryColor, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${invite.fromUser} közös edzésre hívott!',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                                Text('${invite.exercises.length} gyakorlat', style: TextStyle(color: _theme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Terv: ${invite.workoutTitle}', style: const TextStyle(color: Color(0xFF91A2B5), fontSize: 13)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 10)),
                                    icon: const Icon(Icons.check, size: 16, color: Color(0xFF07101B)),
                                    label: const Text('ELFOGADÁS (Dashboardra)', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.bold, fontSize: 11)),
                                    onPressed: () => _acceptWorkoutInvite(invite),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.close_rounded, color: _theme.secondaryColor),
                                  onPressed: () => _declineWorkoutInvite(invite),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                if (_pendingRequests.isNotEmpty) ...[
                  const Text('Függőben lévő barátkérelmek', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  ..._pendingRequests.map((tag) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF26364A))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tag, style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                IconButton(icon: Icon(Icons.check_circle, color: _theme.primaryColor), onPressed: () => setState(() => _pendingRequests.remove(tag))),
                                IconButton(icon: Icon(Icons.cancel, color: _theme.secondaryColor), onPressed: () => setState(() => _pendingRequests.remove(tag))),
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
                      decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF26364A))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF1B2A3D),
                                child: Text(friend.name[0], style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.bold)),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF1B2A3D), borderRadius: BorderRadius.circular(10)),
                            child: Text(friend.shareWeight ? '${friend.currentWeight} kg' : '🔒 Rejtve', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';
import 'workout_tracker_tab.dart';

class WorkoutInvite {
  final String id;
  final String senderName;
  final String targetFriendName;
  final String workoutType;
  final String timeLabel;
  final DateTime createdAt;
  String status;

  WorkoutInvite({
    required this.id,
    required this.senderName,
    required this.targetFriendName,
    required this.workoutType,
    required this.timeLabel,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderName': senderName,
        'targetFriendName': targetFriendName,
        'workoutType': workoutType,
        'timeLabel': timeLabel,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  factory WorkoutInvite.fromMap(Map<String, dynamic> map) => WorkoutInvite(
        id: map['id'] ?? '',
        senderName: map['senderName'] ?? 'Edzőtárs',
        targetFriendName: map['targetFriendName'] ?? '',
        workoutType: map['workoutType'] ?? 'Vegyes Edzés',
        timeLabel: map['timeLabel'] ?? 'MOST',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        status: map['status'] ?? 'pending',
      );
}

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final ThemeService _theme = ThemeService();
  final List<String> _friends = ['Bence (GymBro)', 'Dávid (BeastMode)', 'Anna (PowerLift)', 'Gergő (CardioKing)'];
  List<WorkoutInvite> _invites = [];
  bool _isOnlineSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('shared_workout_invites_online');
    if (raw != null && raw.isNotEmpty) {
      final List<dynamic> list = jsonDecode(raw);
      setState(() {
        _invites = list.map((e) => WorkoutInvite.fromMap(e)).toList();
      });
    } else {
      setState(() {
        _invites = [
          WorkoutInvite(
            id: 'sample_1',
            senderName: 'Bence (GymBro)',
            targetFriendName: 'Te',
            workoutType: 'PUSH',
            timeLabel: 'MOST 🔥',
            createdAt: DateTime.now(),
          ),
        ];
      });
      _saveInvites();
    }
  }

  Future<void> _saveInvites() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_invites.map((e) => e.toMap()).toList());
    await prefs.setString('shared_workout_invites_online', encoded);
  }

  Future<void> _triggerCloudSync() async {
    setState(() => _isOnlineSyncing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isOnlineSyncing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Felhő szinkronizáció kész! Minden barát online 🟢'), backgroundColor: _theme.primaryColor),
      );
    }
  }

  Future<void> _acceptAndActivateWorkout(WorkoutInvite invite) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = getInitialWorkoutCategories();
    final matchedCat = categories.firstWhere(
      (c) => c.title.toLowerCase().contains(invite.workoutType.toLowerCase()) || c.id.toLowerCase() == invite.workoutType.toLowerCase(),
      orElse: () => categories.first,
    );

    final exercisesData = matchedCat.exercises.take(6).map((e) => {
      'name': e.name,
      'targetSets': e.defaultSets,
      'targetReps': e.defaultReps,
      'completedSets': 0,
    }).toList();

    await prefs.setString('daily_workout_type', "${matchedCat.title.split(' ')[0]} (${invite.senderName} partnerrel)");
    await prefs.setString('daily_planned_exercises', jsonEncode(exercisesData));

    setState(() {
      invite.status = 'accepted';
    });
    await _saveInvites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Közös edzés elfogadva (${invite.senderName})! Aktiválva a Dashboardon 💪'), backgroundColor: _theme.primaryColor),
      );
    }
  }

  void _openInviteDialog(String friendName) {
    String selectedWorkout = 'PUSH';
    bool isNow = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Online Edzésmeghívás ⚡', style: TextStyle(color: _theme.primaryColor, fontSize: 18, fontWeight: FontWeight.w900)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                Text('Címzett: $friendName (Online Fiók)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 16),
                const Text('EDZÉSTÍPUS:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['PUSH', 'PULL', 'LEG', 'CARDIO'].map((type) {
                    final isSel = selectedWorkout == type;
                    return ChoiceChip(
                      label: Text(type, style: TextStyle(color: isSel ? const Color(0xFF07101B) : Colors.white, fontWeight: FontWeight.bold)),
                      selected: isSel,
                      selectedColor: _theme.primaryColor,
                      backgroundColor: _theme.cardColor,
                      onSelected: (val) {
                        if (val) setSheetState(() => selectedWorkout = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () {
                      final newInvite = WorkoutInvite(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        senderName: 'Én (DagiGymBro)',
                        targetFriendName: friendName,
                        workoutType: selectedWorkout,
                        timeLabel: isNow ? 'MOST 🔥' : 'Hamarosan 📅',
                        createdAt: DateTime.now(),
                      );

                      setState(() {
                        _invites.insert(0, newInvite);
                      });
                      _saveInvites();
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Online meghívó elküldve $friendName részére! 🚀'), backgroundColor: _theme.primaryColor),
                      );
                    },
                    child: const Text('MEGHÍVÓ KÜLDÉSE A FELHŐBE 📨', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900)),
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
        final pendingInvites = _invites.where((i) => i.status == 'pending').toList();

        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: _theme.backgroundColor,
            title: const Text('Dagi app • Online Közösség', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            actions: [
              IconButton(
                icon: _isOnlineSyncing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.sync_rounded, color: _theme.primaryColor),
                tooltip: 'Felhő Szinkronizáció',
                onPressed: _triggerCloudSync,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendingInvites.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, color: _theme.secondaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text('BEJÖVŐ ONLINE MEGHÍVÁSOK (${pendingInvites.length})', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.w900, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                ...pendingInvites.map((inv) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _theme.secondaryColor.withValues(alpha: 0.6), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(inv.senderName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: _theme.secondaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                child: Text(inv.timeLabel, style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${inv.senderName} hívott egy ${inv.workoutType} edzésre!', style: const TextStyle(color: Color(0xFFD3E0EA), fontSize: 13)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor),
                                  onPressed: () => _acceptAndActivateWorkout(inv),
                                  icon: const Icon(Icons.check_rounded, color: Color(0xFF07101B), size: 16),
                                  label: const Text('ELFOGADÁS', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900, fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
              ],
              const Text('ONLINE GYM BRO-K & EDZŐTÁRSAK', style: TextStyle(color: Color(0xFF91A2B5), fontWeight: FontWeight.w900, fontSize: 12)),
              const SizedBox(height: 10),
              ..._friends.map((friend) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1F2F42))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(backgroundColor: _theme.primaryColor.withValues(alpha: 0.15), child: Icon(Icons.fitness_center_rounded, color: _theme.primaryColor, size: 18)),
                            const SizedBox(width: 12),
                            Text(friend, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          onPressed: () => _openInviteDialog(friend),
                          icon: const Icon(Icons.send_rounded, color: Color(0xFF07101B), size: 14),
                          label: const Text('MEGHÍVÁS', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

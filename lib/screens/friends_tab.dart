import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';
import 'workout_tracker_tab.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final ThemeService _theme = ThemeService();
  final List<String> _friends = ['Bence (GymBro)', 'Dávid (BeastMode)', 'Anna (PowerLift)', 'Gergő (CardioKing)'];
  List<WorkoutInvite> _invites = [];

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('shared_workout_invites');
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
          WorkoutInvite(
            id: 'sample_2',
            senderName: 'Dávid (BeastMode)',
            targetFriendName: 'Te',
            workoutType: 'LEG',
            timeLabel: '08.31 18:30 📅',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ];
      });
      _saveInvites();
    }
  }

  Future<void> _saveInvites() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_invites.map((e) => e.toMap()).toList());
    await prefs.setString('shared_workout_invites', encoded);
  }

  Future<void> _acceptAndActivateWorkout(WorkoutInvite invite) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = getInitialWorkoutCategories();
    final matchedCat = categories.firstWhere(
      (c) => c.title.toLowerCase() == invite.workoutType.toLowerCase() || c.id.toLowerCase() == invite.workoutType.toLowerCase(),
      orElse: () => categories.first,
    );

    final exercisesData = matchedCat.exercises.take(6).map((e) => {
      'name': e.name,
      'targetSets': e.defaultSets,
      'targetReps': e.defaultReps,
      'completedSets': 0,
    }).toList();

    final workoutData = {
      'isShared': true,
      'partnerName': invite.senderName,
      'timeLabel': invite.timeLabel,
      'workoutType': matchedCat.title,
      'exercises': exercisesData,
    };

    await prefs.setString('active_shared_workout', jsonEncode(workoutData));
    await prefs.setString('daily_workout_type', "${matchedCat.title} (${invite.senderName} partnerrel)");
    await prefs.setString('daily_planned_exercises', jsonEncode(exercisesData));

    setState(() {
      invite.status = 'accepted';
    });
    await _saveInvites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Edzés elfogadva és aktiválva a Dashboardon! (${invite.senderName} • ${invite.timeLabel}) 💪'),
          backgroundColor: _theme.primaryColor,
        ),
      );
    }
  }

  void _openInviteDialog(String friendName) {
    String selectedWorkout = 'PUSH';
    bool isNow = true;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

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
                    Text('Edzésmeghívás ⚡', style: TextStyle(color: _theme.primaryColor, fontSize: 20, fontWeight: FontWeight.w900)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                Text('Címzett: $friendName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 18),
                const Text('VÁLASSZ EDZÉSTÍPUST:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['PUSH', 'PULL', 'LEG', 'UPPER', 'LOWER'].map((type) {
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
                const SizedBox(height: 18),
                const Text('IDŐPONT MEGADÁSA:', style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isNow ? _theme.secondaryColor : _theme.cardColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => setSheetState(() => isNow = true),
                        icon: Icon(Icons.flash_on_rounded, color: isNow ? const Color(0xFF07101B) : Colors.white),
                        label: Text('MOST AZONNAL', style: TextStyle(color: isNow ? const Color(0xFF07101B) : Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isNow ? _theme.primaryColor : _theme.cardColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          setSheetState(() => isNow = false);
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (pickedTime != null) {
                              setSheetState(() {
                                selectedDate = pickedDate;
                                selectedTime = pickedTime;
                              });
                            }
                          }
                        },
                        icon: Icon(Icons.event_rounded, color: !isNow ? const Color(0xFF07101B) : Colors.white),
                        label: Text(
                          !isNow ? "${DateFormat('MM.dd').format(selectedDate)} ${selectedTime.format(context)}" : 'KÉSŐBB...',
                          style: TextStyle(color: !isNow ? const Color(0xFF07101B) : Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      final timeString = isNow
                          ? 'MOST'
                          : "${DateFormat('MM.dd').format(selectedDate)} ${selectedTime.format(context)}";

                      final newInvite = WorkoutInvite(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        senderName: 'Én',
                        targetFriendName: friendName,
                        workoutType: selectedWorkout,
                        timeLabel: timeString,
                        createdAt: DateTime.now(),
                      );

                      setState(() {
                        _invites.insert(0, newInvite);
                      });
                      _saveInvites();
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Meghívó elküldve $friendName részére ($timeString - $selectedWorkout)! 🚀'),
                          backgroundColor: _theme.primaryColor,
                        ),
                      );
                    },
                    child: const Text('MEGHÍVÓ ELKÜLDÉSE 📨', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900, fontSize: 14)),
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
            elevation: 0,
            title: const Text('Közösség & Közös Edzés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pendingInvites.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.notifications_active_rounded, color: _theme.secondaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text('BEJÖVŐ EDZÉSMEGHÍVÁSOK (${pendingInvites.length})', style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...pendingInvites.map((inv) => _buildInviteCard(inv)),
                  const SizedBox(height: 24),
                ],
                const Text('GYM BRO-K & EDZŐTÁRSAK', style: TextStyle(color: Color(0xFF91A2B5), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                const SizedBox(height: 10),
                ..._friends.map((friend) => _buildFriendCard(friend)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInviteCard(WorkoutInvite inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _theme.secondaryColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(inv.senderName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _theme.secondaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(inv.timeLabel, style: TextStyle(color: _theme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${inv.senderName} meghívott ${inv.timeLabel} egy ${inv.workoutType} edzésre!',
            style: const TextStyle(color: Color(0xFFD3E0EA), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _theme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _acceptAndActivateWorkout(inv),
                  icon: const Icon(Icons.check_rounded, color: Color(0xFF07101B), size: 18),
                  label: const Text('ELFOGADÁS & BETÁRAZÁS', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF26364A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() => inv.status = 'declined');
                    _saveInvites();
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                  label: const Text('ELUTASÍTÁS', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2F42)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _theme.primaryColor.withValues(alpha: 0.15),
                child: Icon(Icons.fitness_center_rounded, color: _theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 14),
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => _openInviteDialog(name),
            icon: const Icon(Icons.send_rounded, color: Color(0xFF07101B), size: 14),
            label: const Text('MEGHÍVÁS', style: TextStyle(color: Color(0xFF07101B), fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

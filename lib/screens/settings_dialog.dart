import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _enabled = true;
  int _intervalHours = 2;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  final List<int> _intervalOptions = [1, 2, 3, 4, 6, 8, 12];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool('custom_notif_enabled') ?? true;
      _intervalHours = prefs.getInt('custom_notif_interval') ?? 2;
      _titleController.text =
          prefs.getString('custom_notif_title') ?? 'Idő a fehérjére! 🥛';
      _bodyController.text =
          prefs.getString('custom_notif_body') ?? 'Edd meg a kajád vagy idd meg a shake-et!';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('custom_notif_enabled', _enabled);
    await prefs.setInt('custom_notif_interval', _intervalHours);
    await prefs.setString('custom_notif_title', _titleController.text);
    await prefs.setString('custom_notif_body', _bodyController.text);

    if (_enabled) {
      await NotificationService.scheduleIntervalReminder(
        title: _titleController.text,
        body: _bodyController.text,
        intervalHours: _intervalHours,
      );
    } else {
      await NotificationService.cancelCustomReminder();
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Egyedi értesítés beállítva!', style: TextStyle(color: Color(0xFF28D5CF))),
          backgroundColor: Color(0xFF0D1825),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF07101B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF26364A)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Egyedi Értesítés',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFF5F8FB)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF91A2B5), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1825),
                  border: Border.all(color: const Color(0xFF26364A)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Értesítések engedélyezése',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF5F8FB)),
                    ),
                    Switch(
                      value: _enabled,
                      activeColor: const Color(0xFF28D5CF),
                      activeTrackColor: const Color(0xFF166864),
                      inactiveThumbColor: const Color(0xFF91A2B5),
                      inactiveTrackColor: const Color(0xFF111F2E),
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                  ],
                ),
              ),
              if (_enabled) ...[
                const SizedBox(height: 16),
                const Text('Milyen gyakran ismétlődjön?', style: TextStyle(fontSize: 13, color: Color(0xFF91A2B5))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1825),
                    border: Border.all(color: const Color(0xFF26364A)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _intervalHours,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0D1825),
                      style: const TextStyle(color: Color(0xFF28D5CF), fontWeight: FontWeight.bold),
                      items: _intervalOptions.map((hours) {
                        return DropdownMenuItem<int>(
                          value: hours,
                          child: Text('Minden $hours órában'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _intervalHours = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Értesítés Címe', style: TextStyle(fontSize: 13, color: Color(0xFF91A2B5))),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0D1825),
                    hintText: 'Pl. Igyál fehérjét!',
                    hintStyle: const TextStyle(color: Color(0xFF55687D)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF26364A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF28D5CF)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Értesítés Szövege', style: TextStyle(fontSize: 13, color: Color(0xFF91A2B5))),
                const SizedBox(height: 8),
                TextField(
                  controller: _bodyController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0D1825),
                    hintText: 'Pl. Napi 2g/tskg fehérje a cél!',
                    hintStyle: const TextStyle(color: Color(0xFF55687D)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF26364A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF28D5CF)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF356D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _saveSettings,
                  child: const Text(
                    'MENTÉS ÉS AKTIVÁLÁS',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
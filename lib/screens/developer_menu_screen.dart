import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class DeveloperMenuScreen extends StatelessWidget {
  const DeveloperMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService theme = ThemeService();
    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(backgroundColor: theme.backgroundColor, title: const Text('Developer Titkos Menü 🛠️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orangeAccent)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Debug & Fejlesztői Eszközök', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Itt tesztelhetők a helyi adattárolási state-ek, offline sync és lokális mock adatok.', style: TextStyle(color: Color(0xFFD3E0EA), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                tileColor: theme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                title: const Text('Helyi cache ürítése (SharedPreferences)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache kiürítve! 🧹')));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

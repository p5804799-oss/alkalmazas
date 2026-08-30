import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../providers/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();
    final appState = context.watch<AppState>();
    final bool hasWorkoutToday = false; 
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Edzés Státusz
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hasWorkoutToday ? theme.secondaryColor : Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MAI EDZÉS', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Text('🛋️ ', style: TextStyle(fontSize: 24)),
                  Text('Pihi van bástya!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Kalória Kártya
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedBackgroundColor: theme.cardColor,
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Napi Makrók & Kalória', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('1450 / 2450 kcal', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.primaryColor, width: 8)),
                      child: const Center(child: Text('60%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('🥩 Fehérje: 120 / 180g', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 8),
                        Text('🍚 Szénhidrát: 150 / 220g', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 8),
                        Text('🥑 Zsír: 45 / 70g', style: TextStyle(color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Víz és Lépés Interakció
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                theme: theme, title: 'Vízbevitel', value: '${appState.waterIntake} ml',
                icon: Icons.water_drop, color: Colors.blueAccent, btnText: '+ 250 ml',
                onTap: () => context.read<AppState>().addWater(250),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                theme: theme, title: 'Lépésszám', value: '${appState.steps}',
                icon: Icons.directions_walk, color: Colors.orangeAccent, btnText: '+ 1000',
                onTap: () => context.read<AppState>().addSteps(1000),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({required ThemeService theme, required String title, required String value, required IconData icon, required Color color, required String btnText, required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color.withValues(alpha: 0.2), foregroundColor: color, elevation: 0),
            onPressed: onTap,
            child: Text(btnText),
          )
        ],
      ),
    );
  }
}

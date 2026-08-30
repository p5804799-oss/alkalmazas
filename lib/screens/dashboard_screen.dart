import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();
    final bool hasWorkoutToday = false; // Később bekötjük az adatbázisból
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Edzés Státusz Kártya
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
              if (hasWorkoutToday)
                const Text('Felsőtest & Core', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))
              else
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

        // 2. Lenyitható Kalória és Makró Kártya
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
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor, width: 8),
                      ),
                      child: const Center(child: Text('60%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('🥩 Fehérje: 120g / 180g', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 8),
                        Text('🍚 Szénhidrát: 150g / 220g', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 8),
                        Text('🥑 Zsír: 45g / 70g', style: TextStyle(color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

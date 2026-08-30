import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'workout_screen.dart';
import 'food_recipe_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'community_screen.dart';
import 'dev_designer_sheet.dart';
import '../services/theme_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  int _secretTapCount = 0;
  DateTime? _lastTapTime;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WorkoutScreen(),
    const FoodRecipeScreen(),
    const ProgressScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  void _handleSecretTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _secretTapCount = 1;
    } else {
      _secretTapCount++;
    }
    _lastTapTime = now;

    if (_secretTapCount >= 5) {
      _secretTapCount = 0;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🕵️ Fejlesztői Mód Aktiválva!')));
      showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) => const DevDesignerSheet());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();
    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            backgroundColor: theme.backgroundColor,
            title: GestureDetector(
              onTap: _handleSecretTap,
              child: const Text('Dagi app', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: theme.cardColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: theme.primaryColor,
            unselectedItemColor: Colors.grey,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Főoldal'),
              BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Edzés'),
              BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Ételek'),
              BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Fejlődés'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Közösség'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        );
      }
    );
  }
}

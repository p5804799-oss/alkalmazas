import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'dashboard_tab.dart';
import 'progress_tab.dart';
import 'workout_tracker_tab.dart';
import 'trend_tab.dart';
import 'foods_tab.dart';
import 'recipes_tab.dart';
import 'friends_tab.dart';
import 'profile_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final ThemeService _theme = ThemeService();
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardTab(),
    ProgressTab(),
    WorkoutTrackerTab(),
    TrendTab(),
    FoodsTab(),
    RecipesTab(),
    FriendsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _theme.backgroundColor,
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: _theme.cardColor,
            selectedItemColor: _theme.primaryColor,
            unselectedItemColor: const Color(0xFF91A2B5),
            selectedFontSize: 10,
            unselectedFontSize: 9,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Főoldal'),
              BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Fejlődés'),
              BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: 'Edzés'),
              BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded), label: 'Testsúly'),
              BottomNavigationBarItem(icon: Icon(Icons.fastfood_rounded), label: 'Ételek'),
              BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'Receptek'),
              BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Közösség'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
            ],
          ),
        );
      },
    );
  }
}

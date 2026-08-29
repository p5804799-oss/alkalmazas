import 'package:flutter/material.dart';
import 'dashboard_tab.dart';
import 'friends_tab.dart';
import 'recipes_tab.dart';
import 'foods_tab.dart';
import 'trend_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const DashboardTab(),
      const FriendsTab(),
      const RecipesTab(),
      const FoodsTab(),
      const TrendTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF07101B),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D1825),
        selectedItemColor: const Color(0xFF28D5CF),
        unselectedItemColor: const Color(0xFF91A2B5),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Főoldal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Barátok',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Receptek',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_rounded),
            label: 'Ételek',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded),
            label: 'Trendek',
          ),
        ],
      ),
    );
  }
}
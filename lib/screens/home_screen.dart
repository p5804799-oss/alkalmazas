import 'package:flutter/material.dart';
import 'dashboard_tab.dart';
import 'friends_tab.dart';
import 'recipes_tab.dart';
import 'foods_tab.dart';
import 'trend_tab.dart';
import 'profile_tab.dart';

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
      DashboardTab(onNavigateTab: _onTabChanged),
      const FriendsTab(),
      const RecipesTab(),
      const FoodsTab(),
      const TrendTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B101B),
          border: Border(top: BorderSide(color: Color(0xFF1E2B48), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: const Color(0xFF0B101B),
          indicatorColor: const Color(0xFFFF2E63).withOpacity(0.15),
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _onTabChanged,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white54, size: 22),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF00E5FF), size: 22),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded, color: Colors.white54, size: 22),
              selectedIcon: Icon(Icons.people_rounded, color: Color(0xFFFF2E63), size: 22),
              label: 'Csapat',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined, color: Colors.white54, size: 22),
              selectedIcon: Icon(Icons.restaurant_menu_rounded, color: Color(0xFF00E5FF), size: 22),
              label: 'Receptek',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined, color: Colors.white54, size: 22),
              selectedIcon: Icon(Icons.shopping_bag_rounded, color: Color(0xFFFF2E63), size: 22),
              label: 'Lidl Tár',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart_rounded, color: Colors.white54, size: 22),
              selectedIcon: Icon(Icons.show_chart_rounded, color: Color(0xFF00E5FF), size: 22),
              label: 'Trend',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Colors.white54, size: 22),
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFFFF2E63), size: 22),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
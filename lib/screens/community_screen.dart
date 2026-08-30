import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/theme_service.dart';
import '../models/friend_model.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Friend> _friends = CommunityDatabase.mockFriends;
  
  bool _shareWeight = true;
  bool _shareCalories = true;
  bool _shareWorkouts = true;

  void _showInviteModal(Friend friend) {
    final theme = ThemeService();
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Közös edzés: ${friend.name}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: theme.backgroundColor, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Kiválasztott edzés: Push Nap', style: TextStyle(color: Colors.white)),
                  Icon(Icons.fitness_center, color: Colors.orangeAccent),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.black),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Sikeres edzésmeghívó elküldve ${friend.name} részére!'),
                      backgroundColor: const Color(0xFF00E676),
                    ),
                  );
                },
                child: const Text('Meghívó Elküldése', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.white54,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Barátok & Meghívók'),
              Tab(text: 'Összehasonlítás'),
              Tab(text: 'Adatvédelem'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFriendsTab(theme),
                _buildComparisonTab(theme),
                _buildSettingsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab(ThemeService theme) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.black),
        label: const Text('Barát felvétele', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔍 Barát keresése és hozzáadása hamarosan...')));
        },
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Stack(
                children: [
                  CircleAvatar(backgroundColor: theme.backgroundColor, child: Text(friend.name[0], style: const TextStyle(color: Colors.white))),
                  if (friend.isOnline)
                    Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))),
                ],
              ),
              title: Text(friend.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(friend.status, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.secondaryColor.withValues(alpha: 0.2), foregroundColor: theme.secondaryColor, elevation: 0),
                onPressed: () => _showInviteModal(friend),
                child: const Text('Meghívás'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComparisonTab(ThemeService theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Heti Kalóriabevitel (Te vs Gábor)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white12, strokeWidth: 1)),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) => Text('${val.toInt()}', style: const TextStyle(color: Colors.white54, fontSize: 10)))),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) => Text(['H', 'K', 'Sze', 'Cs', 'P', 'Szo', 'V'][val.toInt()], style: const TextStyle(color: Colors.white54, fontSize: 10)))),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [FlSpot(0, 2400), FlSpot(1, 2300), FlSpot(2, 2500), FlSpot(3, 2200), FlSpot(4, 2600)],
                        isCurved: true, color: theme.primaryColor, barWidth: 3, dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: const [FlSpot(0, 2800), FlSpot(1, 2750), FlSpot(2, 2900), FlSpot(3, 2600), FlSpot(4, 3000)],
                        isCurved: true, color: theme.secondaryColor, barWidth: 3, dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 12, color: theme.primaryColor), const SizedBox(width: 8), const Text('Te', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 24),
                  Container(width: 12, height: 12, color: theme.secondaryColor), const SizedBox(width: 8), const Text('Gábor', style: TextStyle(color: Colors.white)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab(ThemeService theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Megosztott adatok a barátokkal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Testsúly megosztása', style: TextStyle(color: Colors.white)),
          subtitle: const Text('A barátaid láthatják az aktuális súlyodat és fejlődésedet.', style: TextStyle(color: Colors.white54, fontSize: 12)),
          value: _shareWeight,
          activeColor: theme.primaryColor,
          onChanged: (val) => setState(() => _shareWeight = val),
          tileColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Kalória & Makrók megosztása', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Heti grafikonon összehasonlítható lesz a beviteled.', style: TextStyle(color: Colors.white54, fontSize: 12)),
          value: _shareCalories,
          activeColor: theme.primaryColor,
          onChanged: (val) => setState(() => _shareCalories = val),
          tileColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Edzéskiválasztás megosztása', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Láthatják, milyen edzést csinálsz ma.', style: TextStyle(color: Colors.white54, fontSize: 12)),
          value: _shareWorkouts,
          activeColor: theme.primaryColor,
          onChanged: (val) => setState(() => _shareWorkouts = val),
          tileColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ],
    );
  }
}

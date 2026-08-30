import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/theme_service.dart';
import '../providers/app_state.dart';
import '../models/user_profile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddStepsModal(BuildContext context, ThemeService theme) {
    final TextEditingController stepsController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👟 Lépések Megadása', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pl. 4500',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: theme.backgroundColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.black),
                onPressed: () {
                  if (stepsController.text.isNotEmpty) {
                    final int exactSteps = int.tryParse(stepsController.text) ?? 0;
                    context.read<AppState>().addPreciseSteps(exactSteps);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Hozzáadás', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final appState = context.watch<AppState>();
    final userProfile = context.watch<UserProfile>();
    
    final double bmr = userProfile.calculateBMR;
    final double activeBurn = appState.steps * 0.04;
    final double totalBurn = bmr + activeBurn;
    final int deficit = (totalBurn - appState.consumedCalories).round();
    
    final int targetCal = userProfile.calculatedTargetCalories;
    final double calPercent = targetCal > 0 ? (appState.consumedCalories / targetCal).clamp(0.0, 1.0) : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Kiválasztott Edzés Kártya
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: appState.todaysWorkout != 'Pihi van bástya!' ? theme.secondaryColor : Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MAI EDZÉS', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('🔥 ', style: TextStyle(fontSize: 24)),
                  Text(appState.todaysWorkout, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Kalória & Makró Kártya (Valós adatokkal + Nullázó gombbal)
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            collapsedBackgroundColor: theme.cardColor,
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Napi Makrók & Kalória', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white54, size: 18),
                  onPressed: () => context.read<AppState>().resetMeals(),
                  tooltip: 'Étkezések nullázása',
                )
              ],
            ),
            subtitle: Text('${appState.consumedCalories} / $targetCal kcal', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.primaryColor, width: 8)),
                      child: Center(child: Text('${(calPercent * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🥩 Fehérje: ${appState.consumedProtein} / ${userProfile.targetProtein}g', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text('🍚 Szénhidrát: ${appState.consumedCarbs} / ${userProfile.targetCarbs}g', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text('🥑 Zsír: ${appState.consumedFat} / ${userProfile.targetFat}g', style: const TextStyle(color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Deficit Oszlopdiagram
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            collapsedBackgroundColor: theme.cardColor,
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('📉 Napi Deficit & Égetés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(deficit > 0 ? 'Deficit: -$deficit kcal' : 'Többlet: ${deficit.abs()} kcal', style: TextStyle(color: deficit > 0 ? theme.primaryColor : Colors.redAccent, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: totalBurn > appState.consumedCalories ? totalBurn + 500 : appState.consumedCalories.toDouble() + 500,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12);
                                  Widget text = value == 0 ? const Text('Bevitel', style: style) : const Text('Égetés', style: style);
                                  return SideTitleWidget(axisSide: meta.axisSide, child: text);
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [BarChartRodData(toY: appState.consumedCalories.toDouble(), color: Colors.orangeAccent, width: 30, borderRadius: BorderRadius.circular(4))],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [BarChartRodData(toY: totalBurn, color: theme.primaryColor, width: 30, borderRadius: BorderRadius.circular(4))],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Víz és Lépés Interakció (Nullázó gombokkal)
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                theme: theme, title: 'Vízbevitel', value: '${appState.waterIntake} ml',
                icon: Icons.water_drop, color: Colors.blueAccent, btnText: '+ 250 ml',
                onTap: () => context.read<AppState>().addWater(250),
                onReset: () => context.read<AppState>().resetWater(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                theme: theme, title: 'Lépésszám', value: '${appState.steps}',
                icon: Icons.directions_walk, color: Colors.orangeAccent, btnText: 'Beírás',
                onTap: () => _showAddStepsModal(context, theme),
                onReset: () => context.read<AppState>().resetSteps(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({required ThemeService theme, required String title, required String value, required IconData icon, required Color color, required String btnText, required VoidCallback onTap, required VoidCallback onReset}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white54, size: 18),
                onPressed: onReset,
                tooltip: 'Nullázás',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color.withValues(alpha: 0.2), foregroundColor: color, elevation: 0, minimumSize: const Size(double.infinity, 32)),
            onPressed: onTap,
            child: Text(btnText),
          )
        ],
      ),
    );
  }
}

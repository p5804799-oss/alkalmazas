import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfile _profile = UserProfile();

  void _showEditModal() {
    // Később ide jönnek a TextField-ek (beírós módszer)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adatelem szerkesztő hamarosan...')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Személyes Adatok
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('👤 Személyes Adatok', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: Icon(Icons.edit, color: theme.primaryColor), onPressed: _showEditModal),
                ],
              ),
              const Divider(color: Colors.white12),
              _buildRow('Név:', _profile.name),
              _buildRow('Nem & Kor:', '${_profile.gender.name == 'male' ? 'Férfi' : 'Nő'}, ${_profile.age} év'),
              _buildRow('Magasság:', '${_profile.height} cm'),
              _buildRow('Jelenlegi súly:', '${_profile.weight} kg'),
              _buildRow('Cél súly:', '${_profile.targetWeight} kg', color: theme.secondaryColor),
              _buildRow('Napi Lépéscél:', '${_profile.targetSteps} lépés'),
              _buildRow('Vízcél:', '${_profile.targetWater} ml'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // TDEE és Makró Kalkulátor (Lenyitható)
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedBackgroundColor: theme.cardColor,
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('🔥 Számított Napi Szükséglet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('${_profile.calculatedTargetCalories} kcal / nap', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Alapanyagcsere (BMR):', style: TextStyle(color: Colors.white70)),
                        Text('${_profile.calculateBMR.round()} kcal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroBadge('Fehérje', '${_profile.targetProtein}g', theme.primaryColor),
                        _buildMacroBadge('Szénhidrát', '${_profile.targetCarbs}g', Colors.orangeAccent),
                        _buildMacroBadge('Zsír', '${_profile.targetFat}g', Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Deficit / Égetés Követő (Lenyitható)
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedBackgroundColor: theme.cardColor,
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('📉 Napi Deficit & Égetés', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Aktivitás + Edzés becsült égetése', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: 0.65, backgroundColor: Colors.white12, color: theme.secondaryColor, minHeight: 8),
                    const SizedBox(height: 12),
                    Text('Becsült kalóriadeficit ma: -450 kcal', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMacroBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

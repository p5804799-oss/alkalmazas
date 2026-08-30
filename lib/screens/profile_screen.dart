import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditModal(BuildContext context, UserProfile profile, ThemeService theme) {
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(text: profile.age.toString());
    final heightController = TextEditingController(text: profile.height.toString());
    final weightController = TextEditingController(text: profile.weight.toString());
    final targetWeightController = TextEditingController(text: profile.targetWeight.toString());
    final targetStepsController = TextEditingController(text: profile.targetSteps.toString());
    final targetWaterController = TextEditingController(text: profile.targetWater.toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('👤 Személyes Adatok Szerkesztése', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField('Név', nameController, theme),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('Kor', ageController, theme, isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Magasság (cm)', heightController, theme, isNumber: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('Jelenlegi Súly (kg)', weightController, theme, isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Cél Súly (kg)', targetWeightController, theme, isNumber: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('Napi Lépéscél', targetStepsController, theme, isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Vízcél (ml)', targetWaterController, theme, isNumber: true)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.black),
                  onPressed: () {
                    profile.updateProfile(
                      nameController.text,
                      int.tryParse(ageController.text) ?? profile.age,
                      double.tryParse(heightController.text) ?? profile.height,
                      double.tryParse(weightController.text) ?? profile.weight,
                      double.tryParse(targetWeightController.text) ?? profile.targetWeight,
                      int.tryParse(targetStepsController.text) ?? profile.targetSteps,
                      int.tryParse(targetWaterController.text) ?? profile.targetWater,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Változások Mentése', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, ThemeService theme, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: theme.backgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();
    final profile = context.watch<UserProfile>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Személyes Adatok Kártya
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
                  IconButton(icon: Icon(Icons.edit, color: theme.primaryColor), onPressed: () => _showEditModal(context, profile, theme)),
                ],
              ),
              const Divider(color: Colors.white12),
              _buildRow('Név:', profile.name),
              _buildRow('Nem & Kor:', '${profile.gender == Gender.male ? 'Férfi' : 'Nő'}, ${profile.age} év'),
              _buildRow('Magasság:', '${profile.height} cm'),
              _buildRow('Jelenlegi súly:', '${profile.weight} kg'),
              _buildRow('Cél súly:', '${profile.targetWeight} kg', color: theme.secondaryColor),
              _buildRow('Napi Lépéscél:', '${profile.targetSteps} lépés'),
              _buildRow('Vízcél:', '${profile.targetWater} ml'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // TDEE és Makró Kalkulátor
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedBackgroundColor: theme.cardColor,
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('🔥 Számított Napi Szükséglet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('${profile.calculatedTargetCalories} kcal / nap', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Alapanyagcsere (BMR):', style: TextStyle(color: Colors.white70)),
                        Text('${profile.calculateBMR.round()} kcal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroBadge('Fehérje', '${profile.targetProtein}g', theme.primaryColor),
                        _buildMacroBadge('Szénhidrát', '${profile.targetCarbs}g', Colors.orangeAccent),
                        _buildMacroBadge('Zsír', '${profile.targetFat}g', Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Látványosabb Deficit & Égetés Kártya
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📉 Napi Deficit & Célégetés', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: 0.75, backgroundColor: Colors.white12, color: theme.secondaryColor, minHeight: 10),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Célzott kalóriadeficit:', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  Text('-400 kcal / nap', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Becsült heti zsírégetés:', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  Text('~0.5 kg / hét', style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
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

import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class DevDesignerSheet extends StatelessWidget {
  const DevDesignerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService theme = ThemeService();

    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DEV DESIGNER • TÉMA VÁLASZTÓ 🎨', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 14),
              ...ThemeService.presets.map((preset) {
                final isSelected = theme.activePresetId == preset.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? preset.primary.withValues(alpha: 0.2) : theme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? preset.primary : const Color(0xFF26364A)),
                  ),
                  child: ListTile(
                    title: Text(preset.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: Container(width: 20, height: 20, decoration: BoxDecoration(color: preset.primary, shape: BoxShape.circle)),
                    onTap: () {
                      theme.setPreset(preset.id);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

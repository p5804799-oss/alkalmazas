import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class DevDesignerSheet extends StatefulWidget {
  const DevDesignerSheet({super.key});

  @override
  State<DevDesignerSheet> createState() => _DevDesignerSheetState();
}

class _DevDesignerSheetState extends State<DevDesignerSheet> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeService,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF07101B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _themeService.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.palette_rounded, color: _themeService.primaryColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fejlesztői Mód & Dizájn',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                          ),
                          Text(
                            'Telefonon belüli stílusszerkesztő',
                            style: TextStyle(color: Color(0xFF91A2B5), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF91A2B5)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Válassz alkalmazás témát (Azonnali előnézet):',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ...ThemeService.presets.map((preset) {
                final isSelected = _themeService.activePresetId == preset.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: preset.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? preset.primaryAccent : const Color(0xFF26364A),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    onTap: () => _themeService.setPreset(preset),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(backgroundColor: preset.primaryAccent, radius: 10),
                        const SizedBox(width: 6),
                        CircleAvatar(backgroundColor: preset.secondaryAccent, radius: 10),
                      ],
                    ),
                    title: Text(
                      preset.name,
                      style: TextStyle(
                        color: isSelected ? preset.primaryAccent : Colors.white,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: preset.primaryAccent)
                        : null,
                  ),
                );
              }),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }
}

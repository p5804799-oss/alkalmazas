import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _kcalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final k = await StorageService.getTargetKcal();
    final p = await StorageService.getTargetProtein();
    setState(() {
      _kcalCtrl.text = k.toStringAsFixed(0);
      _proteinCtrl.text = p.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beállítások & Célok')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('👤 Felhasználói Adatvédelem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 6),
                  Text(
                    'Ez az alkalmazás 100%-ban offline működik. Semmilyen adat, e-mail cím vagy naplóbejegyzés nem kerül feltöltésre felhőbe, minden csak a te telefonodon tárolódik.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Napi makrócélok', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          TextField(
            controller: _kcalCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Napi Kalóriacél (kcal)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.local_fire_department, color: Colors.amber)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _proteinCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Napi Fehérjecél (g)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.egg_alt_outlined, color: Color(0xFF10B981))),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final k = double.tryParse(_kcalCtrl.text) ?? 2200;
                final p = double.tryParse(_proteinCtrl.text) ?? 190;
                await StorageService.setTargetKcal(k);
                await StorageService.setTargetProtein(p);
                setState(() => _isSaved = true);
                Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _isSaved = false); });
              },
              child: Text(_isSaved ? '✓ Mentve!' : 'Célok mentése', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

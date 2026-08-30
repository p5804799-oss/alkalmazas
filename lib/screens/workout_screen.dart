import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../models/exercise_database.dart';
import '../services/theme_service.dart';
import '../providers/app_state.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String? _activeCategory;
  late List<Exercise> _exercises;
  final Map<String, String?> _categoryImages = {};
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = ['Push', 'Pull', 'Leg', 'Upper', 'Core', 'Cardio'];

  @override
  void initState() {
    super.initState();
    _exercises = ExerciseDatabase.allExercises;
    _loadCategoryImages();
  }

  Future<void> _loadCategoryImages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var cat in _categories) {
        _categoryImages[cat] = prefs.getString('cover_$cat');
      }
    });
  }

  Future<void> _pickCoverImage(String category) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cover_$category', image.path);
      setState(() {
        _categoryImages[category] = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();
    final appState = context.watch<AppState>();

    if (_activeCategory == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Milyen pusztítást végzünk ma?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._categories.map((cat) {
            final String? imgPath = _categoryImages[cat];
            final int count = _exercises.where((Exercise e) => e.category == cat).length;
            return GestureDetector(
              onTap: () => setState(() => _activeCategory = cat),
              child: Container(
                height: 130,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                  image: imgPath != null
                      ? DecorationImage(
                          image: FileImage(File(imgPath)),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.photo_camera, color: Colors.white70, size: 20),
                                onPressed: () => _pickCoverImage(cat),
                                tooltip: 'Borítókép cseréje',
                              ),
                              Icon(Icons.arrow_forward, color: theme.primaryColor),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$count gyakorlat • 1 terv', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.black, minimumSize: const Size(90, 30)),
                            icon: const Icon(Icons.check, size: 14),
                            label: const Text('Maiapp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              appState.setTodaysWorkout('$cat Edzés');
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Kijelölve mára: $cat Edzés!')));
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    final List<Exercise> filteredExercises = _exercises.where((Exercise e) => e.category == _activeCategory).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _activeCategory = null),
              ),
              const SizedBox(width: 8),
              Text('$_activeCategory Gyakorlatok', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredExercises.length,
            itemBuilder: (context, index) {
              final Exercise ex = filteredExercises[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Célizom: ${ex.targetMuscle}', style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Széria: ${ex.sets}', style: const TextStyle(color: Colors.white70)),
                        Text('Ism: ${ex.reps}', style: const TextStyle(color: Colors.white70)),
                        Text('Súly: ${ex.currentWeight} kg', style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/exercise_database.dart';
import '../services/theme_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String _selectedCategory = 'Push'; // Legyen egy konkrét kategória az alap
  final List<String> _categories = ['Kedvencek', 'Push', 'Pull', 'Leg', 'Core', 'Cardio'];
  late List<Exercise> _exercises;
  
  // Kategória borítóképek útvonalai
  final Map<String, String?> _categoryImages = {};
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cover_$_selectedCategory', image.path);
      setState(() {
        _categoryImages[_selectedCategory] = image.path;
      });
    }
  }

  List<Exercise> get _filteredExercises {
    if (_selectedCategory == 'Kedvencek') return _exercises.where((e) => e.isFavorite).toList();
    return _exercises.where((e) => e.category == _selectedCategory).toList();
  }

  void _toggleFavorite(Exercise ex) {
    setState(() {
      ex.isFavorite = !ex.isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService();
    final currentImagePath = _categoryImages[_selectedCategory];
    
    return Column(
      children: [
        // Kategória szűrő sáv
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat == 'Kedvencek' ? '⭐ Kedvencek' : cat, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                  selected: isSelected,
                  selectedColor: theme.primaryColor,
                  backgroundColor: theme.cardColor,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = cat);
                  },
                ),
              );
            },
          ),
        ),
        
        // Dinamikus Borítókép Kártya
        GestureDetector(
          onTap: _pickCoverImage,
          child: Container(
            height: 140,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
              image: currentImagePath != null
                  ? DecorationImage(
                      image: FileImage(File(currentImagePath)),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                    )
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedCategory.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, color: currentImagePath == null ? theme.primaryColor : Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        currentImagePath == null ? 'Koppints a saját borítóképhez' : 'Borítókép cseréje',
                        style: TextStyle(color: currentImagePath == null ? theme.primaryColor : Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Gyakorlatok listája
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filteredExercises.length,
            itemBuilder: (context, index) {
              final ex = _filteredExercises[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(ex.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: Icon(ex.isFavorite ? Icons.star : Icons.star_border, color: ex.isFavorite ? Colors.amber : Colors.grey),
                          onPressed: () => _toggleFavorite(ex),
                        ),
                      ],
                    ),
                    Text('${ex.category} • ${ex.targetMuscle}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatController(context, 'Széria', ex.sets.toString(), theme.primaryColor),
                        _buildStatController(context, 'Ismétlés', ex.reps.toString(), theme.primaryColor),
                        _buildStatController(context, 'Súly (kg)', ex.currentWeight.toStringAsFixed(1), theme.secondaryColor),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatController(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF07101B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

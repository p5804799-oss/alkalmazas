import 'package:flutter/foundation.dart';

class Exercise {
  final String id;
  final String name;
  final String category; // Push, Pull, Leg, Cardio, stb.
  final String targetMuscle;
  bool isFavorite;
  int sets;
  int reps;
  double currentWeight;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.targetMuscle,
    this.isFavorite = false,
    this.sets = 3,
    this.reps = 10,
    this.currentWeight = 0.0,
  });
}

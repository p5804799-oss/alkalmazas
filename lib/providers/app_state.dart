import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  int waterIntake = 0; // ml
  int steps = 0;
  List<double> weightHistory = [85.0, 84.2, 83.5]; // Mock kezdeti adatok

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    waterIntake = prefs.getInt('waterIntake') ?? 0;
    steps = prefs.getInt('steps') ?? 0;
    final savedWeights = prefs.getStringList('weightHistory');
    if (savedWeights != null) {
      weightHistory = savedWeights.map((e) => double.parse(e)).toList();
    }
    notifyListeners();
  }

  Future<void> addWater(int amount) async {
    waterIntake += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterIntake', waterIntake);
    notifyListeners();
  }

  Future<void> addSteps(int amount) async {
    steps += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps', steps);
    notifyListeners();
  }

  Future<void> addWeightMeasurement(double weight) async {
    weightHistory.add(weight);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('weightHistory', weightHistory.map((e) => e.toString()).toList());
    notifyListeners();
  }
}

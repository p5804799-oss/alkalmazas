import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  int waterIntake = 0; // ml
  int steps = 0;
  int consumedCalories = 0;
  int consumedProtein = 0;
  int consumedCarbs = 0;
  int consumedFat = 0;

  String todaysWorkout = 'Pihi van bástya!';
  List<double> weightHistory = [85.0, 84.2, 83.5];

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    waterIntake = prefs.getInt('waterIntake') ?? 0;
    steps = prefs.getInt('steps') ?? 0;
    consumedCalories = prefs.getInt('consumedCalories') ?? 0;
    consumedProtein = prefs.getInt('consumedProtein') ?? 0;
    consumedCarbs = prefs.getInt('consumedCarbs') ?? 0;
    consumedFat = prefs.getInt('consumedFat') ?? 0;
    todaysWorkout = prefs.getString('todaysWorkout') ?? 'Pihi van bástya!';
    final savedWeights = prefs.getStringList('weightHistory');
    if (savedWeights != null) {
      weightHistory = savedWeights.map((e) => double.parse(e)).toList();
    }
    notifyListeners();
  }

  Future<void> addWater(int amount) async {
    waterIntake += amount;
    if (waterIntake < 0) waterIntake = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterIntake', waterIntake);
    notifyListeners();
  }

  Future<void> resetWater() async {
    waterIntake = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterIntake', 0);
    notifyListeners();
  }

  Future<void> addPreciseSteps(int exactSteps) async {
    steps += exactSteps;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps', steps);
    notifyListeners();
  }

  Future<void> resetSteps() async {
    steps = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps', 0);
    notifyListeners();
  }

  Future<void> addFoodMeal(int cal, int p, int c, int f) async {
    consumedCalories += cal;
    consumedProtein += p;
    consumedCarbs += c;
    consumedFat += f;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('consumedCalories', consumedCalories);
    await prefs.setInt('consumedProtein', consumedProtein);
    await prefs.setInt('consumedCarbs', consumedCarbs);
    await prefs.setInt('consumedFat', consumedFat);
    notifyListeners();
  }

  Future<void> resetMeals() async {
    consumedCalories = 0;
    consumedProtein = 0;
    consumedCarbs = 0;
    consumedFat = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('consumedCalories', 0);
    await prefs.setInt('consumedProtein', 0);
    await prefs.setInt('consumedCarbs', 0);
    await prefs.setInt('consumedFat', 0);
    notifyListeners();
  }

  Future<void> setTodaysWorkout(String workoutName) async {
    todaysWorkout = workoutName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todaysWorkout', workoutName);
    notifyListeners();
  }

  Future<void> addWeightMeasurement(double weight) async {
    weightHistory.add(weight);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('weightHistory', weightHistory.map((e) => e.toString()).toList());
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _mealsKey = 'logged_meals_v1';
  static const String _weightsKey = 'logged_weights_v1';
  static const String _targetKcalKey = 'target_kcal';
  static const String _targetProteinKey = 'target_protein';

  static Future<List<Recipe>> loadRecipes() async {
    final String response = await rootBundle.loadString('assets/data/recipes.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Recipe.fromJson(json)).toList();
  }

  static Future<List<FoodItem>> loadFoods() async {
    final String response = await rootBundle.loadString('assets/data/foods.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => FoodItem.fromJson(json)).toList();
  }

  static Future<double> getTargetKcal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_targetKcalKey) ?? 2200.0;
  }

  static Future<void> setTargetKcal(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_targetKcalKey, val);
  }

  static Future<double> getTargetProtein() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_targetProteinKey) ?? 190.0;
  }

  static Future<void> setTargetProtein(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_targetProteinKey, val);
  }

  static Future<List<LoggedMeal>> getMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_mealsKey);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((item) => LoggedMeal.fromMap(item)).toList();
  }

  static Future<void> saveMeal(LoggedMeal meal) async {
    final meals = await getMeals();
    meals.insert(0, meal);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mealsKey, json.encode(meals.map((m) => m.toMap()).toList()));
  }

  static Future<void> deleteMeal(String id) async {
    final meals = await getMeals();
    meals.removeWhere((m) => m.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mealsKey, json.encode(meals.map((m) => m.toMap()).toList()));
  }

  static Future<List<DailyWeightLog>> getWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_weightsKey);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((item) => DailyWeightLog.fromMap(item)).toList();
  }

  static Future<void> saveWeight(DailyWeightLog weightLog) async {
    final weights = await getWeights();
    weights.removeWhere((w) => w.date == weightLog.date);
    weights.add(weightLog);
    weights.sort((a, b) => a.date.compareTo(b.date));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightsKey, json.encode(weights.map((w) => w.toMap()).toList()));
  }
}

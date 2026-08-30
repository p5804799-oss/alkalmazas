import 'package:flutter/foundation.dart';

class FoodItem {
  final String id;
  final String name;
  final String category;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  bool isFavorite;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isFavorite = false,
  });
}

class FoodDatabase {
  static List<FoodItem> get excelLidlRecipes => [
    FoodItem(id: 'f1', name: 'Pikok Pure Csirkemell Szendvics', category: 'Reggeli', calories: 340, protein: 38, carbs: 32, fat: 4, isFavorite: true),
    FoodItem(id: 'f2', name: 'Pilos Zsírszegény Túró Gyümölccsel', category: 'Snack', calories: 390, protein: 44, carbs: 45, fat: 3),
    FoodItem(id: 'f3', name: 'Lidl Csirkemell Jázmin Rizzsel', category: 'Ebéd', calories: 540, protein: 56, carbs: 60, fat: 6, isFavorite: true),
    FoodItem(id: 'f4', name: 'Aligator Tonhalsaláta', category: 'Vacsora', calories: 420, protein: 41, carbs: 34, fat: 12),
    FoodItem(id: 'f5', name: 'Proteines Zabkása (Lidl Whey)', category: 'Reggeli', calories: 310, protein: 30, carbs: 40, fat: 5),
  ];
}

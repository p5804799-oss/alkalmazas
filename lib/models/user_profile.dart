import 'package:flutter/foundation.dart';

enum Gender { male, female }

class UserProfile extends ChangeNotifier {
  String name;
  int age;
  double weight; // kg
  double targetWeight; // kg
  double height; // cm
  Gender gender;
  
  int targetSteps;
  int targetWater; // ml
  
  int? customTargetCalories;
  int? customProtein;
  int? customCarbs;
  int? customFat;

  UserProfile({
    this.name = 'Dagi User',
    this.age = 25,
    this.weight = 85.0,
    this.targetWeight = 75.0,
    this.height = 180.0,
    this.gender = Gender.male,
    this.targetSteps = 10000,
    this.targetWater = 3000,
  });

  double get calculateBMR {
    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    return gender == Gender.male ? bmr + 5 : bmr - 161;
  }

  int get calculatedTargetCalories {
    if (customTargetCalories != null) return customTargetCalories!;
    return (calculateBMR * 1.375).round();
  }

  int get targetProtein => customProtein ?? ((calculatedTargetCalories * 0.30) / 4).round();
  int get targetCarbs => customCarbs ?? ((calculatedTargetCalories * 0.40) / 4).round();
  int get targetFat => customFat ?? ((calculatedTargetCalories * 0.30) / 9).round();

  void updateBasicInfo({required String n, required int a, required double w, required double h, required Gender g}) {
    name = n; age = a; weight = w; height = h; gender = g;
    notifyListeners();
  }
}

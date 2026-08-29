class Recipe {
  final String id;
  final String category;
  final String name;
  final double servings;
  final String ingredients;
  final String instructions;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final String note;
  final String source;

  Recipe({
    required this.id,
    required this.category,
    required this.name,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.note,
    required this.source,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      servings: (json['servings'] as num?)?.toDouble() ?? 1.0,
      ingredients: json['ingredients'] ?? '',
      instructions: json['instructions'] ?? '',
      kcal: (json['kcal'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] ?? '',
      source: json['source'] ?? '',
    );
  }
}

class FoodItem {
  final String category;
  final String name;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final String unit;
  final String note;

  FoodItem({
    required this.category,
    required this.name,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.unit,
    required this.note,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      kcal: (json['kcal'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '100 g',
      note: json['note'] ?? '',
    );
  }
}

class LoggedMeal {
  final String id;
  final String date;
  final String mealType;
  final String name;
  final double amount;
  final String unit;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  LoggedMeal({
    required this.id,
    required this.date,
    required this.mealType,
    required this.name,
    required this.amount,
    required this.unit,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'mealType': mealType,
    'name': name,
    'amount': amount,
    'unit': unit,
    'kcal': kcal,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };

  factory LoggedMeal.fromMap(Map<String, dynamic> map) => LoggedMeal(
    id: map['id'] ?? '',
    date: map['date'] ?? '',
    mealType: map['mealType'] ?? 'Egyéb',
    name: map['name'] ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 1.0,
    unit: map['unit'] ?? 'adag',
    kcal: (map['kcal'] as num?)?.toDouble() ?? 0.0,
    protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
    carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
    fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
  );
}

class DailyWeightLog {
  final String date;
  final double weight;
  final String workoutType;

  DailyWeightLog({
    required this.date,
    required this.weight,
    required this.workoutType,
  });

  Map<String, dynamic> toMap() => {
    'date': date,
    'weight': weight,
    'workoutType': workoutType,
  };

  factory DailyWeightLog.fromMap(Map<String, dynamic> map) => DailyWeightLog(
    date: map['date'] ?? '',
    weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
    workoutType: map['workoutType'] ?? '',
  );
}

class FriendProfile {
  final String id;
  final String inviteCode;
  final String name;
  final String avatar;
  final double currentWeight;
  final double weightChange;
  final String lastWeighInDate;
  final double todayKcal;
  final double targetKcal;
  final double todayProtein;
  final double targetProtein;
  final String todayWorkout;
  final List<LoggedMeal> todayMeals;

  FriendProfile({
    required this.id,
    required this.inviteCode,
    required this.name,
    required this.avatar,
    required this.currentWeight,
    required this.weightChange,
    required this.lastWeighInDate,
    required this.todayKcal,
    required this.targetKcal,
    required this.todayProtein,
    required this.targetProtein,
    required this.todayWorkout,
    required this.todayMeals,
  });
}
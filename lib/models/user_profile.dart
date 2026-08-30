import 'flutter/foundation.dart';
import 'shared_preferences/shared_preferences.dart';

enum Gender { male, female }

class UserProfile extends ChangeNotifier {
  String name = 'Peti';
  Gender gender = Gender.male;
  int age = 28;
  double height = 180.0;
  double weight = 83.5;
  double targetWeight = 78.0;
  int targetSteps = 10000;
  int targetWater = 3000;

  UserProfile() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('prof_name') ?? name;
    age = prefs.getInt('prof_age') ?? age;
    height = prefs.getDouble('prof_height') ?? height;
    weight = prefs.getDouble('prof_weight') ?? weight;
    targetWeight = prefs.getDouble('prof_targetWeight') ?? targetWeight;
    targetSteps = prefs.getInt('prof_targetSteps') ?? targetSteps;
    targetWater = prefs.getInt('prof_targetWater') ?? targetWater;
    notifyListeners();
  }

  Future<void> updateProfile(String n, int a, double h, double w, double tw, int ts, int twat) async {
    name = n;
    age = a;
    height = h;
    weight = w;
    targetWeight = tw;
    targetSteps = ts;
    targetWater = twat;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prof_name', name);
    await prefs.setInt('prof_age', age);
    await prefs.setDouble('prof_height', height);
    await prefs.setDouble('prof_weight', weight);
    await prefs.setDouble('prof_targetWeight', targetWeight);
    await prefs.setInt('prof_targetSteps', targetSteps);
    await prefs.setInt('prof_targetWater', targetWater);
    notifyListeners();
  }

  double get calculateBMR {
    if (gender == Gender.male) {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  int get calculatedTargetCalories => (calculateBMR * 1.375).round() - 400; // Enyhe deficit
  int get targetProtein => (weight * 2.2).round();
  int get targetCarbs => 220;
  int get targetFat => 65;
}

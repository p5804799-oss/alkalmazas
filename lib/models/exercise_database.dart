class Exercise {
  final String id;
  final String name;
  final String category;
  final String targetMuscle;
  int sets;
  int reps;
  double currentWeight;
  bool isFavorite;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.targetMuscle,
    this.sets = 4,
    this.reps = 10,
    this.currentWeight = 50.0,
    this.isFavorite = false,
  });
}

class ExerciseDatabase {
  static List<Exercise> get allExercises => [
    // Push
    Exercise(id: 'e1', name: 'Fekvenyomás rúddal', category: 'Push', targetMuscle: 'Mell', currentWeight: 70),
    Exercise(id: 'e2', name: 'Fekvenyomás kézi súlyzóval', category: 'Push', targetMuscle: 'Mell', currentWeight: 26),
    Exercise(id: 'e3', name: 'Nyomás fekven ferdepadon', category: 'Push', targetMuscle: 'Felső mell', currentWeight: 60),
    Exercise(id: 'e4', name: 'Oldalemelés kézi súlyzóval', category: 'Push', targetMuscle: 'Oldalsó váll', currentWeight: 12),
    Exercise(id: 'e5', name: 'Fej feletti vállnyomás', category: 'Push', targetMuscle: 'Első váll', currentWeight: 45),
    Exercise(id: 'e6', name: 'Tolódzkodás', category: 'Push', targetMuscle: 'Tricepsz / Mell', currentWeight: 0),
    Exercise(id: 'e7', name: 'Tricepsz letolás csigán', category: 'Push', targetMuscle: 'Tricepsz', currentWeight: 30),

    // Pull
    Exercise(id: 'e8', name: 'Húzódzkodás', category: 'Pull', targetMuscle: 'Hát', currentWeight: 0),
    Exercise(id: 'e9', name: 'Lehúzás csigán mellhez', category: 'Pull', targetMuscle: 'Hát', currentWeight: 55),
    Exercise(id: 'e10', name: 'Evezés döntött törzsben rúddal', category: 'Pull', targetMuscle: 'Hát', currentWeight: 60),
    Exercise(id: 'e11', name: 'Egykezes evezés kézi súlyzóval', category: 'Pull', targetMuscle: 'Hát', currentWeight: 28),
    Exercise(id: 'e12', name: 'Arc Pull (Archoz húzás)', category: 'Pull', targetMuscle: 'Hátsó váll', currentWeight: 25),
    Exercise(id: 'e13', name: 'Bicepsz hajlítás rúddal', category: 'Pull', targetMuscle: 'Bicepsz', currentWeight: 30),
    Exercise(id: 'e14', name: 'Kalapács bicepsz kézi súlyzóval', category: 'Pull', targetMuscle: 'Bicepsz', currentWeight: 16),

    // Leg
    Exercise(id: 'e15', name: 'Guggolás rúddal', category: 'Leg', targetMuscle: 'Comb / Farizom', currentWeight: 90),
    Exercise(id: 'e16', name: 'Román felhúzás', category: 'Leg', targetMuscle: 'Combhajlító', currentWeight: 80),
    Exercise(id: 'e17', name: 'Lábtolás gépben', category: 'Leg', targetMuscle: 'Comb', currentWeight: 160),
    Exercise(id: 'e18', name: 'Lábnyújtás gépben', category: 'Leg', targetMuscle: 'Combfeszítő', currentWeight: 50),
    Exercise(id: 'e19', name: 'Lábhajlítás gépben', category: 'Leg', targetMuscle: 'Combhajlító', currentWeight: 45),
    Exercise(id: 'e20', name: 'Vádli állva', category: 'Leg', targetMuscle: 'Vádli', currentWeight: 70),

    // Upper (Push + Pull kombináció)
    Exercise(id: 'e21', name: 'Fekvenyomás rúddal', category: 'Upper', targetMuscle: 'Mell', currentWeight: 70),
    Exercise(id: 'e22', name: 'Lehúzás csigán mellhez', category: 'Upper', targetMuscle: 'Hát', currentWeight: 55),
    Exercise(id: 'e23', name: 'Vállnyomás kézi súlyzóval', category: 'Upper', targetMuscle: 'Váll', currentWeight: 22),
    Exercise(id: 'e24', name: 'Evezés csigán alsó fogással', category: 'Upper', targetMuscle: 'Hát', currentWeight: 50),

    // Core
    Exercise(id: 'e25', name: 'Plank (Alkartámasz)', category: 'Core', targetMuscle: 'Has', currentWeight: 0, reps: 60),
    Exercise(id: 'e26', name: 'Lábemelés függeszkedve', category: 'Core', targetMuscle: 'Alsó has', currentWeight: 0, reps: 15),
    Exercise(id: 'e27', name: 'Hasprés talajon', category: 'Core', targetMuscle: 'Has', currentWeight: 0, reps: 20),

    // Cardio
    Exercise(id: 'e28', name: 'Futópad intervallum', category: 'Cardio', targetMuscle: 'Egész test', currentWeight: 0, reps: 20),
    Exercise(id: 'e29', name: 'Lépcsőgép (Stairmaster)', category: 'Cardio', targetMuscle: 'Comb / Farizom', currentWeight: 0, reps: 15),
  ];
}

import 'exercise.dart';

class ExerciseDatabase {
  static List<Exercise> get allExercises => [
    Exercise(id: 'ex1', name: 'Fekvenyomás rúddal', category: 'Push', targetMuscle: 'Mell'),
    Exercise(id: 'ex2', name: 'Fekvenyomás egykezes súlyzóval', category: 'Push', targetMuscle: 'Mell', isFavorite: true),
    Exercise(id: 'ex3', name: 'Vállból nyomás kézisúlyzóval', category: 'Push', targetMuscle: 'Váll'),
    Exercise(id: 'ex4', name: 'Lehúzás csigán mellhez', category: 'Pull', targetMuscle: 'Hát', isFavorite: true),
    Exercise(id: 'ex5', name: 'Döntött törzsű evezés', category: 'Pull', targetMuscle: 'Hát'),
    Exercise(id: 'ex6', name: 'Bicepsz hajlítás állva', category: 'Pull', targetMuscle: 'Bicepsz'),
    Exercise(id: 'ex7', name: 'Guggolás rúddal', category: 'Leg', targetMuscle: 'Comb', isFavorite: true),
    Exercise(id: 'ex8', name: 'Román felhúzás', category: 'Leg', targetMuscle: 'Combhajlító'),
    Exercise(id: 'ex9', name: 'Vádli állva', category: 'Leg', targetMuscle: 'Vádli'),
    Exercise(id: 'ex10', name: 'Haskerék', category: 'Core', targetMuscle: 'Has'),
  ];
}

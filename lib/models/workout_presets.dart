class WorkoutExercisePreset {
  final String name;
  final int sets;
  final int reps;

  const WorkoutExercisePreset({
    required this.name,
    required this.sets,
    required this.reps,
  });
}

final Map<String, List<WorkoutExercisePreset>> kWorkoutPlanPresets = {
  'Mell - Tricepsz 💪': [
    const WorkoutExercisePreset(name: 'Fekvenyomás rúddal', sets: 4, reps: 8),
    const WorkoutExercisePreset(name: 'Döntött padú nyomás', sets: 3, reps: 10),
    const WorkoutExercisePreset(name: 'Tárogatás csigán', sets: 3, reps: 12),
    const WorkoutExercisePreset(name: 'Tolódzkodás', sets: 3, reps: 10),
    const WorkoutExercisePreset(name: 'Letolás csigán kötéllel', sets: 4, reps: 12),
  ],
  'Hát - Bicepsz 🏋️': [
    const WorkoutExercisePreset(name: 'Lehúzás szélesen mellhez', sets: 4, reps: 10),
    const WorkoutExercisePreset(name: 'Döntött törzsű evezés', sets: 4, reps: 8),
    const WorkoutExercisePreset(name: 'Evezés alsó csigán', sets: 3, reps: 12),
    const WorkoutExercisePreset(name: 'Bicepsz állva francia rúddal', sets: 4, reps: 10),
    const WorkoutExercisePreset(name: 'Kalapács bicepsz kézisúlyzóval', sets: 3, reps: 12),
  ],
  'Láb - Váll 🦵': [
    const WorkoutExercisePreset(name: 'Guggolás rúddal', sets: 4, reps: 8),
    const WorkoutExercisePreset(name: 'Lábtoló gép', sets: 4, reps: 10),
    const WorkoutExercisePreset(name: 'Combhajlító gép', sets: 3, reps: 12),
    const WorkoutExercisePreset(name: 'Vállból nyomás kézisúlyzóval', sets: 4, reps: 8),
    const WorkoutExercisePreset(name: 'Oldalemelés kézisúlyzóval', sets: 4, reps: 15),
  ],
  'Kardió - Has 🏃': [
    const WorkoutExercisePreset(name: 'Futópad / Emelkedős séta', sets: 1, reps: 30),
    const WorkoutExercisePreset(name: 'Lábemelés függeszkedve', sets: 4, reps: 15),
    const WorkoutExercisePreset(name: 'Hasprés padon', sets: 4, reps: 20),
    const WorkoutExercisePreset(name: 'Plank', sets: 3, reps: 60),
  ],
  'Teljes Test (Full Body) 🔥': [
    const WorkoutExercisePreset(name: 'Guggolás rúddal', sets: 3, reps: 8),
    const WorkoutExercisePreset(name: 'Fekvenyomás rúddal', sets: 3, reps: 8),
    const WorkoutExercisePreset(name: 'Döntött törzsű evezés', sets: 3, reps: 8),
    const WorkoutExercisePreset(name: 'Vállból nyomás', sets: 3, reps: 10),
    const WorkoutExercisePreset(name: 'Bicepsz állva rúddal', sets: 2, reps: 12),
  ],
};

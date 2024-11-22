import 'package:vivafit_personal_app/models/training_routine.dart';

class Training {
  String id;
  String name;
  String description;
  String observation;
  String difficulty;
  Duration estimatedExecutionTime;
  double estimatedCaloriesBurned;
  List<TrainingRoutine> routines;

  void addTrainingRoutine(TrainingRoutine routine) {
    routines.add(routine);
  }

  Training({
    required this.id,
    required this.name,
    required this.description,
    required this.observation,
    required this.difficulty,
    required this.estimatedExecutionTime,
    required this.estimatedCaloriesBurned,
    required this.routines,
  });

  factory Training.fromMap(Map<String, dynamic> map) {
    return Training(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      observation: map['observation'],
      difficulty: map['difficulty'],
      estimatedExecutionTime: Duration(minutes: map['estimatedExecutionTime']),
      estimatedCaloriesBurned: map['estimatedCaloriesBurned'],
      routines: List<TrainingRoutine>.from(map['routines'].map((x) => TrainingRoutine.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'observation': observation,
      'difficulty': difficulty,
      'estimatedExecutionTime': estimatedExecutionTime.inMinutes,
      'estimatedCaloriesBurned': estimatedCaloriesBurned,
      'routines': routines.map((x) => x.toMap()).toList(),
    };
  }
}
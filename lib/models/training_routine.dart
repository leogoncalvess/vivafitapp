import 'package:vivafit_personal_app/models/exercise.dart';

class TrainingRoutine {
  String id;
  String name;
  Duration estimatedExecutionTime;
  String difficultyLevel;
  DateTime startDate;
  DateTime endDate;
  String goal;
  String observation;
  List<Exercise> exercises;
  String personalTrainerId;
  String studentId;

  void addExercise(Exercise exercise) {
    exercises.add(exercise);
  }

  TrainingRoutine({
    required this.id,
    required this.name,
    required this.estimatedExecutionTime,
    required this.difficultyLevel,
    required this.startDate,
    required this.endDate,
    required this.goal,
    required this.observation,
    required this.exercises,
    required this.personalTrainerId,
    required this.studentId,
  });

  factory TrainingRoutine.fromMap(Map<String, dynamic> map) {
    return TrainingRoutine(
      id: map['id'],
      name: map['name'],
      estimatedExecutionTime: Duration(minutes: map['estimatedExecutionTime']),
      difficultyLevel: map['difficultyLevel'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      goal: map['goal'],
      observation: map['observation'],
      exercises: List<Exercise>.from(map['exercises'].map((e) => Exercise.fromJson(e))),
      personalTrainerId: map['personalTrainerId'],
      studentId: map['studentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'estimatedExecutionTime': estimatedExecutionTime.inMinutes,
      'difficultyLevel': difficultyLevel,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'goal': goal,
      'observation': observation,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'personalTrainerId': personalTrainerId,
      'studentId': studentId,
    };
  }
}
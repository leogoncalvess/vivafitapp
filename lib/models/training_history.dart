import 'package:vivafit_personal_app/models/user_profile.dart';

class TrainingHistory {
  final DateTime date;
  final int caloriesBurned;
  final int caloriesConsumed;
  final DateTime startTime;
  final DateTime endTime;
  final String feedback;
  final int minHeartRate;
  final int maxHeartRate;
  final int avgHeartRate;
  final int stepsCount;
  final double distanceCovered;
  final String workoutType;
  final String mood;
  final UserProfile userProfile;

  TrainingHistory({
    required this.date,
    required this.caloriesBurned,
    required this.caloriesConsumed,
    required this.startTime,
    required this.endTime,
    required this.feedback,
    required this.minHeartRate,
    required this.maxHeartRate,
    required this.avgHeartRate,
    required this.stepsCount,
    required this.distanceCovered,
    required this.workoutType,
    required this.mood,
    required this.userProfile,
  });

  factory TrainingHistory.fromMap(Map<String, dynamic> map) {
    return TrainingHistory(
      date: DateTime.parse(map['date']),
      caloriesBurned: map['caloriesBurned'],
      caloriesConsumed: map['caloriesConsumed'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      feedback: map['feedback'],
      minHeartRate: map['minHeartRate'],
      maxHeartRate: map['maxHeartRate'],
      avgHeartRate: map['avgHeartRate'],
      stepsCount: map['stepsCount'],
      distanceCovered: map['distanceCovered'],
      workoutType: map['workoutType'],
      mood: map['mood'],
      userProfile: UserProfile.fromMap(map['userProfile']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'caloriesBurned': caloriesBurned,
      'caloriesConsumed': caloriesConsumed,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'feedback': feedback,
      'minHeartRate': minHeartRate,
      'maxHeartRate': maxHeartRate,
      'avgHeartRate': avgHeartRate,
      'stepsCount': stepsCount,
      'distanceCovered': distanceCovered,
      'workoutType': workoutType,
      'mood': mood,
      'userProfile': userProfile.toMap(),
    };
  }
}
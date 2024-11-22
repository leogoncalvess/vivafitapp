import 'package:vivafit_personal_app/models/roles.dart';
import 'package:vivafit_personal_app/models/training_history.dart';

class UserProfile {
  String id;
  String gender;
  DateTime birthDate;
  double height;
  double weight;
  String goal;
  bool isActive;
  String name;
  String email;
  String phone;
  String personalTrainerId;
  String imageUrl;
  List<UserRole> roles;
  List<TrainingHistory> trainingHistory;

  UserProfile({
    required this.id,
    required this.gender,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.goal,
    required this.isActive,
    required this.name,
    required this.email,
    required this.phone,
    required this.personalTrainerId,
    required this.imageUrl,
    required this.roles,
    this.trainingHistory = const [],
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      gender: map['gender'],
      birthDate: DateTime.parse(map['birthDate']),
      height: map['height'],
      weight: map['weight'],
      goal: map['goal'],
      isActive: map['isActive'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      personalTrainerId: map['personalTrainerId'],
      imageUrl: map['imageUrl'],
      roles: (map['roles'] as List).map((role) => UserRole.values.firstWhere((e) => e.toString() == 'UserRole.$role')).toList(),
      trainingHistory: map['trainingHistory'] != null ? (map['trainingHistory'] as List).map((history) => TrainingHistory.fromMap(history)).toList() : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'height': height,
      'weight': weight,
      'goal': goal,
      'isActive': isActive,
      'name': name,
      'email': email,
      'phone': phone,
      'personalTrainerId': personalTrainerId,
      'imageUrl': imageUrl,
      'roles': roles.map((role) => role.toString().split('.').last).toList(),
      'trainingHistory': trainingHistory.map((history) => history.toMap()).toList(),
    };
  }

  bool hasRole(UserRole role) {
    return roles.contains(role);
  }
}
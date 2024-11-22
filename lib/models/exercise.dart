import 'dart:convert';

class Exercise {
  late final String id;
  final String title;
  final String englishName;
  final String description;
  final String category;
  final List<String> activatedMuscleGroups;
  final String difficultyLevel;
  final String requiredEquipment;
  final List<ExecutionStep> executionInstructions;
  final String specificBenefits;
  final String suggestedSetsReps;
  final String safetyTips;
  final List<String> variations;
  final String restTime;
  final String calorieBurn;
  final String videoUrl;

  Exercise({
    required this.id,
    required this.title,
    required this.englishName,
    required this.description,
    required this.category,
    required this.activatedMuscleGroups,
    required this.difficultyLevel,
    required this.requiredEquipment,
    required this.executionInstructions,
    required this.specificBenefits,
    required this.suggestedSetsReps,
    required this.safetyTips,
    required this.variations,
    required this.restTime,
    required this.calorieBurn,
    this.videoUrl = '',
  });

  // Função toJson para converter o objeto em JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'english_name': englishName,
      'description': description,
      'category': category,
      'activated_muscle_groups': activatedMuscleGroups,
      'difficulty_level': difficultyLevel,
      'required_equipment': requiredEquipment,
      'execution_instructions': executionInstructions.map((e) => e.toJson()).toList(),
      'specific_benefits': specificBenefits,
      'suggested_sets_reps': suggestedSetsReps,
      'safety_tips': safetyTips,
      'variations': variations,
      'rest_time': restTime,
      'calorie_burn': calorieBurn,
      'video_url': videoUrl,
    };
  }

  // Função fromJson para criar o objeto a partir de JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    var instructions = json['execution_instructions'] as List;
    List<ExecutionStep> executionSteps = instructions.map((e) => ExecutionStep.fromJson(e)).toList();

    return Exercise(
      id: json['id'] ?? '',
      title: json['title'],
      englishName: json['english_name'],
      description: json['description'],
      category: json['category'],
      activatedMuscleGroups: List<String>.from(json['activated_muscle_groups']),
      difficultyLevel: json['difficulty_level'],
      requiredEquipment: json['required_equipment'],
      executionInstructions: executionSteps,
      specificBenefits: json['specific_benefits'],
      suggestedSetsReps: json['suggested_sets_reps'],
      safetyTips: json['safety_tips'],
      variations: List<String>.from(json['variations']),
      restTime: json['rest_time'],
      calorieBurn: json['calorie_burn'],
      videoUrl: '',
    );
  }
}

class ExecutionStep {
  final int id;
  final String step;
  final String description;

  ExecutionStep({
    required this.id,
    required this.step,
    required this.description,
  });

  // Função toJson para a etapa da execução
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'step': step,
      'description': description,
    };
  }

  // Função fromJson para a etapa da execução
  factory ExecutionStep.fromJson(Map<String, dynamic> json) {
    return ExecutionStep(
      id: json['id'],
      step: json['step'],
      description: json['description'],
    );
  }
}

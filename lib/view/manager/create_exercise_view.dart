import 'package:flutter/material.dart';
import 'package:vivafit_personal_app/models/exercise.dart';
import 'package:vivafit_personal_app/services/exercise_service.dart';
import 'package:uuid/uuid.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';

class CreateExerciseView extends StatefulWidget {
  const CreateExerciseView({super.key});

  @override
  State<CreateExerciseView> createState() => _CreateExerciseViewState();
}

class _CreateExerciseViewState extends State<CreateExerciseView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _loadController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _estimatedCaloriesBurnedController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();  

  final _formKey = GlobalKey<FormState>();
  final _exerciseService = ExerciseService();
  final _uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _observationController.dispose();
    _seriesController.dispose();
    _loadController.dispose();
    _difficultyController.dispose();
    _estimatedCaloriesBurnedController.dispose();
    _videoUrlController.dispose();
    _repetitionsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
  
      Exercise newExercise = Exercise(
        id: _uuid.v4(),
        title: _nameController.text,
        description: _descriptionController.text,
        safetyTips: _observationController.text,
        suggestedSetsReps: _seriesController.text,
        difficultyLevel: _difficultyController.text,
        calorieBurn: _estimatedCaloriesBurnedController.text,
        videoUrl: _videoUrlController.text,
        restTime: _repetitionsController.text, 
        englishName: '', category: '', activatedMuscleGroups: [], requiredEquipment: '', executionInstructions: [], specificBenefits: '', variations: [],
      );

      await _exerciseService.saveExercise(newExercise);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercício criado com sucesso!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Exercício'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  RoundTextField(
                    controller: _nameController,
                    hitText: "Nome",
                    icon: "assets/img/p_achi.png",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um nome';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _descriptionController,
                    hitText: "Descrição",
                    icon: "assets/img/p_achi.png",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma descrição';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _observationController,
                    hitText: "Observação",
                    icon: "assets/img/p_achi.png",
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _seriesController,
                    hitText: "Séries",
                    icon: "assets/img/repetitions.png",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número de séries';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _loadController,
                    hitText: "Carga",
                    icon: "assets/img/weight.png",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a carga';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _difficultyController,
                    hitText: "Dificuldade",
                    icon: "assets/img/difficulity.png",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a dificuldade';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _estimatedCaloriesBurnedController,
                    hitText: "Calorias Estimadas",
                    icon: "assets/img/p_achi.png",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira as calorias estimadas';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    keyboardType: TextInputType.url,
                    acceptedFileTypes: ['mp4', 'mov', 'avi'],
                    firebaseStoragePath: 'exercises',
                    controller: _videoUrlController,
                    hitText: "Vídeo",
                    icon: "assets/img/p_achi.png",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o vídeo';
                      }
                      return null;
                    }                    
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextField(
                    controller: _repetitionsController,
                    hitText: "Repetições",
                    icon: "assets/img/Repeat.png",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número de repetições';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.07),
                  RoundButton(
                    title: "Criar",
                    onPressed: () => _submitForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
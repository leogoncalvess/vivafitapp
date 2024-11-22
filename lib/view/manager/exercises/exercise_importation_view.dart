import 'package:flutter/material.dart';
import 'package:vivafit_personal_app/models/exercise.dart';
import 'package:vivafit_personal_app/services/exercise_service.dart';

class ExerciseImportationView extends StatefulWidget {
  @override
  _ExerciseImportationViewState createState() => _ExerciseImportationViewState();
}

class _ExerciseImportationViewState extends State<ExerciseImportationView> {
  bool _isLoading = false;
  ExerciseService _exerciseService = ExerciseService(); // Serviço
  TextEditingController _jsonController = TextEditingController(); // Controlador para o campo de texto

  // Função chamada quando o botão de importar é pressionado
  Future<void> _importExercises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Exercise> exercises = [];

      // Verifica se o campo de texto não está vazio
      if (_jsonController.text.isNotEmpty) {
        // Importa os exercícios do texto JSON
        exercises = await _exerciseService.importExercisesFromText(_jsonController.text);
      } else {
        // Importa os exercícios do arquivo
        exercises = await _exerciseService.importExercisesFromFile();
      }

      if (exercises.isNotEmpty) {
        // Salva os exercícios importados no Firestore
        await _exerciseService.saveExercises(exercises);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Exercícios importados com sucesso!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Nenhum exercício encontrado no arquivo ou texto.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao importar: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Importar Exercícios'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _jsonController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Cole o JSON aqui',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _importExercises,
                    child: Text('Importar Exercícios'),
                  ),
                ],
              ),
      ),
    );
  }
}
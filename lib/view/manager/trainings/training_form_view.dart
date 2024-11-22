import 'package:flutter/material.dart';
import 'package:vivafit_personal_app/models/training.dart';
import 'package:vivafit_personal_app/models/training_routine.dart';
import 'package:vivafit_personal_app/services/training_service.dart';
import 'package:vivafit_personal_app/services/training_routine_service.dart';
import 'package:vivafit_personal_app/view/manager/trainings/training_routine_form_view.dart';

class TrainingFormView extends StatefulWidget {
  final Training? training;

  TrainingFormView({this.training});

  @override
  _TrainingFormViewState createState() => _TrainingFormViewState();
}

class _TrainingFormViewState extends State<TrainingFormView> {
  final _formKey = GlobalKey<FormState>();
  final TrainingService _trainingService = TrainingService();
  final TrainingRoutineService _trainingRoutineService = TrainingRoutineService();

  late String _name;
  late String _description;
  late String _observation;
  late String _difficulty;
  late Duration _estimatedExecutionTime;
  late double _estimatedCaloriesBurned;
  List<TrainingRoutine> _routines = [];

  @override
  void initState() {
    super.initState();
    if (widget.training != null) {
      _name = widget.training!.name;
      _description = widget.training!.description;
      _observation = widget.training!.observation;
      _difficulty = widget.training!.difficulty;
      _estimatedExecutionTime = widget.training!.estimatedExecutionTime;
      _estimatedCaloriesBurned = widget.training!.estimatedCaloriesBurned;
      _routines = widget.training!.routines;
    } else {
      _name = '';
      _description = '';
      _observation = '';
      _difficulty = '';
      _estimatedExecutionTime = Duration(minutes: 0);
      _estimatedCaloriesBurned = 0.0;
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Training training = Training(
        id: widget.training?.id ?? '',
        name: _name,
        description: _description,
        observation: _observation,
        difficulty: _difficulty,
        estimatedExecutionTime: _estimatedExecutionTime,
        estimatedCaloriesBurned: _estimatedCaloriesBurned,
        routines: _routines,
      );
      if (widget.training == null) {
        _trainingService.createTraining(training);
      } else {
        _trainingService.updateTraining(training);
      }
      Navigator.of(context).pop();
    }
  }

  void _addRoutine() async {
    TrainingRoutine? routine = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TrainingRoutineFormView(),
      ),
    );
    if (routine != null) {
      setState(() {
        _routines.add(routine);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.training == null ? 'Criar Treino' : 'Editar Treino'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                initialValue: _observation,
                decoration: InputDecoration(labelText: 'Observação'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira a observação';
                  }
                  return null;
                },
                onSaved: (value) {
                  _observation = value!;
                },
              ),
              TextFormField(
                initialValue: _difficulty,
                decoration: InputDecoration(labelText: 'Dificuldade'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira a dificuldade';
                  }
                  return null;
                },
                onSaved: (value) {
                  _difficulty = value!;
                },
              ),
              TextFormField(
                initialValue: _estimatedExecutionTime.inMinutes.toString(),
                decoration: InputDecoration(labelText: 'Tempo Estimado de Execução (minutos)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira o tempo estimado de execução';
                  }
                  return null;
                },
                onSaved: (value) {
                  _estimatedExecutionTime = Duration(minutes: int.parse(value!));
                },
              ),
              TextFormField(
                initialValue: _estimatedCaloriesBurned.toString(),
                decoration: InputDecoration(labelText: 'Calorias Estimadas Queimadas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira as calorias estimadas queimadas';
                  }
                  return null;
                },
                onSaved: (value) {
                  _estimatedCaloriesBurned = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addRoutine,
                child: Text('Adicionar Rotina de Treino'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text('Salvar Treino'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
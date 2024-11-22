import 'package:flutter/material.dart';
import 'package:vivafit_personal_app/models/exercise.dart';
import 'package:vivafit_personal_app/models/training_routine.dart';
import 'package:vivafit_personal_app/services/exercise_service.dart';
import 'package:vivafit_personal_app/services/training_routine_service.dart';
import 'package:vivafit_personal_app/view/manager/exercises/exercise_search_view.dart';

class TrainingRoutineFormView extends StatefulWidget {
  final TrainingRoutine? routine;

  TrainingRoutineFormView({this.routine});

  @override
  _TrainingRoutineFormViewState createState() => _TrainingRoutineFormViewState();
}

class _TrainingRoutineFormViewState extends State<TrainingRoutineFormView> {
  final _formKey = GlobalKey<FormState>();
  final ExerciseService _exerciseService = ExerciseService();
  final TrainingRoutineService _trainingRoutineService = TrainingRoutineService();

  late String _name;
  late Duration _estimatedExecutionTime;
  late String _difficultyLevel;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _goal;
  late String _observation;
  List<Exercise> _exercises = [];
  late String _personalTrainerId;
  late String _studentId;

  @override
  void initState() {
    super.initState();
    if (widget.routine != null) {
      _name = widget.routine!.name;
      _estimatedExecutionTime = widget.routine!.estimatedExecutionTime;
      _difficultyLevel = widget.routine!.difficultyLevel;
      _startDate = widget.routine!.startDate;
      _endDate = widget.routine!.endDate;
      _goal = widget.routine!.goal;
      _observation = widget.routine!.observation;
      _exercises = widget.routine!.exercises;
      _personalTrainerId = widget.routine!.personalTrainerId;
      _studentId = widget.routine!.studentId;
    } else {
      _name = '';
      _estimatedExecutionTime = Duration();
      _difficultyLevel = '';
      _startDate = DateTime.now();
      _endDate = DateTime.now();
      _goal = '';
      _observation = '';
      _personalTrainerId = '';
      _studentId = '';
    }
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      TrainingRoutine routine = TrainingRoutine(
        id: widget.routine?.id ?? '',
        name: _name,
        estimatedExecutionTime: _estimatedExecutionTime,
        difficultyLevel: _difficultyLevel,
        startDate: _startDate,
        endDate: _endDate,
        goal: _goal,
        observation: _observation,
        exercises: _exercises,
        personalTrainerId: _personalTrainerId,
        studentId: _studentId,
      );
      if (widget.routine == null) {
        _trainingRoutineService.createTrainingRoutine(routine);
      } else {
        _trainingRoutineService.updateTrainingRoutine(routine);
      }
      Navigator.of(context).pop(routine);
    }
  }

void _addExercise() async {
  List<Exercise>? selectedExercises = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ExerciseSearchView(
        onExerciseSelected: (selectedExercise) {
          Navigator.pop(context, selectedExercise);
        },
      ),
    ),
  );
  if (selectedExercises != null) {
    setState(() {
      _exercises.addAll(selectedExercises);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? 'Create Routine' : 'Edit Routine'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveRoutine,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _goal,
                decoration: InputDecoration(labelText: 'Goal'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal';
                  }
                  return null;
                },
                onSaved: (value) {
                  _goal = value!;
                },
              ),
              TextFormField(
                initialValue: _observation,
                decoration: InputDecoration(labelText: 'Observation'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an observation';
                  }
                  return null;
                },
                onSaved: (value) {
                  _observation = value!;
                },
              ),
              ElevatedButton(
                onPressed: _addExercise,
                child: Text('Add Exercise'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    Exercise exercise = _exercises[index];
                    return ListTile(
                      title: Text(exercise.title),
                      subtitle: Text(exercise.description),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _exercises.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
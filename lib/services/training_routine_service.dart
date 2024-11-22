import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vivafit_personal_app/models/exercise.dart';
import 'package:vivafit_personal_app/models/training_routine.dart';

class TrainingRoutineService {
  final CollectionReference _trainingRoutinesCollection = FirebaseFirestore.instance.collection('trainingRoutines');

  Future<void> createTrainingRoutine(TrainingRoutine trainingRoutine) async {
    await _trainingRoutinesCollection.doc(trainingRoutine.id).set(trainingRoutine.toMap());
  }

  Future<void> saveTrainingRoutine(TrainingRoutine trainingRoutine) async {
    await _trainingRoutinesCollection.doc(trainingRoutine.id).set(trainingRoutine.toMap());
  }

  Future<void> deleteTrainingRoutine(String id) async {
    await _trainingRoutinesCollection.doc(id).delete();
  }

  Future<void> updateTrainingRoutine(TrainingRoutine trainingRoutine) async {
    await _trainingRoutinesCollection.doc(trainingRoutine.id).update(trainingRoutine.toMap());
  }

  Future<void> updateTrainingRoutineGoal(String trainingRoutineId, String goal) async {
    await _trainingRoutinesCollection.doc(trainingRoutineId).update({'goal': goal});
  }

  Future<void> updateTrainingRoutineObservation(String trainingRoutineId, String observation) async {
    await _trainingRoutinesCollection.doc(trainingRoutineId).update({'observation': observation});
  }

  Future<void> updateTrainingRoutinePersonalTrainer(String trainingRoutineId, String personalTrainerId) async {
    await _trainingRoutinesCollection.doc(trainingRoutineId).update({'personalTrainerId': personalTrainerId});
  }

  Future<TrainingRoutine?> getTrainingRoutineById(String id) async {
    DocumentSnapshot doc = await _trainingRoutinesCollection.doc(id).get();
    if (doc.exists) {
      return TrainingRoutine.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<TrainingRoutine>> searchTrainingRoutines({required String personalTrainerId, String? name, String? studentId}) async {
    Query query = _trainingRoutinesCollection.where('personalTrainerId', isEqualTo: personalTrainerId);
    if (name != null) {
      query = query.where('name', isEqualTo: name);
    } else if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<TrainingRoutine> trainingRoutines = querySnapshot.docs.map((doc) {
      return TrainingRoutine.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return trainingRoutines;
  }

  Future<void> addExerciseToTrainingRoutine(String routineId, Exercise exercise) async {
    TrainingRoutine? routine = await getTrainingRoutineById(routineId);
    if (routine != null) {
      routine.addExercise(exercise);
      await updateTrainingRoutine(routine);
    }
  }
}
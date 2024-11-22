import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vivafit_personal_app/models/training.dart';
import 'package:vivafit_personal_app/models/training_routine.dart';

class TrainingService {
  final CollectionReference _trainingsCollection = FirebaseFirestore.instance.collection('trainings');

  Future<void> createTraining(Training training) async {
    await _trainingsCollection.doc(training.id).set(training.toMap());
  }

  Future<void> saveTraining(Training training) async {
    await _trainingsCollection.doc(training.id).set(training.toMap());
  }

  Future<void> deleteTraining(String id) async {
    await _trainingsCollection.doc(id).delete();
  }

  Future<void> updateTraining(Training training) async {
    await _trainingsCollection.doc(training.id).update(training.toMap());
  }

  Future<Training?> getTrainingById(String id) async {
    DocumentSnapshot doc = await _trainingsCollection.doc(id).get();
    if (doc.exists) {
      return Training.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Training>> searchTrainings({String? name, String? difficulty}) async {
    Query query = _trainingsCollection;
    if (name != null) {
      query = query.where('name', isEqualTo: name);
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<Training> trainings = querySnapshot.docs.map((doc) {
      return Training.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return trainings;
  }

  Future<void> addTrainingRoutineToTraining(String trainingId, TrainingRoutine routine) async {
    Training? training = await getTrainingById(trainingId);
    if (training != null) {
      training.addTrainingRoutine(routine);
      await updateTraining(training);
    }
  }

}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vivafit_personal_app/models/exercise.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:vivafit_personal_app/models/paginated_exercises.dart';

class ExerciseService {
  final CollectionReference _exercisesCollection = FirebaseFirestore.instance.collection('exercises');
  final ExercisePaginator paginator = ExercisePaginator();

  // Função para gerar um ID único usando UUID
  String generateId() {
    var uuid = Uuid();
    return uuid.v4();  // Gera um ID único usando UUID v4
  }

  // Função para importar os exercícios de um arquivo JSON
  Future<List<Exercise>> importExercisesFromFile() async {
    List<Exercise> exercisesList = [];
  
    // Abrir o File Picker para o usuário escolher o arquivo JSON
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
  
    if (result != null) {
      // Pega o caminho do arquivo selecionado
      String filePath = result.files.single.path!;
  
      try {
        // Lê o conteúdo do arquivo JSON
        String jsonString = await File(filePath).readAsString();
        
        // Converte o JSON para a lista de Exercícios
        List<dynamic> jsonList = jsonDecode(jsonString);
        exercisesList = jsonList.map((json) {
          // Gerar um ID único para cada exercício
          json['id'] = generateId();
          return Exercise.fromJson(json);
        }).toList();
      } catch (e) {
        print('Erro ao ler o arquivo JSON: $e');
      }
    }
  
    return exercisesList;
  }

  // Função para importar os exercícios de um texto JSON
  Future<List<Exercise>> importExercisesFromText(String jsonString) async {
    List<Exercise> exercisesList = [];
    try {
      // Converte o JSON para a lista de Exercícios
      List<dynamic> jsonList = jsonDecode(jsonString);
      exercisesList = jsonList.map((json) {
        // Gerar um ID único para cada exercício
        json['id'] = generateId();
        return Exercise.fromJson(json);
      }).toList();
    } catch (e) {
      print('Erro ao ler o texto JSON: $e');
    }
    return exercisesList;
  }

  // Função para salvar os exercícios no Firestore
  Future<void> saveExercises(List<Exercise> exercisesList) async {
    final firestore = FirebaseFirestore.instance;

    // Itera sobre a lista de exercícios
    for (var exercise in exercisesList) {
      try {
        // Verificar se já existe um exercício com o mesmo título no Firestore
        var existingExerciseQuery = await firestore
            .collection('exercises') // Usar o nome da coleção em inglês
            .where('titulo', isEqualTo: exercise.title)
            .get();

        // Se o exercício já existe, não adiciona
        if (existingExerciseQuery.docs.isNotEmpty) {
          print('Exercício com o título "${exercise.title}" já existe no Firestore.');
        } else {
          // Se não existe, cria um novo documento com o ID fornecido
          await saveExercise(exercise);
          print('Exercício "${exercise.title}" salvo com sucesso!');
        }
      } catch (e) {
        print('Erro ao salvar exercício: $e');
      }
    }
  }

  Future<void> saveExercise(Exercise exercise) async {
    if (exercise.id.isEmpty) {
      exercise.id = generateId();
    }
    await _exercisesCollection.doc(exercise.id).set(exercise.toJson());
  }

  Future<void> deleteExercise(String id) async {
    await _exercisesCollection.doc(id).delete();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _exercisesCollection.doc(exercise.id).update(exercise.toJson());
  }

  Future<Exercise?> getExerciseById(String id) async {
    DocumentSnapshot doc = await _exercisesCollection.doc(id).get();
    if (doc.exists) {
      return Exercise.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Exercise>> searchExercises({String? name, String? difficulty}) async {
    Query query = _exercisesCollection;
    if (name != null) {
      query = query.where('name', isEqualTo: name);
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<Exercise> exercises = querySnapshot.docs.map((doc) {
      return Exercise.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();

    return exercises;
  }

  // Função para buscar exercícios por categoria
  Future<List<Exercise>> searchExercisesByCategory(String category) async {
    QuerySnapshot querySnapshot = await _exercisesCollection
        .where('category', isEqualTo: category)
        .get();

    List<Exercise> exercises = querySnapshot.docs.map((doc) {
      return Exercise.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();

    return exercises;
  }

  // Função para buscar exercícios com paginação e categoria
  Future<PaginatedExercises> searchExercisesWithPagination({required String category, int limit = 10}) async {
    Query query = _exercisesCollection.orderBy('title');
    if (category != 'Todas') {
      query = query.where('category', isEqualTo: category);
    }

    return paginator.paginate(query, limit: limit);
  }

  Future<PaginatedExercises> loadMoreExercises({required String category, int limit = 10}) async {
    Query query = _exercisesCollection.orderBy('title');
    if (category != 'Todas') {
      query = query.where('category', isEqualTo: category);
    }

    return paginator.paginate(query, limit: limit);
  }

  void resetPagination() {
    paginator.resetPagination();
  }
}
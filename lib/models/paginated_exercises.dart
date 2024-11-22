import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vivafit_personal_app/models/exercise.dart';

class PaginatedExercises {
  final List<Exercise> exercises;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PaginatedExercises({required this.exercises, this.lastDocument, required this.hasMore});
}

class ExercisePaginator {
  DocumentSnapshot? lastDocument;

  Future<PaginatedExercises> paginate(Query query, {int limit = 10}) async {
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    query = query.limit(limit);

    QuerySnapshot querySnapshot = await query.get();
    List<Exercise> exercises = querySnapshot.docs.map((doc) {
      return Exercise.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();

    lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
    bool hasMore = querySnapshot.docs.length == limit;

    return PaginatedExercises(exercises: exercises, lastDocument: lastDocument, hasMore: hasMore);
  }

  void resetPagination() {
    lastDocument = null;
  }
}
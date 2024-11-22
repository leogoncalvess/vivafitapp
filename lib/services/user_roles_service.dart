import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vivafit_personal_app/models/user_roles.dart';

class UserRolesService {
  final CollectionReference userRolesCollection =
      FirebaseFirestore.instance.collection('userRoles');

  // Método para obter as roles de um usuário
  Future<UserRoles?> getUserRoles(String uid) async {
    final doc = await userRolesCollection.doc(uid).get();
    if (doc.exists) {
      return UserRoles.fromDocument(doc);
    }
    return null;
  }

  // Método para adicionar uma role a um usuário
  Future<void> addRoleToUser(String uid, String role) async {
    final userRoles = await getUserRoles(uid);
    if (userRoles != null) {
      if (!userRoles.roles.contains(role)) {
        userRoles.roles.add(role);
        await userRolesCollection.doc(uid).update(userRoles.toMap());
      }
    } else {
      await userRolesCollection.doc(uid).set({
        'roles': [role],
      });
    }
  }

  // Método para remover uma role de um usuário
  Future<void> removeRoleFromUser(String uid, String role) async {
    final userRoles = await getUserRoles(uid);
    if (userRoles != null) {
      userRoles.roles.remove(role);
      await userRolesCollection.doc(uid).update(userRoles.toMap());
    }
  }
}
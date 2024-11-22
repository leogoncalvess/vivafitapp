import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoles {
  final String uid;
  final List<String> roles;

  UserRoles({
    required this.uid,
    required this.roles,
  });

  // Método para converter um documento Firestore em um objeto UserRoles
  factory UserRoles.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserRoles(
      uid: doc.id,
      roles: List<String>.from(data['roles']),
    );
  }

  // Método para converter um objeto UserRoles em um mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'roles': roles,
    };
  }
}
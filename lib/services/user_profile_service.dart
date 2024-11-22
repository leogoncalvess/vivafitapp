import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vivafit_personal_app/models/user_profile.dart';

class UserProfileService {
  final CollectionReference _userProfilesCollection = FirebaseFirestore.instance.collection('userProfiles');

  Future<void> createUserProfile(UserProfile userProfile) async {
    await _userProfilesCollection.doc(userProfile.id).set(userProfile.toMap());
  }

  Future<void> saveUserProfile(UserProfile userProfile) async {
    await _userProfilesCollection.doc(userProfile.id).set(userProfile.toMap());
  }

  Future<void> deleteUserProfile(String id) async {
    await _userProfilesCollection.doc(id).delete();
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    await _userProfilesCollection.doc(userProfile.id).update(userProfile.toMap());
  }

  Future<void> activateUserProfile(String id) async {
    await _userProfilesCollection.doc(id).update({'isActive': true});
  }

  Future<void> deactivateUserProfile(String id) async {
    await _userProfilesCollection.doc(id).update({'isActive': false});
  }

  Future<List<UserProfile>> searchUserProfiles({required String personalTrainerId, String? name, String? email, String? phone}) async {
    Query query = _userProfilesCollection.where('personalTrainerId', isEqualTo: personalTrainerId);
    if (name != null) {
      query = query.where('name', isEqualTo: name);
    } else if (email != null) {
      query = query.where('email', isEqualTo: email);
    } else if (phone != null) {
      query = query.where('phone', isEqualTo: phone);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<UserProfile> userProfiles = querySnapshot.docs.map((doc) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return userProfiles;
  }
  
  Future<void> updateUserProfileGoal(String userProfileId, String goal) async {
    await _userProfilesCollection.doc(userProfileId).update({'goal': goal});
  }

  Future<void> updateUserProfileImage(String userProfileId, String imageUrl) async {
    await _userProfilesCollection.doc(userProfileId).update({'imageUrl': imageUrl});
  }

  Future<void> updateUserProfilePersonalTrainer(String userProfileId, String personalTrainerId) async {
    await _userProfilesCollection.doc(userProfileId).update({'personalTrainerId': personalTrainerId});
  }

  Future<UserProfile?> getUserProfileById(String id) async {
    DocumentSnapshot doc = await _userProfilesCollection.doc(id).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
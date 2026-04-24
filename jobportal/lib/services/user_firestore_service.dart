import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFirestoreService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  Future<void> createUser({
    required User firebaseUser,
    required String name,
    required String role,
  }) async {
    await _usersRef.doc(firebaseUser.uid).set({
      'name': name,
      'email': firebaseUser.email,
      'role': role, // seeker | employer
      'verified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool verified;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.verified,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'seeker',
      verified: data['verified'] ?? false,
    );
  }
}

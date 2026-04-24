import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../seeker/seeker_dashboard.dart';
import '../employer/employer_dashboard.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Logged in → fetch role
        final user = snapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data =
            roleSnapshot.data!.data() as Map<String, dynamic>?;

            if (data == null) {
              return const LoginScreen();
            }

            final role = data['role'];

            // ✅ IMPORTANT: Return widget, DO NOT navigate here
            if (role == 'seeker') {
              return const SeekerDashboard();
            } else if (role == 'employer') {
              return const EmployerDashboard();
            } else {
              return const Scaffold(
                body: Center(child: Text('Access Denied')),
              );
            }
          },
        );
      },
    );
  }
}

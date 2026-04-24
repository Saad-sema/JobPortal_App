import 'package:flutter/material.dart';
import 'core/firebase_init.dart';
import 'features/auth/admin_login_screen.dart';

void main() async {
  await FirebaseInit.init();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HireHub Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const AdminLoginScreen(),
    );
  }
}

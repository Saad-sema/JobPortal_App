import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() =>
      _AdminRegisterScreenState();
}

class _AdminRegisterScreenState
    extends State<AdminRegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _secretKey = TextEditingController();

  bool _loading = false;

  static const String ADMIN_SECRET_KEY = "ADMIN@2025";

  // ---------------- REGISTER ADMIN ----------------
  Future<void> _registerAdmin() async {
    if (_name.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty ||
        _secretKey.text.isEmpty) {
      _show('All fields required');
      return;
    }

    if (_secretKey.text.trim() != ADMIN_SECRET_KEY) {
      _show('Invalid Admin Secret Key');
      return;
    }

    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final uid = cred.user!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'role': 'admin',
        'verified': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin registered successfully'),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = 'Registration failed';

      if (e.code == 'email-already-in-use') {
        msg = 'Email already registered';
      } else if (e.code == 'weak-password') {
        msg = 'Password too weak';
      }

      _show(msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF020617),
              Color(0xFF020617),
              Color(0xFF020617),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _glassRegisterCard(),
            ),
          ),
        ),
      ),
    );
  }

  // ================= GLASS REGISTER CARD =================
  Widget _glassRegisterCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              const Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.greenAccent,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Admin Registration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              const Text(
                'Create a secure admin account',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              _field(
                controller: _name,
                label: 'Full Name',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 14),

              _field(
                controller: _email,
                label: 'Email Address',
                icon: Icons.email_rounded,
              ),
              const SizedBox(height: 14),

              _field(
                controller: _password,
                label: 'Password',
                icon: Icons.lock_rounded,
                obscure: true,
              ),
              const SizedBox(height: 14),

              _field(
                controller: _secretKey,
                label: 'Admin Secret Key',
                icon: Icons.key_rounded,
                obscure: true,
                highlight: true,
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _registerAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                      : const Text(
                    'Create Admin Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TEXT FIELD =================
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool highlight = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color:
          highlight ? Colors.redAccent : Colors.white54,
        ),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: highlight
                ? Colors.redAccent.withOpacity(0.4)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: highlight
                ? Colors.redAccent
                : Colors.greenAccent,
          ),
        ),
      ),
    );
  }
}

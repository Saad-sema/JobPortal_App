import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // common
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();

  // employer only (backend unchanged)
  final _companyName = TextEditingController();
  final _companyDesc = TextEditingController();
  final _designation = TextEditingController();
  final _experience = TextEditingController();
  final _website = TextEditingController();

  String _role = 'seeker'; // backend role
  bool _loading = false;
  bool _obscure = true;

  /// ---------------- REGISTER (UNCHANGED) ----------------
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final uid = cred.user!.uid;

      final data = {
        'role': _role, // seeker / employer (same)
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'profilePhotoBase64': '',
        'verified': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_role == 'employer') {
        data.addAll({
          'companyName': _companyName.text.trim(),
          'companyDescription': _companyDesc.text.trim(),
          'designation': _designation.text.trim(),
          'experience': int.tryParse(_experience.text) ?? 0,
          'website': _website.text.trim(),
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF141E30),
              Color(0xFF243B55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// TITLE
                        const Text(
                          'Create Account 🚀',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Start your career journey with us',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 28),

                        _field(_name, 'Full Name', Icons.person_outline),
                        _field(_email, 'Email Address', Icons.email_outlined),
                        _field(_password, 'Password', Icons.lock_outline,
                            obscure: true),
                        _field(_phone, 'Phone Number', Icons.phone_outlined),

                        const SizedBox(height: 12),

                        /// ROLE (UI text changed)
                        DropdownButtonFormField<String>(
                          value: _role,
                          dropdownColor: const Color(0xFF243B55),
                          decoration: _dropdownDecoration(),
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(
                              value: 'seeker',
                              child: Text('Candidate'),
                            ),
                            DropdownMenuItem(
                              value: 'employer',
                              child: Text('Company'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _role = v!),
                        ),

                        /// COMPANY EXTRA (same condition)
                        if (_role == 'employer') ...[
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 10),

                          const Text(
                            'Company Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          _field(
                            _companyName,
                            'Company Name',
                            Icons.business_outlined,
                          ),
                          _field(
                            _companyDesc,
                            'Company Description',
                            Icons.description_outlined,
                          ),
                          _field(
                            _designation,
                            'Your Designation',
                            Icons.badge_outlined,
                          ),
                          _field(
                            _experience,
                            'Experience (years)',
                            Icons.timeline_outlined,
                            keyboard: TextInputType.number,
                          ),
                          _field(
                            _website,
                            'Website',
                            Icons.language_outlined,
                          ),
                        ],

                        const SizedBox(height: 28),

                        /// REGISTER BUTTON
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00F260),
                                    Color(0xFF0575E6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: _loading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Already have an account? Login',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- INPUT FIELD ----------------
  Widget _field(
      TextEditingController c,
      String label,
      IconData icon, {
        bool obscure = false,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        validator: (v) =>
        v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      labelText: 'Select Role',
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

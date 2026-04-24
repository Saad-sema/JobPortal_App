import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../chat/chat_screen.dart';

class UserPublicProfileScreen extends StatelessWidget {
  final String userId;

  const UserPublicProfileScreen({
    super.key,
    required this.userId,
  });

  /// 🔹 UI ROLE LABEL ONLY (backend unchanged)
  String _roleLabel(String role) {
    if (role == 'seeker') return 'Candidate';
    if (role == 'employer') return 'Company';
    return role;
  }

  /// ---------------- START CHAT ----------------
  Future<void> _startChat(
      BuildContext context,
      String otherUserId,
      ) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatRef = FirebaseFirestore.instance.collection('chats');

    final existing =
    await chatRef.where('participants', arrayContains: currentUserId).get();

    String? chatId;

    for (var doc in existing.docs) {
      if ((doc['participants'] as List).contains(otherUserId)) {
        chatId = doc.id;
        break;
      }
    }

    if (chatId == null) {
      final newChat = await chatRef.add({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      chatId = newChat.id;
    }

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId!,
          otherUserId: otherUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E1A),
              Color(0xFF1A1F38),
            ],
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future:
          FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final photoBase64 = data['profilePhotoBase64'];
            final role = data['role'];

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                /// ---------------- AVATAR ----------------
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      backgroundImage: photoBase64 != null &&
                          photoBase64.toString().isNotEmpty
                          ? MemoryImage(base64Decode(photoBase64))
                          : null,
                      child: photoBase64 == null
                          ? Text(
                        (data['name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 34,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// ---------------- NAME ----------------
                Center(
                  child: Text(
                    data['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                if (data['companyName'] != null)
                  Center(
                    child: Text(
                      data['companyName'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                _sectionTitle('Basic Info'),
                _glassInfoRow('Email', data['email']),
                _glassInfoRow('Phone', data['phone']),
                _glassInfoRow('Role', _roleLabel(role)),

                /// ---------------- SEEKER (Candidate) ----------------
                if (role == 'seeker') ...[
                  const SizedBox(height: 20),
                  _sectionTitle('Education'),
                  _glassInfoRow('Education', data['education']),
                  _glassInfoRow(
                    'CGPA',
                    data['cgpa'] != null ? data['cgpa'].toString() : '',
                  ),

                  const SizedBox(height: 16),
                  _sectionTitle('Skills'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (data['skills'] as List<dynamic>?)
                        ?.map(
                          (e) => Chip(
                        label: Text(e),
                        backgroundColor:
                        Colors.white.withOpacity(0.08),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                      ),
                    )
                        .toList() ??
                        [
                          Text(
                            'No skills',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          )
                        ],
                  ),
                ],

                /// ---------------- EMPLOYER (Company) ----------------
                if (role == 'employer') ...[
                  const SizedBox(height: 20),
                  _sectionTitle('Company Details'),
                  _glassInfoRow('Company', data['companyName']),
                  _glassInfoRow(
                    'Experience',
                    data['experience'] != null
                        ? data['experience'].toString()
                        : '',
                  ),
                ],

                const SizedBox(height: 32),

                /// ---------------- CHAT BUTTON ----------------
                if (currentUserId != null && currentUserId != userId)
                  ElevatedButton.icon(
                    onPressed: () => _startChat(context, userId),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Start Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ---------------- HELPERS ----------------
  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.85),
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _glassInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

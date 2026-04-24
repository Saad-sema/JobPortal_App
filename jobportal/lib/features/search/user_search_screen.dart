import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../chat/chat_screen.dart';
import '../profile/user_public_profile_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  /// 🔹 UI ROLE LABEL ONLY (backend unchanged)
  String _roleLabel(String role) {
    if (role == 'seeker') return 'Candidate';
    if (role == 'employer') return 'Company';
    return role;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A0E1A),
                Color(0xFF0A0E1A),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
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
          'Search Users',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
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
        child: Column(
          children: [
            /// SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: Colors.white.withOpacity(0.7),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search users by name...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 18),
                                ),
                                onChanged: (v) =>
                                    setState(() => _query = v),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 20,
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

            /// USER LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  if (!snapshot.hasData) {
                    return _buildEmptyState('No data available');
                  }

                  final users = snapshot.data!.docs
                      .where((doc) => doc.id != currentUserId)
                      .where((doc) => (doc['name'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(_query.toLowerCase()))
                      .toList();

                  if (users.isEmpty) {
                    return _buildEmptyState(
                      _query.isEmpty
                          ? 'No users found'
                          : 'No matching users',
                    );
                  }

                  return ListView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final doc = users[index];
                      final user =
                      doc.data() as Map<String, dynamic>;
                      final photoBase64 =
                      user['profilePhotoBase64'];

                      return _buildUserCard(
                        doc.id,
                        user,
                        photoBase64,
                        currentUserId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================== USER CARD ==================
  Widget _buildUserCard(
      String userId,
      Map<String, dynamic> user,
      String? photoBase64,
      String currentUserId,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    UserPublicProfileScreen(userId: userId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                /// AVATAR
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E293B),
                        Color(0xFF334155),
                      ],
                    ),
                  ),
                  child: photoBase64 != null && photoBase64.isNotEmpty
                      ? ClipOval(
                    child: Image.memory(
                      base64Decode(photoBase64),
                      fit: BoxFit.cover,
                    ),
                  )
                      : Center(
                    child: Text(
                      user['name'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                /// INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _roleLabel(user['role'] ?? 'User'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                /// CHAT
                IconButton(
                  onPressed: () =>
                      _startChat(userId, currentUserId),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================== START CHAT ==================
  Future<void> _startChat(
      String otherUserId, String currentUserId) async {
    final chatRef =
    FirebaseFirestore.instance.collection('chats');
    final existing = await chatRef
        .where('participants', arrayContains: currentUserId)
        .get();

    String? chatId;

    for (var c in existing.docs) {
      if ((c['participants'] as List).contains(otherUserId)) {
        chatId = c.id;
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

  /// ================== LOADING STATE ==================
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// ================== EMPTY STATE ==================
  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}

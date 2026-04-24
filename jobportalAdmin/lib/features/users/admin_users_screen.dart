import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  // ---------------- UPDATE VERIFIED ----------------
  Future<void> _toggleVerified(
      BuildContext context, String uid, bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'verified': value});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'User verified' : 'User unverified'),
        ),
      );
    } catch (e) {
      _error(context, e);
    }
  }

  // ---------------- CHANGE ROLE ----------------
  Future<void> _changeRole(
      BuildContext context, String uid, String role) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'role': role});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Role changed to ${_roleLabel(role)}',
          ),
        ),
      );
    } catch (e) {
      _error(context, e);
    }
  }

  // ---------------- DELETE USER ----------------
  Future<void> _deleteUser(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted')),
      );
    } catch (e) {
      _error(context, e);
    }
  }

  // ---------------- SHOW REVOKE CONFIRMATION ----------------
  Future<void> _showRevokeConfirmation(
      BuildContext context, String uid, String name) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
        ),
        title: const Text(
          'Revoke Verification?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to revoke verification for $name? They will no longer be able to post jobs until re-verified.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleVerified(context, uid, false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Revoke',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _error(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// 🔹 UI role label only
  String _roleLabel(String role) {
    if (role == 'seeker') return 'Candidate';
    if (role == 'employer') return 'Company';
    return role;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _userCard(context, doc.id, data);
          }).toList(),
        );
      },
    );
  }

  // ================= USER CARD =================
  Widget _userCard(
      BuildContext context, String uid, Map<String, dynamic> data) {
    final role = data['role'] ?? 'seeker';
    final verified = data['verified'] ?? false;

    // 🟡 Highlight unverified employers so admin spots them immediately.
    final bool needsAttention = role == 'employer' && !verified;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: needsAttention
                  ? Colors.amber.withOpacity(0.06)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: needsAttention
                    ? Colors.amber.withOpacity(0.55)
                    : Colors.white.withOpacity(0.12),
                width: needsAttention ? 1.8 : 1.0,
              ),
              boxShadow: needsAttention
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.15),
                        blurRadius: 18,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── name + optional warning chip ──
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (needsAttention)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.amber.withOpacity(0.55)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.amber, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'NEEDS VERIFICATION',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['email'] ?? '',
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  children: [
                    _badge(
                      _roleLabel(role).toUpperCase(),
                      Colors.blueAccent,
                    ),
                    _badge(
                      verified ? 'VERIFIED' : 'UNVERIFIED',
                      verified
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    if (role == 'employer')
                      Expanded(
                        child: _actionBtn(
                          title: verified ? 'Revoke Access' : 'Verify',
                          color: verified
                              ? Colors.orangeAccent
                              : Colors.greenAccent,
                          onTap: () {
                            if (verified) {
                              _showRevokeConfirmation(
                                  context, uid, data['name'] ?? 'User');
                            } else {
                              _toggleVerified(context, uid, true);
                            }
                          },
                        ),
                      ),
                    if (role == 'employer') const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        title: role == 'seeker'
                            ? 'Make Company'
                            : 'Make Candidate',
                        color: Colors.blueAccent,
                        onTap: () => _changeRole(
                          context,
                          uid,
                          role == 'seeker'
                              ? 'employer'
                              : 'seeker',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        title: 'Delete',
                        color: Colors.redAccent,
                        onTap: () => _deleteUser(context, uid),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionBtn({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

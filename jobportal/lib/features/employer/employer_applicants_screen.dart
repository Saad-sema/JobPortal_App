import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../profile/user_public_profile_screen.dart';

class EmployerApplicantsScreen extends StatelessWidget {
  final String jobId;

  const EmployerApplicantsScreen({
    super.key,
    required this.jobId,
  });

  /// ---------------- OPEN RESUME IN BROWSER ----------------
  Future<void> _openResume(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  /// ---------------- UPDATE APPLICATION STATUS ----------------
  Future<void> _updateStatus(
      BuildContext context,
      String docId,
      String status,
      ) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(docId)
        .update({'status': status});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $status')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        title: Text(
          'Applicants',
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('applications')
              .where('jobId', isEqualTo: jobId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final photoBase64 = data['profilePhotoBase64'];
                final status = data['status'] ?? 'applied';

                return _buildApplicantCard(
                  context: context,
                  docId: doc.id,
                  data: data,
                  photoBase64: photoBase64,
                  status: status,
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// ================== APPLICANT CARD ==================
  Widget _buildApplicantCard({
    required BuildContext context,
    required String docId,
    required Map<String, dynamic> data,
    required String? photoBase64,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserPublicProfileScreen(
                  userId: data['userId'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// APPLICANT INFO
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PROFILE AVATAR
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
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: photoBase64 != null && photoBase64.isNotEmpty
                          ? ClipOval(
                        child: Image.memory(
                          base64Decode(photoBase64),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Center(
                        child: Text(
                          (data['name'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// APPLICANT DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Education
                          Row(
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 13,
                                color: Colors.white.withOpacity(0.45),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  (data['education'] as String?)
                                              ?.trim()
                                              .isNotEmpty ==
                                          true
                                      ? data['education']
                                      : 'No education info',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // CGPA
                          Row(
                            children: [
                              Icon(
                                Icons.grade_rounded,
                                size: 13,
                                color: Colors.white.withOpacity(0.45),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                data['cgpa'] != null &&
                                        data['cgpa'].toString() != '0'
                                    ? 'CGPA: ${data['cgpa']}'
                                    : 'CGPA: Not provided',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          /// STATUS BADGE
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _getStatusColor(status).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: 14,
                                  color: _getStatusColor(status),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// ACTION MENU
                    PopupMenuButton<String>(
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
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'resume') {
                          _openResume(data['resumeUrl'] ?? '');
                        } else {
                          _updateStatus(context, docId, value);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'resume',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.description_rounded,
                                size: 18,
                                color: Color(0xFF60A5FA),
                              ),
                              const SizedBox(width: 12),
                              const Text('View Resume'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'shortlisted',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.checklist_rounded,
                                size: 18,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 12),
                              const Text('Shortlist'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'selected',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 12),
                              const Text('Select'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'rejected',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Reject',
                                style: TextStyle(color: Color(0xFFEF4444)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// APPLICANT SKILLS (if available)
                if (data['skills'] != null && (data['skills'] as List).isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skills:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (data['skills'] as List).take(4).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF2563EB).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              skill.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF60A5FA),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
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

  /// ================== STATUS HELPERS ==================
  Color _getStatusColor(String status) {
    switch (status) {
      case 'shortlisted':
        return const Color(0xFFF59E0B);
      case 'selected':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF60A5FA);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'shortlisted':
        return Icons.checklist_rounded;
      case 'selected':
        return Icons.star_rounded;
      case 'rejected':
        return Icons.close_rounded;
      default:
        return Icons.pending_rounded;
    }
  }

  /// ================== LOADING STATE ==================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(const Color(0xFF10B981)),
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Applicants...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// ================== EMPTY STATE ==================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 50,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Applicants Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Candidates will appear here once they apply to your job posting.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
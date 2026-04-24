import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminJobsScreen extends StatelessWidget {
  const AdminJobsScreen({super.key});

  // ---------------- UPDATE JOB STATUS ----------------
  Future<void> _updateStatus(
      BuildContext context,
      String jobId,
      String status,
      ) async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .update({'status': status});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Job marked as $status')),
    );
  }

  // ---------------- DELETE JOB ----------------
  Future<void> _deleteJob(
      BuildContext context,
      String jobId,
      ) async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No jobs posted',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'open';

            // 🔢 Count applications from the `applications` collection
            // (they are stored as separate docs with a `jobId` field,
            //  NOT as an embedded array on the job document).
            return FutureBuilder<AggregateQuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('applications')
                  .where('jobId', isEqualTo: doc.id)
                  .count()
                  .get(),
              builder: (context, countSnap) {
                final applicationCount =
                    countSnap.data?.count ?? 0;

                return _heavyJobCard(
                  context,
                  doc.id,
                  data,
                  status,
                  applicationCount,
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  // ================= HEAVY JOB CARD =================
  Widget _heavyJobCard(
      BuildContext context,
      String jobId,
      Map<String, dynamic> data,
      String status,
      int applications,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- HEADER ----------------
                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.work_rounded,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['companyName'] ?? '',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ---------------- BADGES ----------------
                Wrap(
                  spacing: 8,
                  children: [
                    _badge(
                      status.toUpperCase(),
                      status == 'open'
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                    _badge(
                      '$applications Applications',
                      Colors.purpleAccent,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---------------- ACTION BUTTONS ----------------
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        title: 'Open',
                        color: Colors.greenAccent,
                        active: status == 'open',
                        onTap: () => _updateStatus(
                          context,
                          jobId,
                          'open',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        title: 'Close',
                        color: Colors.orangeAccent,
                        active: status == 'closed',
                        onTap: () => _updateStatus(
                          context,
                          jobId,
                          'closed',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        title: 'Delete',
                        color: Colors.redAccent,
                        onTap: () =>
                            _deleteJob(context, jobId),
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

  // ================= BADGE =================
  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.4),
        ),
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

  // ================= ACTION BUTTON =================
  Widget _actionButton({
    required String title,
    required Color color,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? color.withOpacity(0.25)
              : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.45),
          ),
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

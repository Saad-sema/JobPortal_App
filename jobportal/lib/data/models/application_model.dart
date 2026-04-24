import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final String seekerId;
  final String employerId;
  final String resumeUrl;
  final String status;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.seekerId,
    required this.employerId,
    required this.resumeUrl,
    required this.status,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ApplicationModel(
      id: doc.id,
      jobId: data['jobId'],
      seekerId: data['seekerId'],
      employerId: data['employerId'],
      resumeUrl: data['resumeUrl'],
      status: data['status'],
    );
  }
}

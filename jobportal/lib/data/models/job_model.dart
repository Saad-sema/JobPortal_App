import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String description;
  final String companyName;
  final String employerId;
  final String location;
  final String jobType;
  final List<String> requiredSkills;
  final List<String> eligibleBranches;
  final double minCgpa;
  final String status;
  final Timestamp deadline;
  final Timestamp? createdAt;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    required this.employerId,
    required this.location,
    required this.jobType,
    required this.requiredSkills,
    required this.eligibleBranches,
    required this.minCgpa,
    required this.status,
    required this.deadline,
    this.createdAt,
  });

  /// FROM FIRESTORE
  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JobModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      companyName: data['companyName'] ?? '',
      employerId: data['employerId'] ?? '',
      location: data['location'] ?? '',
      jobType: data['jobType'] ?? '',
      requiredSkills:
      List<String>.from(data['requiredSkills'] ?? []),
      eligibleBranches:
      List<String>.from(data['eligibleBranches'] ?? []),
      minCgpa: (data['minCgpa'] ?? 0).toDouble(),
      status: data['status'] ?? 'open',
      deadline: data['deadline'] ?? Timestamp.now(),
      createdAt: data['createdAt'],
    );
  }

  /// TO FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'companyName': companyName,
      'employerId': employerId,
      'location': location,
      'jobType': jobType,
      'requiredSkills': requiredSkills,
      'eligibleBranches': eligibleBranches,
      'minCgpa': minCgpa,
      'status': status,
      'deadline': deadline,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

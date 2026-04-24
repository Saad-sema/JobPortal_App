import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationRepository {
  final CollectionReference _ref =
  FirebaseFirestore.instance.collection('applications');

  /// ---------------------------
  /// Seeker: Apply for Job
  /// ---------------------------
  Future<void> applyJob({
    required String jobId,
    required String seekerId,
    required String employerId,
    required String resumeUrl,
  }) async {
    await _ref.add({
      'jobId': jobId,
      'seekerId': seekerId,
      'employerId': employerId,
      'resumeUrl': resumeUrl,
      'status': 'applied',
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ---------------------------
  /// Employer: Get Applicants
  /// ---------------------------
  Stream<List<ApplicationModel>> getApplicationsForJob(
      String jobId) {
    return _ref
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) =>
            ApplicationModel.fromFirestore(doc),
      )
          .toList(),
    );
  }

  /// ---------------------------
  /// Employer: Update Status
  /// ---------------------------
  Future<void> updateStatus(
      String applicationId,
      String status,
      ) async {
    await _ref.doc(applicationId).update({
      'status': status,
    });
  }

  /// ---------------------------
  /// Seeker: My Applications (NEXT STEP)
  /// ---------------------------
  Stream<List<ApplicationModel>> getApplicationsForSeeker(
      String seekerId) {
    return _ref
        .where('seekerId', isEqualTo: seekerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) =>
            ApplicationModel.fromFirestore(doc),
      )
          .toList(),
    );
  }
}

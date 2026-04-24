import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> createJob(JobModel job) async {
    await _firestore.collection('jobs').add(job.toMap());
  }
}

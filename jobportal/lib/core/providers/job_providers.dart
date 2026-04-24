import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/job_repository.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

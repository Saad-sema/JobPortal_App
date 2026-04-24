import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/application_repository.dart';

final applicationRepoProvider =
Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

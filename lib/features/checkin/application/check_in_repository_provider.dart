import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../data/drift_check_in_repository.dart';
import '../domain/check_in_repository.dart';
final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftCheckInRepository(db.checkInsDao);
});

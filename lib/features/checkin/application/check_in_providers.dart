import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_checkin.dart';
import 'check_in_repository_provider.dart';
final todayCheckInProvider = FutureProvider<UserCheckin?>((ref) {
  return ref.watch(checkInRepositoryProvider).getByDate(DateTime.now());
});

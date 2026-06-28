import 'user_checkin.dart';
abstract class CheckInRepository {
  Future<List<UserCheckin>> getAll();
  Stream<List<UserCheckin>> watchAll();
  Future<UserCheckin?> getByDate(DateTime date);
  Future<List<UserCheckin>> getRecent(int limit);
  Future<void> save(UserCheckin checkin);
}

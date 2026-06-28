import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../checkin/data/drift_user_checkin_mapper.dart';
import '../../../checkin/domain/user_checkin.dart' as domain;
import '../../../../core/database/app_database.dart' as app_db;
import '../../../../core/providers/database_provider.dart';
final checkinsProvider = StreamProvider<List<domain.UserCheckin>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.userCheckinsDao.watchAllCheckins().map(
        (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
      );
});

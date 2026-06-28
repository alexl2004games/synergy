import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_checkin.freezed.dart';
@freezed
abstract class UserCheckin with _$UserCheckin {
  const factory UserCheckin({
    required String id,
    required DateTime date,
    required int moodScore,
    required int productivity,
    required int energy,
    required DateTime createdAt,
    @Default('') String note,
  }) = _UserCheckin;
}

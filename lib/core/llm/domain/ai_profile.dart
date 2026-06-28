import 'package:freezed_annotation/freezed_annotation.dart';
part 'ai_profile.freezed.dart';
@freezed
abstract class AIProfile with _$AIProfile {
  const factory AIProfile({
    @Default(1.0) double correctionFactor,
    @Default(0.0) double avgMoodScore,
    @Default(9) int peakHoursStart,
    @Default(12) int peakHoursEnd,
    @Default(0) int totalCheckins,
    DateTime? updatedAt,
  }) = _AIProfile;
}

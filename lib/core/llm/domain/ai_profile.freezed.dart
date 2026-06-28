// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
part of 'ai_profile.dart';
T _$identity<T>(T value) => value;
mixin _$AIProfile {
  double get correctionFactor;
  double get avgMoodScore;
  int get peakHoursStart;
  int get peakHoursEnd;
  int get totalCheckins;
  DateTime? get updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIProfileCopyWith<AIProfile> get copyWith =>
      _$AIProfileCopyWithImpl<AIProfile>(this as AIProfile, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIProfile &&
            (identical(other.correctionFactor, correctionFactor) ||
                other.correctionFactor == correctionFactor) &&
            (identical(other.avgMoodScore, avgMoodScore) ||
                other.avgMoodScore == avgMoodScore) &&
            (identical(other.peakHoursStart, peakHoursStart) ||
                other.peakHoursStart == peakHoursStart) &&
            (identical(other.peakHoursEnd, peakHoursEnd) ||
                other.peakHoursEnd == peakHoursEnd) &&
            (identical(other.totalCheckins, totalCheckins) ||
                other.totalCheckins == totalCheckins) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }
  @override
  int get hashCode => Object.hash(runtimeType, correctionFactor, avgMoodScore,
      peakHoursStart, peakHoursEnd, totalCheckins, updatedAt);
  @override
  String toString() {
    return 'AIProfile(correctionFactor: $correctionFactor, avgMoodScore: $avgMoodScore, peakHoursStart: $peakHoursStart, peakHoursEnd: $peakHoursEnd, totalCheckins: $totalCheckins, updatedAt: $updatedAt)';
  }
}
abstract mixin class $AIProfileCopyWith<$Res> {
  factory $AIProfileCopyWith(AIProfile value, $Res Function(AIProfile) _then) =
      _$AIProfileCopyWithImpl;
  @useResult
  $Res call(
      {double correctionFactor,
      double avgMoodScore,
      int peakHoursStart,
      int peakHoursEnd,
      int totalCheckins,
      DateTime? updatedAt});
}
class _$AIProfileCopyWithImpl<$Res> implements $AIProfileCopyWith<$Res> {
  _$AIProfileCopyWithImpl(this._self, this._then);
  final AIProfile _self;
  final $Res Function(AIProfile) _then;
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correctionFactor = null,
    Object? avgMoodScore = null,
    Object? peakHoursStart = null,
    Object? peakHoursEnd = null,
    Object? totalCheckins = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      correctionFactor: null == correctionFactor
          ? _self.correctionFactor
          : correctionFactor // ignore: cast_nullable_to_non_nullable
              as double,
      avgMoodScore: null == avgMoodScore
          ? _self.avgMoodScore
          : avgMoodScore // ignore: cast_nullable_to_non_nullable
              as double,
      peakHoursStart: null == peakHoursStart
          ? _self.peakHoursStart
          : peakHoursStart // ignore: cast_nullable_to_non_nullable
              as int,
      peakHoursEnd: null == peakHoursEnd
          ? _self.peakHoursEnd
          : peakHoursEnd // ignore: cast_nullable_to_non_nullable
              as int,
      totalCheckins: null == totalCheckins
          ? _self.totalCheckins
          : totalCheckins // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}
extension AIProfilePatterns on AIProfile {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AIProfile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIProfile() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AIProfile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIProfile():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AIProfile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIProfile() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            double correctionFactor,
            double avgMoodScore,
            int peakHoursStart,
            int peakHoursEnd,
            int totalCheckins,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIProfile() when $default != null:
        return $default(
            _that.correctionFactor,
            _that.avgMoodScore,
            _that.peakHoursStart,
            _that.peakHoursEnd,
            _that.totalCheckins,
            _that.updatedAt);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            double correctionFactor,
            double avgMoodScore,
            int peakHoursStart,
            int peakHoursEnd,
            int totalCheckins,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIProfile():
        return $default(
            _that.correctionFactor,
            _that.avgMoodScore,
            _that.peakHoursStart,
            _that.peakHoursEnd,
            _that.totalCheckins,
            _that.updatedAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            double correctionFactor,
            double avgMoodScore,
            int peakHoursStart,
            int peakHoursEnd,
            int totalCheckins,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIProfile() when $default != null:
        return $default(
            _that.correctionFactor,
            _that.avgMoodScore,
            _that.peakHoursStart,
            _that.peakHoursEnd,
            _that.totalCheckins,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}
class _AIProfile implements AIProfile {
  const _AIProfile(
      {this.correctionFactor = 1.0,
      this.avgMoodScore = 0.0,
      this.peakHoursStart = 9,
      this.peakHoursEnd = 12,
      this.totalCheckins = 0,
      this.updatedAt});
  @override
  @JsonKey()
  final double correctionFactor;
  @override
  @JsonKey()
  final double avgMoodScore;
  @override
  @JsonKey()
  final int peakHoursStart;
  @override
  @JsonKey()
  final int peakHoursEnd;
  @override
  @JsonKey()
  final int totalCheckins;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIProfileCopyWith<_AIProfile> get copyWith =>
      __$AIProfileCopyWithImpl<_AIProfile>(this, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIProfile &&
            (identical(other.correctionFactor, correctionFactor) ||
                other.correctionFactor == correctionFactor) &&
            (identical(other.avgMoodScore, avgMoodScore) ||
                other.avgMoodScore == avgMoodScore) &&
            (identical(other.peakHoursStart, peakHoursStart) ||
                other.peakHoursStart == peakHoursStart) &&
            (identical(other.peakHoursEnd, peakHoursEnd) ||
                other.peakHoursEnd == peakHoursEnd) &&
            (identical(other.totalCheckins, totalCheckins) ||
                other.totalCheckins == totalCheckins) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }
  @override
  int get hashCode => Object.hash(runtimeType, correctionFactor, avgMoodScore,
      peakHoursStart, peakHoursEnd, totalCheckins, updatedAt);
  @override
  String toString() {
    return 'AIProfile(correctionFactor: $correctionFactor, avgMoodScore: $avgMoodScore, peakHoursStart: $peakHoursStart, peakHoursEnd: $peakHoursEnd, totalCheckins: $totalCheckins, updatedAt: $updatedAt)';
  }
}
abstract mixin class _$AIProfileCopyWith<$Res>
    implements $AIProfileCopyWith<$Res> {
  factory _$AIProfileCopyWith(
          _AIProfile value, $Res Function(_AIProfile) _then) =
      __$AIProfileCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double correctionFactor,
      double avgMoodScore,
      int peakHoursStart,
      int peakHoursEnd,
      int totalCheckins,
      DateTime? updatedAt});
}
class __$AIProfileCopyWithImpl<$Res> implements _$AIProfileCopyWith<$Res> {
  __$AIProfileCopyWithImpl(this._self, this._then);
  final _AIProfile _self;
  final $Res Function(_AIProfile) _then;
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? correctionFactor = null,
    Object? avgMoodScore = null,
    Object? peakHoursStart = null,
    Object? peakHoursEnd = null,
    Object? totalCheckins = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_AIProfile(
      correctionFactor: null == correctionFactor
          ? _self.correctionFactor
          : correctionFactor // ignore: cast_nullable_to_non_nullable
              as double,
      avgMoodScore: null == avgMoodScore
          ? _self.avgMoodScore
          : avgMoodScore // ignore: cast_nullable_to_non_nullable
              as double,
      peakHoursStart: null == peakHoursStart
          ? _self.peakHoursStart
          : peakHoursStart // ignore: cast_nullable_to_non_nullable
              as int,
      peakHoursEnd: null == peakHoursEnd
          ? _self.peakHoursEnd
          : peakHoursEnd // ignore: cast_nullable_to_non_nullable
              as int,
      totalCheckins: null == totalCheckins
          ? _self.totalCheckins
          : totalCheckins // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

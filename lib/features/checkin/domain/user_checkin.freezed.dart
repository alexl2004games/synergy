// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
part of 'user_checkin.dart';
T _$identity<T>(T value) => value;
mixin _$UserCheckin {
  String get id;
  DateTime get date;
  int get moodScore;
  int get productivity;
  int get energy;
  DateTime get createdAt;
  String get note;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserCheckinCopyWith<UserCheckin> get copyWith =>
      _$UserCheckinCopyWithImpl<UserCheckin>(this as UserCheckin, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserCheckin &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.moodScore, moodScore) ||
                other.moodScore == moodScore) &&
            (identical(other.productivity, productivity) ||
                other.productivity == productivity) &&
            (identical(other.energy, energy) || other.energy == energy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.note, note) || other.note == note));
  }
  @override
  int get hashCode => Object.hash(
      runtimeType, id, date, moodScore, productivity, energy, createdAt, note);
  @override
  String toString() {
    return 'UserCheckin(id: $id, date: $date, moodScore: $moodScore, productivity: $productivity, energy: $energy, createdAt: $createdAt, note: $note)';
  }
}
abstract mixin class $UserCheckinCopyWith<$Res> {
  factory $UserCheckinCopyWith(
          UserCheckin value, $Res Function(UserCheckin) _then) =
      _$UserCheckinCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      int moodScore,
      int productivity,
      int energy,
      DateTime createdAt,
      String note});
}
class _$UserCheckinCopyWithImpl<$Res> implements $UserCheckinCopyWith<$Res> {
  _$UserCheckinCopyWithImpl(this._self, this._then);
  final UserCheckin _self;
  final $Res Function(UserCheckin) _then;
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? moodScore = null,
    Object? productivity = null,
    Object? energy = null,
    Object? createdAt = null,
    Object? note = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      moodScore: null == moodScore
          ? _self.moodScore
          : moodScore // ignore: cast_nullable_to_non_nullable
              as int,
      productivity: null == productivity
          ? _self.productivity
          : productivity // ignore: cast_nullable_to_non_nullable
              as int,
      energy: null == energy
          ? _self.energy
          : energy // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: null == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}
extension UserCheckinPatterns on UserCheckin {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_UserCheckin value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserCheckin() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_UserCheckin value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserCheckin():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_UserCheckin value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserCheckin() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, DateTime date, int moodScore, int productivity,
            int energy, DateTime createdAt, String note)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserCheckin() when $default != null:
        return $default(_that.id, _that.date, _that.moodScore,
            _that.productivity, _that.energy, _that.createdAt, _that.note);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, DateTime date, int moodScore, int productivity,
            int energy, DateTime createdAt, String note)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserCheckin():
        return $default(_that.id, _that.date, _that.moodScore,
            _that.productivity, _that.energy, _that.createdAt, _that.note);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, DateTime date, int moodScore, int productivity,
            int energy, DateTime createdAt, String note)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserCheckin() when $default != null:
        return $default(_that.id, _that.date, _that.moodScore,
            _that.productivity, _that.energy, _that.createdAt, _that.note);
      case _:
        return null;
    }
  }
}
class _UserCheckin implements UserCheckin {
  const _UserCheckin(
      {required this.id,
      required this.date,
      required this.moodScore,
      required this.productivity,
      required this.energy,
      required this.createdAt,
      this.note = ''});
  @override
  final String id;
  @override
  final DateTime date;
  @override
  final int moodScore;
  @override
  final int productivity;
  @override
  final int energy;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserCheckinCopyWith<_UserCheckin> get copyWith =>
      __$UserCheckinCopyWithImpl<_UserCheckin>(this, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserCheckin &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.moodScore, moodScore) ||
                other.moodScore == moodScore) &&
            (identical(other.productivity, productivity) ||
                other.productivity == productivity) &&
            (identical(other.energy, energy) || other.energy == energy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.note, note) || other.note == note));
  }
  @override
  int get hashCode => Object.hash(
      runtimeType, id, date, moodScore, productivity, energy, createdAt, note);
  @override
  String toString() {
    return 'UserCheckin(id: $id, date: $date, moodScore: $moodScore, productivity: $productivity, energy: $energy, createdAt: $createdAt, note: $note)';
  }
}
abstract mixin class _$UserCheckinCopyWith<$Res>
    implements $UserCheckinCopyWith<$Res> {
  factory _$UserCheckinCopyWith(
          _UserCheckin value, $Res Function(_UserCheckin) _then) =
      __$UserCheckinCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      int moodScore,
      int productivity,
      int energy,
      DateTime createdAt,
      String note});
}
class __$UserCheckinCopyWithImpl<$Res> implements _$UserCheckinCopyWith<$Res> {
  __$UserCheckinCopyWithImpl(this._self, this._then);
  final _UserCheckin _self;
  final $Res Function(_UserCheckin) _then;
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? moodScore = null,
    Object? productivity = null,
    Object? energy = null,
    Object? createdAt = null,
    Object? note = null,
  }) {
    return _then(_UserCheckin(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      moodScore: null == moodScore
          ? _self.moodScore
          : moodScore // ignore: cast_nullable_to_non_nullable
              as int,
      productivity: null == productivity
          ? _self.productivity
          : productivity // ignore: cast_nullable_to_non_nullable
              as int,
      energy: null == energy
          ? _self.energy
          : energy // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: null == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

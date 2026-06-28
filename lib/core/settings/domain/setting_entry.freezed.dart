// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
part of 'setting_entry.dart';
T _$identity<T>(T value) => value;
mixin _$SettingEntry {
  String get key;
  String get value;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingEntryCopyWith<SettingEntry> get copyWith =>
      _$SettingEntryCopyWithImpl<SettingEntry>(
          this as SettingEntry, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SettingEntry &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value));
  }
  @override
  int get hashCode => Object.hash(runtimeType, key, value);
  @override
  String toString() {
    return 'SettingEntry(key: $key, value: $value)';
  }
}
abstract mixin class $SettingEntryCopyWith<$Res> {
  factory $SettingEntryCopyWith(
          SettingEntry value, $Res Function(SettingEntry) _then) =
      _$SettingEntryCopyWithImpl;
  @useResult
  $Res call({String key, String value});
}
class _$SettingEntryCopyWithImpl<$Res> implements $SettingEntryCopyWith<$Res> {
  _$SettingEntryCopyWithImpl(this._self, this._then);
  final SettingEntry _self;
  final $Res Function(SettingEntry) _then;
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}
extension SettingEntryPatterns on SettingEntry {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SettingEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingEntry() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SettingEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingEntry():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SettingEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingEntry() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String key, String value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingEntry() when $default != null:
        return $default(_that.key, _that.value);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String key, String value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingEntry():
        return $default(_that.key, _that.value);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String key, String value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingEntry() when $default != null:
        return $default(_that.key, _that.value);
      case _:
        return null;
    }
  }
}
class _SettingEntry implements SettingEntry {
  const _SettingEntry({required this.key, required this.value});
  @override
  final String key;
  @override
  final String value;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingEntryCopyWith<_SettingEntry> get copyWith =>
      __$SettingEntryCopyWithImpl<_SettingEntry>(this, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SettingEntry &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value));
  }
  @override
  int get hashCode => Object.hash(runtimeType, key, value);
  @override
  String toString() {
    return 'SettingEntry(key: $key, value: $value)';
  }
}
abstract mixin class _$SettingEntryCopyWith<$Res>
    implements $SettingEntryCopyWith<$Res> {
  factory _$SettingEntryCopyWith(
          _SettingEntry value, $Res Function(_SettingEntry) _then) =
      __$SettingEntryCopyWithImpl;
  @override
  @useResult
  $Res call({String key, String value});
}
class __$SettingEntryCopyWithImpl<$Res>
    implements _$SettingEntryCopyWith<$Res> {
  __$SettingEntryCopyWithImpl(this._self, this._then);
  final _SettingEntry _self;
  final $Res Function(_SettingEntry) _then;
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? key = null,
    Object? value = null,
  }) {
    return _then(_SettingEntry(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
part of 'task_tag.dart';
T _$identity<T>(T value) => value;
mixin _$TaskTag {
  String get id;
  String get taskId;
  String get tagName;
  bool get isPrimary;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskTagCopyWith<TaskTag> get copyWith =>
      _$TaskTagCopyWithImpl<TaskTag>(this as TaskTag, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskTag &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.tagName, tagName) || other.tagName == tagName) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary));
  }
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, tagName, isPrimary);
  @override
  String toString() {
    return 'TaskTag(id: $id, taskId: $taskId, tagName: $tagName, isPrimary: $isPrimary)';
  }
}
abstract mixin class $TaskTagCopyWith<$Res> {
  factory $TaskTagCopyWith(TaskTag value, $Res Function(TaskTag) _then) =
      _$TaskTagCopyWithImpl;
  @useResult
  $Res call({String id, String taskId, String tagName, bool isPrimary});
}
class _$TaskTagCopyWithImpl<$Res> implements $TaskTagCopyWith<$Res> {
  _$TaskTagCopyWithImpl(this._self, this._then);
  final TaskTag _self;
  final $Res Function(TaskTag) _then;
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? tagName = null,
    Object? isPrimary = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      tagName: null == tagName
          ? _self.tagName
          : tagName // ignore: cast_nullable_to_non_nullable
              as String,
      isPrimary: null == isPrimary
          ? _self.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}
extension TaskTagPatterns on TaskTag {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TaskTag value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskTag() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TaskTag value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskTag():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TaskTag value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskTag() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String taskId, String tagName, bool isPrimary)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskTag() when $default != null:
        return $default(_that.id, _that.taskId, _that.tagName, _that.isPrimary);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String taskId, String tagName, bool isPrimary)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskTag():
        return $default(_that.id, _that.taskId, _that.tagName, _that.isPrimary);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String taskId, String tagName, bool isPrimary)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskTag() when $default != null:
        return $default(_that.id, _that.taskId, _that.tagName, _that.isPrimary);
      case _:
        return null;
    }
  }
}
class _TaskTag implements TaskTag {
  const _TaskTag(
      {required this.id,
      required this.taskId,
      required this.tagName,
      this.isPrimary = false});
  @override
  final String id;
  @override
  final String taskId;
  @override
  final String tagName;
  @override
  @JsonKey()
  final bool isPrimary;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TaskTagCopyWith<_TaskTag> get copyWith =>
      __$TaskTagCopyWithImpl<_TaskTag>(this, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TaskTag &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.tagName, tagName) || other.tagName == tagName) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary));
  }
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, tagName, isPrimary);
  @override
  String toString() {
    return 'TaskTag(id: $id, taskId: $taskId, tagName: $tagName, isPrimary: $isPrimary)';
  }
}
abstract mixin class _$TaskTagCopyWith<$Res> implements $TaskTagCopyWith<$Res> {
  factory _$TaskTagCopyWith(_TaskTag value, $Res Function(_TaskTag) _then) =
      __$TaskTagCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String taskId, String tagName, bool isPrimary});
}
class __$TaskTagCopyWithImpl<$Res> implements _$TaskTagCopyWith<$Res> {
  __$TaskTagCopyWithImpl(this._self, this._then);
  final _TaskTag _self;
  final $Res Function(_TaskTag) _then;
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? tagName = null,
    Object? isPrimary = null,
  }) {
    return _then(_TaskTag(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      tagName: null == tagName
          ? _self.tagName
          : tagName // ignore: cast_nullable_to_non_nullable
              as String,
      isPrimary: null == isPrimary
          ? _self.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

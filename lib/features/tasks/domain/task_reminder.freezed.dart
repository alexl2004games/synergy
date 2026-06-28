// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
part of 'task_reminder.dart';
T _$identity<T>(T value) => value;
mixin _$TaskReminder {
  String get id;
  String get taskId;
  DateTime get remindAt;
  bool get isSent;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskReminderCopyWith<TaskReminder> get copyWith =>
      _$TaskReminderCopyWithImpl<TaskReminder>(
          this as TaskReminder, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskReminder &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.remindAt, remindAt) ||
                other.remindAt == remindAt) &&
            (identical(other.isSent, isSent) || other.isSent == isSent));
  }
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, remindAt, isSent);
  @override
  String toString() {
    return 'TaskReminder(id: $id, taskId: $taskId, remindAt: $remindAt, isSent: $isSent)';
  }
}
abstract mixin class $TaskReminderCopyWith<$Res> {
  factory $TaskReminderCopyWith(
          TaskReminder value, $Res Function(TaskReminder) _then) =
      _$TaskReminderCopyWithImpl;
  @useResult
  $Res call({String id, String taskId, DateTime remindAt, bool isSent});
}
class _$TaskReminderCopyWithImpl<$Res> implements $TaskReminderCopyWith<$Res> {
  _$TaskReminderCopyWithImpl(this._self, this._then);
  final TaskReminder _self;
  final $Res Function(TaskReminder) _then;
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? remindAt = null,
    Object? isSent = null,
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
      remindAt: null == remindAt
          ? _self.remindAt
          : remindAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isSent: null == isSent
          ? _self.isSent
          : isSent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}
extension TaskReminderPatterns on TaskReminder {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TaskReminder value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskReminder() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TaskReminder value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskReminder():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TaskReminder value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskReminder() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String taskId, DateTime remindAt, bool isSent)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskReminder() when $default != null:
        return $default(_that.id, _that.taskId, _that.remindAt, _that.isSent);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String taskId, DateTime remindAt, bool isSent)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskReminder():
        return $default(_that.id, _that.taskId, _that.remindAt, _that.isSent);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String taskId, DateTime remindAt, bool isSent)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskReminder() when $default != null:
        return $default(_that.id, _that.taskId, _that.remindAt, _that.isSent);
      case _:
        return null;
    }
  }
}
class _TaskReminder implements TaskReminder {
  const _TaskReminder(
      {required this.id,
      required this.taskId,
      required this.remindAt,
      this.isSent = false});
  @override
  final String id;
  @override
  final String taskId;
  @override
  final DateTime remindAt;
  @override
  @JsonKey()
  final bool isSent;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TaskReminderCopyWith<_TaskReminder> get copyWith =>
      __$TaskReminderCopyWithImpl<_TaskReminder>(this, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TaskReminder &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.remindAt, remindAt) ||
                other.remindAt == remindAt) &&
            (identical(other.isSent, isSent) || other.isSent == isSent));
  }
  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, remindAt, isSent);
  @override
  String toString() {
    return 'TaskReminder(id: $id, taskId: $taskId, remindAt: $remindAt, isSent: $isSent)';
  }
}
abstract mixin class _$TaskReminderCopyWith<$Res>
    implements $TaskReminderCopyWith<$Res> {
  factory _$TaskReminderCopyWith(
          _TaskReminder value, $Res Function(_TaskReminder) _then) =
      __$TaskReminderCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String taskId, DateTime remindAt, bool isSent});
}
class __$TaskReminderCopyWithImpl<$Res>
    implements _$TaskReminderCopyWith<$Res> {
  __$TaskReminderCopyWithImpl(this._self, this._then);
  final _TaskReminder _self;
  final $Res Function(_TaskReminder) _then;
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? remindAt = null,
    Object? isSent = null,
  }) {
    return _then(_TaskReminder(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      remindAt: null == remindAt
          ? _self.remindAt
          : remindAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isSent: null == isSent
          ? _self.isSent
          : isSent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

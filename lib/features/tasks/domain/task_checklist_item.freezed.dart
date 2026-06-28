// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
part of 'task_checklist_item.dart';
T _$identity<T>(T value) => value;
mixin _$TaskChecklistItem {
  String get id;
  String get taskId;
  String get title;
  bool get isDone;
  int get orderIndex;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskChecklistItemCopyWith<TaskChecklistItem> get copyWith =>
      _$TaskChecklistItemCopyWithImpl<TaskChecklistItem>(
          this as TaskChecklistItem, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TaskChecklistItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isDone, isDone) || other.isDone == isDone) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex));
  }
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, taskId, title, isDone, orderIndex);
  @override
  String toString() {
    return 'TaskChecklistItem(id: $id, taskId: $taskId, title: $title, isDone: $isDone, orderIndex: $orderIndex)';
  }
}
abstract mixin class $TaskChecklistItemCopyWith<$Res> {
  factory $TaskChecklistItemCopyWith(
          TaskChecklistItem value, $Res Function(TaskChecklistItem) _then) =
      _$TaskChecklistItemCopyWithImpl;
  @useResult
  $Res call(
      {String id, String taskId, String title, bool isDone, int orderIndex});
}
class _$TaskChecklistItemCopyWithImpl<$Res>
    implements $TaskChecklistItemCopyWith<$Res> {
  _$TaskChecklistItemCopyWithImpl(this._self, this._then);
  final TaskChecklistItem _self;
  final $Res Function(TaskChecklistItem) _then;
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? title = null,
    Object? isDone = null,
    Object? orderIndex = null,
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
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isDone: null == isDone
          ? _self.isDone
          : isDone // ignore: cast_nullable_to_non_nullable
              as bool,
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}
extension TaskChecklistItemPatterns on TaskChecklistItem {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TaskChecklistItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskChecklistItem() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TaskChecklistItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskChecklistItem():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TaskChecklistItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskChecklistItem() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String taskId, String title, bool isDone,
            int orderIndex)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TaskChecklistItem() when $default != null:
        return $default(_that.id, _that.taskId, _that.title, _that.isDone,
            _that.orderIndex);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id, String taskId, String title, bool isDone, int orderIndex)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskChecklistItem():
        return $default(_that.id, _that.taskId, _that.title, _that.isDone,
            _that.orderIndex);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String taskId, String title, bool isDone,
            int orderIndex)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TaskChecklistItem() when $default != null:
        return $default(_that.id, _that.taskId, _that.title, _that.isDone,
            _that.orderIndex);
      case _:
        return null;
    }
  }
}
class _TaskChecklistItem implements TaskChecklistItem {
  const _TaskChecklistItem(
      {required this.id,
      required this.taskId,
      required this.title,
      this.isDone = false,
      this.orderIndex = 0});
  @override
  final String id;
  @override
  final String taskId;
  @override
  final String title;
  @override
  @JsonKey()
  final bool isDone;
  @override
  @JsonKey()
  final int orderIndex;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TaskChecklistItemCopyWith<_TaskChecklistItem> get copyWith =>
      __$TaskChecklistItemCopyWithImpl<_TaskChecklistItem>(this, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TaskChecklistItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isDone, isDone) || other.isDone == isDone) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex));
  }
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, taskId, title, isDone, orderIndex);
  @override
  String toString() {
    return 'TaskChecklistItem(id: $id, taskId: $taskId, title: $title, isDone: $isDone, orderIndex: $orderIndex)';
  }
}
abstract mixin class _$TaskChecklistItemCopyWith<$Res>
    implements $TaskChecklistItemCopyWith<$Res> {
  factory _$TaskChecklistItemCopyWith(
          _TaskChecklistItem value, $Res Function(_TaskChecklistItem) _then) =
      __$TaskChecklistItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id, String taskId, String title, bool isDone, int orderIndex});
}
class __$TaskChecklistItemCopyWithImpl<$Res>
    implements _$TaskChecklistItemCopyWith<$Res> {
  __$TaskChecklistItemCopyWithImpl(this._self, this._then);
  final _TaskChecklistItem _self;
  final $Res Function(_TaskChecklistItem) _then;
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? title = null,
    Object? isDone = null,
    Object? orderIndex = null,
  }) {
    return _then(_TaskChecklistItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isDone: null == isDone
          ? _self.isDone
          : isDone // ignore: cast_nullable_to_non_nullable
              as bool,
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

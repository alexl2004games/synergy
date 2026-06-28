// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
part of 'task.dart';
T _$identity<T>(T value) => value;
mixin _$Task {
  String get id;
  String get title;
  DateTime get createdAt;
  DateTime get updatedAt;
  String get notes;
  DateTime? get deadlineAt;
  DateTime? get startAt;
  DateTime? get endAt;
  bool get isAllDay;
  bool get isPinned;
  int get estMin;
  int? get actualMin;
  TaskStatus get status;
  TaskPriority get priority;
  double get aiConfidence;
  String? get parentTaskId;
  String? get recurrenceRule;
  bool get isExceptionOfRule;
  String? get exceptionOriginalId;
  DateTime? get completedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TaskCopyWith<Task> get copyWith =>
      _$TaskCopyWithImpl<Task>(this as Task, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Task &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.deadlineAt, deadlineAt) ||
                other.deadlineAt == deadlineAt) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.estMin, estMin) || other.estMin == estMin) &&
            (identical(other.actualMin, actualMin) ||
                other.actualMin == actualMin) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.aiConfidence, aiConfidence) ||
                other.aiConfidence == aiConfidence) &&
            (identical(other.parentTaskId, parentTaskId) ||
                other.parentTaskId == parentTaskId) &&
            (identical(other.recurrenceRule, recurrenceRule) ||
                other.recurrenceRule == recurrenceRule) &&
            (identical(other.isExceptionOfRule, isExceptionOfRule) ||
                other.isExceptionOfRule == isExceptionOfRule) &&
            (identical(other.exceptionOriginalId, exceptionOriginalId) ||
                other.exceptionOriginalId == exceptionOriginalId) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        createdAt,
        updatedAt,
        notes,
        deadlineAt,
        startAt,
        endAt,
        isAllDay,
        isPinned,
        estMin,
        actualMin,
        status,
        priority,
        aiConfidence,
        parentTaskId,
        recurrenceRule,
        isExceptionOfRule,
        exceptionOriginalId,
        completedAt
      ]);
  @override
  String toString() {
    return 'Task(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, deadlineAt: $deadlineAt, startAt: $startAt, endAt: $endAt, isAllDay: $isAllDay, isPinned: $isPinned, estMin: $estMin, actualMin: $actualMin, status: $status, priority: $priority, aiConfidence: $aiConfidence, parentTaskId: $parentTaskId, recurrenceRule: $recurrenceRule, isExceptionOfRule: $isExceptionOfRule, exceptionOriginalId: $exceptionOriginalId, completedAt: $completedAt)';
  }
}
abstract mixin class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) =
      _$TaskCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime createdAt,
      DateTime updatedAt,
      String notes,
      DateTime? deadlineAt,
      DateTime? startAt,
      DateTime? endAt,
      bool isAllDay,
      bool isPinned,
      int estMin,
      int? actualMin,
      TaskStatus status,
      TaskPriority priority,
      double aiConfidence,
      String? parentTaskId,
      String? recurrenceRule,
      bool isExceptionOfRule,
      String? exceptionOriginalId,
      DateTime? completedAt});
}
class _$TaskCopyWithImpl<$Res> implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);
  final Task _self;
  final $Res Function(Task) _then;
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? notes = null,
    Object? deadlineAt = freezed,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? isAllDay = null,
    Object? isPinned = null,
    Object? estMin = null,
    Object? actualMin = freezed,
    Object? status = null,
    Object? priority = null,
    Object? aiConfidence = null,
    Object? parentTaskId = freezed,
    Object? recurrenceRule = freezed,
    Object? isExceptionOfRule = null,
    Object? exceptionOriginalId = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      deadlineAt: freezed == deadlineAt
          ? _self.deadlineAt
          : deadlineAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startAt: freezed == startAt
          ? _self.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endAt: freezed == endAt
          ? _self.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAllDay: null == isAllDay
          ? _self.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      isPinned: null == isPinned
          ? _self.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      estMin: null == estMin
          ? _self.estMin
          : estMin // ignore: cast_nullable_to_non_nullable
              as int,
      actualMin: freezed == actualMin
          ? _self.actualMin
          : actualMin // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as TaskPriority,
      aiConfidence: null == aiConfidence
          ? _self.aiConfidence
          : aiConfidence // ignore: cast_nullable_to_non_nullable
              as double,
      parentTaskId: freezed == parentTaskId
          ? _self.parentTaskId
          : parentTaskId // ignore: cast_nullable_to_non_nullable
              as String?,
      recurrenceRule: freezed == recurrenceRule
          ? _self.recurrenceRule
          : recurrenceRule // ignore: cast_nullable_to_non_nullable
              as String?,
      isExceptionOfRule: null == isExceptionOfRule
          ? _self.isExceptionOfRule
          : isExceptionOfRule // ignore: cast_nullable_to_non_nullable
              as bool,
      exceptionOriginalId: freezed == exceptionOriginalId
          ? _self.exceptionOriginalId
          : exceptionOriginalId // ignore: cast_nullable_to_non_nullable
              as String?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}
extension TaskPatterns on Task {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Task value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Task() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Task value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Task():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Task value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Task() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            DateTime createdAt,
            DateTime updatedAt,
            String notes,
            DateTime? deadlineAt,
            DateTime? startAt,
            DateTime? endAt,
            bool isAllDay,
            bool isPinned,
            int estMin,
            int? actualMin,
            TaskStatus status,
            TaskPriority priority,
            double aiConfidence,
            String? parentTaskId,
            String? recurrenceRule,
            bool isExceptionOfRule,
            String? exceptionOriginalId,
            DateTime? completedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Task() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.createdAt,
            _that.updatedAt,
            _that.notes,
            _that.deadlineAt,
            _that.startAt,
            _that.endAt,
            _that.isAllDay,
            _that.isPinned,
            _that.estMin,
            _that.actualMin,
            _that.status,
            _that.priority,
            _that.aiConfidence,
            _that.parentTaskId,
            _that.recurrenceRule,
            _that.isExceptionOfRule,
            _that.exceptionOriginalId,
            _that.completedAt);
      case _:
        return orElse();
    }
  }
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String title,
            DateTime createdAt,
            DateTime updatedAt,
            String notes,
            DateTime? deadlineAt,
            DateTime? startAt,
            DateTime? endAt,
            bool isAllDay,
            bool isPinned,
            int estMin,
            int? actualMin,
            TaskStatus status,
            TaskPriority priority,
            double aiConfidence,
            String? parentTaskId,
            String? recurrenceRule,
            bool isExceptionOfRule,
            String? exceptionOriginalId,
            DateTime? completedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Task():
        return $default(
            _that.id,
            _that.title,
            _that.createdAt,
            _that.updatedAt,
            _that.notes,
            _that.deadlineAt,
            _that.startAt,
            _that.endAt,
            _that.isAllDay,
            _that.isPinned,
            _that.estMin,
            _that.actualMin,
            _that.status,
            _that.priority,
            _that.aiConfidence,
            _that.parentTaskId,
            _that.recurrenceRule,
            _that.isExceptionOfRule,
            _that.exceptionOriginalId,
            _that.completedAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String title,
            DateTime createdAt,
            DateTime updatedAt,
            String notes,
            DateTime? deadlineAt,
            DateTime? startAt,
            DateTime? endAt,
            bool isAllDay,
            bool isPinned,
            int estMin,
            int? actualMin,
            TaskStatus status,
            TaskPriority priority,
            double aiConfidence,
            String? parentTaskId,
            String? recurrenceRule,
            bool isExceptionOfRule,
            String? exceptionOriginalId,
            DateTime? completedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Task() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.createdAt,
            _that.updatedAt,
            _that.notes,
            _that.deadlineAt,
            _that.startAt,
            _that.endAt,
            _that.isAllDay,
            _that.isPinned,
            _that.estMin,
            _that.actualMin,
            _that.status,
            _that.priority,
            _that.aiConfidence,
            _that.parentTaskId,
            _that.recurrenceRule,
            _that.isExceptionOfRule,
            _that.exceptionOriginalId,
            _that.completedAt);
      case _:
        return null;
    }
  }
}
class _Task implements Task {
  const _Task(
      {required this.id,
      required this.title,
      required this.createdAt,
      required this.updatedAt,
      this.notes = '',
      this.deadlineAt,
      this.startAt,
      this.endAt,
      this.isAllDay = false,
      this.isPinned = false,
      this.estMin = 30,
      this.actualMin,
      this.status = TaskStatus.pending,
      this.priority = TaskPriority.medium,
      this.aiConfidence = 1.0,
      this.parentTaskId,
      this.recurrenceRule,
      this.isExceptionOfRule = false,
      this.exceptionOriginalId,
      this.completedAt});
  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String notes;
  @override
  final DateTime? deadlineAt;
  @override
  final DateTime? startAt;
  @override
  final DateTime? endAt;
  @override
  @JsonKey()
  final bool isAllDay;
  @override
  @JsonKey()
  final bool isPinned;
  @override
  @JsonKey()
  final int estMin;
  @override
  final int? actualMin;
  @override
  @JsonKey()
  final TaskStatus status;
  @override
  @JsonKey()
  final TaskPriority priority;
  @override
  @JsonKey()
  final double aiConfidence;
  @override
  final String? parentTaskId;
  @override
  final String? recurrenceRule;
  @override
  @JsonKey()
  final bool isExceptionOfRule;
  @override
  final String? exceptionOriginalId;
  @override
  final DateTime? completedAt;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TaskCopyWith<_Task> get copyWith =>
      __$TaskCopyWithImpl<_Task>(this, _$identity);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Task &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.deadlineAt, deadlineAt) ||
                other.deadlineAt == deadlineAt) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.estMin, estMin) || other.estMin == estMin) &&
            (identical(other.actualMin, actualMin) ||
                other.actualMin == actualMin) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.aiConfidence, aiConfidence) ||
                other.aiConfidence == aiConfidence) &&
            (identical(other.parentTaskId, parentTaskId) ||
                other.parentTaskId == parentTaskId) &&
            (identical(other.recurrenceRule, recurrenceRule) ||
                other.recurrenceRule == recurrenceRule) &&
            (identical(other.isExceptionOfRule, isExceptionOfRule) ||
                other.isExceptionOfRule == isExceptionOfRule) &&
            (identical(other.exceptionOriginalId, exceptionOriginalId) ||
                other.exceptionOriginalId == exceptionOriginalId) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        createdAt,
        updatedAt,
        notes,
        deadlineAt,
        startAt,
        endAt,
        isAllDay,
        isPinned,
        estMin,
        actualMin,
        status,
        priority,
        aiConfidence,
        parentTaskId,
        recurrenceRule,
        isExceptionOfRule,
        exceptionOriginalId,
        completedAt
      ]);
  @override
  String toString() {
    return 'Task(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, deadlineAt: $deadlineAt, startAt: $startAt, endAt: $endAt, isAllDay: $isAllDay, isPinned: $isPinned, estMin: $estMin, actualMin: $actualMin, status: $status, priority: $priority, aiConfidence: $aiConfidence, parentTaskId: $parentTaskId, recurrenceRule: $recurrenceRule, isExceptionOfRule: $isExceptionOfRule, exceptionOriginalId: $exceptionOriginalId, completedAt: $completedAt)';
  }
}
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) =
      __$TaskCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime createdAt,
      DateTime updatedAt,
      String notes,
      DateTime? deadlineAt,
      DateTime? startAt,
      DateTime? endAt,
      bool isAllDay,
      bool isPinned,
      int estMin,
      int? actualMin,
      TaskStatus status,
      TaskPriority priority,
      double aiConfidence,
      String? parentTaskId,
      String? recurrenceRule,
      bool isExceptionOfRule,
      String? exceptionOriginalId,
      DateTime? completedAt});
}
class __$TaskCopyWithImpl<$Res> implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);
  final _Task _self;
  final $Res Function(_Task) _then;
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? notes = null,
    Object? deadlineAt = freezed,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? isAllDay = null,
    Object? isPinned = null,
    Object? estMin = null,
    Object? actualMin = freezed,
    Object? status = null,
    Object? priority = null,
    Object? aiConfidence = null,
    Object? parentTaskId = freezed,
    Object? recurrenceRule = freezed,
    Object? isExceptionOfRule = null,
    Object? exceptionOriginalId = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_Task(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      deadlineAt: freezed == deadlineAt
          ? _self.deadlineAt
          : deadlineAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startAt: freezed == startAt
          ? _self.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endAt: freezed == endAt
          ? _self.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAllDay: null == isAllDay
          ? _self.isAllDay
          : isAllDay // ignore: cast_nullable_to_non_nullable
              as bool,
      isPinned: null == isPinned
          ? _self.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      estMin: null == estMin
          ? _self.estMin
          : estMin // ignore: cast_nullable_to_non_nullable
              as int,
      actualMin: freezed == actualMin
          ? _self.actualMin
          : actualMin // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as TaskPriority,
      aiConfidence: null == aiConfidence
          ? _self.aiConfidence
          : aiConfidence // ignore: cast_nullable_to_non_nullable
              as double,
      parentTaskId: freezed == parentTaskId
          ? _self.parentTaskId
          : parentTaskId // ignore: cast_nullable_to_non_nullable
              as String?,
      recurrenceRule: freezed == recurrenceRule
          ? _self.recurrenceRule
          : recurrenceRule // ignore: cast_nullable_to_non_nullable
              as String?,
      isExceptionOfRule: null == isExceptionOfRule
          ? _self.isExceptionOfRule
          : isExceptionOfRule // ignore: cast_nullable_to_non_nullable
              as bool,
      exceptionOriginalId: freezed == exceptionOriginalId
          ? _self.exceptionOriginalId
          : exceptionOriginalId // ignore: cast_nullable_to_non_nullable
              as String?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

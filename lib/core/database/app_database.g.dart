part of 'app_database.dart';
// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _deadlineAtMeta =
      const VerificationMeta('deadlineAt');
  @override
  late final GeneratedColumn<int> deadlineAt = GeneratedColumn<int>(
      'deadline_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startAtMeta =
      const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<int> startAt = GeneratedColumn<int>(
      'start_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<int> endAt = GeneratedColumn<int>(
      'end_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isAllDayMeta =
      const VerificationMeta('isAllDay');
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
      'is_all_day', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_all_day" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _estMinMeta = const VerificationMeta('estMin');
  @override
  late final GeneratedColumn<int> estMin = GeneratedColumn<int>(
      'est_min', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _actualMinMeta =
      const VerificationMeta('actualMin');
  @override
  late final GeneratedColumn<int> actualMin = GeneratedColumn<int>(
      'actual_min', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('pending'))
          .withConverter<TaskStatus>($TasksTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<TaskPriority, String> priority =
      GeneratedColumn<String>('priority', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('medium'))
          .withConverter<TaskPriority>($TasksTable.$converterpriority);
  static const VerificationMeta _aiConfidenceMeta =
      const VerificationMeta('aiConfidence');
  @override
  late final GeneratedColumn<double> aiConfidence = GeneratedColumn<double>(
      'ai_confidence', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _parentTaskIdMeta =
      const VerificationMeta('parentTaskId');
  @override
  late final GeneratedColumn<String> parentTaskId = GeneratedColumn<String>(
      'parent_task_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _recurrenceRuleMeta =
      const VerificationMeta('recurrenceRule');
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
      'recurrence_rule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isExceptionOfRuleMeta =
      const VerificationMeta('isExceptionOfRule');
  @override
  late final GeneratedColumn<bool> isExceptionOfRule = GeneratedColumn<bool>(
      'is_exception_of_rule', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_exception_of_rule" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _exceptionOriginalIdMeta =
      const VerificationMeta('exceptionOriginalId');
  @override
  late final GeneratedColumn<String> exceptionOriginalId =
      GeneratedColumn<String>('exception_original_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
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
        createdAt,
        updatedAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('deadline_at')) {
      context.handle(
          _deadlineAtMeta,
          deadlineAt.isAcceptableOrUnknown(
              data['deadline_at']!, _deadlineAtMeta));
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta,
          startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    }
    if (data.containsKey('end_at')) {
      context.handle(
          _endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    }
    if (data.containsKey('is_all_day')) {
      context.handle(_isAllDayMeta,
          isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('est_min')) {
      context.handle(_estMinMeta,
          estMin.isAcceptableOrUnknown(data['est_min']!, _estMinMeta));
    }
    if (data.containsKey('actual_min')) {
      context.handle(_actualMinMeta,
          actualMin.isAcceptableOrUnknown(data['actual_min']!, _actualMinMeta));
    }
    if (data.containsKey('ai_confidence')) {
      context.handle(
          _aiConfidenceMeta,
          aiConfidence.isAcceptableOrUnknown(
              data['ai_confidence']!, _aiConfidenceMeta));
    }
    if (data.containsKey('parent_task_id')) {
      context.handle(
          _parentTaskIdMeta,
          parentTaskId.isAcceptableOrUnknown(
              data['parent_task_id']!, _parentTaskIdMeta));
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
          _recurrenceRuleMeta,
          recurrenceRule.isAcceptableOrUnknown(
              data['recurrence_rule']!, _recurrenceRuleMeta));
    }
    if (data.containsKey('is_exception_of_rule')) {
      context.handle(
          _isExceptionOfRuleMeta,
          isExceptionOfRule.isAcceptableOrUnknown(
              data['is_exception_of_rule']!, _isExceptionOfRuleMeta));
    }
    if (data.containsKey('exception_original_id')) {
      context.handle(
          _exceptionOriginalIdMeta,
          exceptionOriginalId.isAcceptableOrUnknown(
              data['exception_original_id']!, _exceptionOriginalIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      deadlineAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deadline_at']),
      startAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_at']),
      endAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_at']),
      isAllDay: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_all_day'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      estMin: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}est_min'])!,
      actualMin: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}actual_min']),
      status: $TasksTable.$converterstatus.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      priority: $TasksTable.$converterpriority.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!),
      aiConfidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ai_confidence'])!,
      parentTaskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_task_id']),
      recurrenceRule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence_rule']),
      isExceptionOfRule: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_exception_of_rule'])!,
      exceptionOriginalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}exception_original_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
    );
  }
  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
  static JsonTypeConverter2<TaskStatus, String, String> $converterstatus =
      const EnumNameConverter<TaskStatus>(TaskStatus.values);
  static JsonTypeConverter2<TaskPriority, String, String> $converterpriority =
      const EnumNameConverter<TaskPriority>(TaskPriority.values);
}
class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final String notes;
  final int? deadlineAt;
  final int? startAt;
  final int? endAt;
  final bool isAllDay;
  final bool isPinned;
  final int estMin;
  final int? actualMin;
  final TaskStatus status;
  final TaskPriority priority;
  final double aiConfidence;
  final String? parentTaskId;
  final String? recurrenceRule;
  final bool isExceptionOfRule;
  final String? exceptionOriginalId;
  final int createdAt;
  final int updatedAt;
  final int? completedAt;
  const Task(
      {required this.id,
      required this.title,
      required this.notes,
      this.deadlineAt,
      this.startAt,
      this.endAt,
      required this.isAllDay,
      required this.isPinned,
      required this.estMin,
      this.actualMin,
      required this.status,
      required this.priority,
      required this.aiConfidence,
      this.parentTaskId,
      this.recurrenceRule,
      required this.isExceptionOfRule,
      this.exceptionOriginalId,
      required this.createdAt,
      required this.updatedAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || deadlineAt != null) {
      map['deadline_at'] = Variable<int>(deadlineAt);
    }
    if (!nullToAbsent || startAt != null) {
      map['start_at'] = Variable<int>(startAt);
    }
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<int>(endAt);
    }
    map['is_all_day'] = Variable<bool>(isAllDay);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['est_min'] = Variable<int>(estMin);
    if (!nullToAbsent || actualMin != null) {
      map['actual_min'] = Variable<int>(actualMin);
    }
    {
      map['status'] =
          Variable<String>($TasksTable.$converterstatus.toSql(status));
    }
    {
      map['priority'] =
          Variable<String>($TasksTable.$converterpriority.toSql(priority));
    }
    map['ai_confidence'] = Variable<double>(aiConfidence);
    if (!nullToAbsent || parentTaskId != null) {
      map['parent_task_id'] = Variable<String>(parentTaskId);
    }
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    map['is_exception_of_rule'] = Variable<bool>(isExceptionOfRule);
    if (!nullToAbsent || exceptionOriginalId != null) {
      map['exception_original_id'] = Variable<String>(exceptionOriginalId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }
  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      notes: Value(notes),
      deadlineAt: deadlineAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineAt),
      startAt: startAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startAt),
      endAt:
          endAt == null && nullToAbsent ? const Value.absent() : Value(endAt),
      isAllDay: Value(isAllDay),
      isPinned: Value(isPinned),
      estMin: Value(estMin),
      actualMin: actualMin == null && nullToAbsent
          ? const Value.absent()
          : Value(actualMin),
      status: Value(status),
      priority: Value(priority),
      aiConfidence: Value(aiConfidence),
      parentTaskId: parentTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTaskId),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      isExceptionOfRule: Value(isExceptionOfRule),
      exceptionOriginalId: exceptionOriginalId == null && nullToAbsent
          ? const Value.absent()
          : Value(exceptionOriginalId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }
  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      deadlineAt: serializer.fromJson<int?>(json['deadlineAt']),
      startAt: serializer.fromJson<int?>(json['startAt']),
      endAt: serializer.fromJson<int?>(json['endAt']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      estMin: serializer.fromJson<int>(json['estMin']),
      actualMin: serializer.fromJson<int?>(json['actualMin']),
      status: $TasksTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      priority: $TasksTable.$converterpriority
          .fromJson(serializer.fromJson<String>(json['priority'])),
      aiConfidence: serializer.fromJson<double>(json['aiConfidence']),
      parentTaskId: serializer.fromJson<String?>(json['parentTaskId']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      isExceptionOfRule: serializer.fromJson<bool>(json['isExceptionOfRule']),
      exceptionOriginalId:
          serializer.fromJson<String?>(json['exceptionOriginalId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'deadlineAt': serializer.toJson<int?>(deadlineAt),
      'startAt': serializer.toJson<int?>(startAt),
      'endAt': serializer.toJson<int?>(endAt),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'isPinned': serializer.toJson<bool>(isPinned),
      'estMin': serializer.toJson<int>(estMin),
      'actualMin': serializer.toJson<int?>(actualMin),
      'status': serializer
          .toJson<String>($TasksTable.$converterstatus.toJson(status)),
      'priority': serializer
          .toJson<String>($TasksTable.$converterpriority.toJson(priority)),
      'aiConfidence': serializer.toJson<double>(aiConfidence),
      'parentTaskId': serializer.toJson<String?>(parentTaskId),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'isExceptionOfRule': serializer.toJson<bool>(isExceptionOfRule),
      'exceptionOriginalId': serializer.toJson<String?>(exceptionOriginalId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
    };
  }
  Task copyWith(
          {String? id,
          String? title,
          String? notes,
          Value<int?> deadlineAt = const Value.absent(),
          Value<int?> startAt = const Value.absent(),
          Value<int?> endAt = const Value.absent(),
          bool? isAllDay,
          bool? isPinned,
          int? estMin,
          Value<int?> actualMin = const Value.absent(),
          TaskStatus? status,
          TaskPriority? priority,
          double? aiConfidence,
          Value<String?> parentTaskId = const Value.absent(),
          Value<String?> recurrenceRule = const Value.absent(),
          bool? isExceptionOfRule,
          Value<String?> exceptionOriginalId = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<int?> completedAt = const Value.absent()}) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        deadlineAt: deadlineAt.present ? deadlineAt.value : this.deadlineAt,
        startAt: startAt.present ? startAt.value : this.startAt,
        endAt: endAt.present ? endAt.value : this.endAt,
        isAllDay: isAllDay ?? this.isAllDay,
        isPinned: isPinned ?? this.isPinned,
        estMin: estMin ?? this.estMin,
        actualMin: actualMin.present ? actualMin.value : this.actualMin,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        aiConfidence: aiConfidence ?? this.aiConfidence,
        parentTaskId:
            parentTaskId.present ? parentTaskId.value : this.parentTaskId,
        recurrenceRule:
            recurrenceRule.present ? recurrenceRule.value : this.recurrenceRule,
        isExceptionOfRule: isExceptionOfRule ?? this.isExceptionOfRule,
        exceptionOriginalId: exceptionOriginalId.present
            ? exceptionOriginalId.value
            : this.exceptionOriginalId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      deadlineAt:
          data.deadlineAt.present ? data.deadlineAt.value : this.deadlineAt,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      estMin: data.estMin.present ? data.estMin.value : this.estMin,
      actualMin: data.actualMin.present ? data.actualMin.value : this.actualMin,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      aiConfidence: data.aiConfidence.present
          ? data.aiConfidence.value
          : this.aiConfidence,
      parentTaskId: data.parentTaskId.present
          ? data.parentTaskId.value
          : this.parentTaskId,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      isExceptionOfRule: data.isExceptionOfRule.present
          ? data.isExceptionOfRule.value
          : this.isExceptionOfRule,
      exceptionOriginalId: data.exceptionOriginalId.present
          ? data.exceptionOriginalId.value
          : this.exceptionOriginalId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('isPinned: $isPinned, ')
          ..write('estMin: $estMin, ')
          ..write('actualMin: $actualMin, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('aiConfidence: $aiConfidence, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('isExceptionOfRule: $isExceptionOfRule, ')
          ..write('exceptionOriginalId: $exceptionOriginalId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
  @override
  int get hashCode => Object.hash(
      id,
      title,
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
      createdAt,
      updatedAt,
      completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.deadlineAt == this.deadlineAt &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.isAllDay == this.isAllDay &&
          other.isPinned == this.isPinned &&
          other.estMin == this.estMin &&
          other.actualMin == this.actualMin &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.aiConfidence == this.aiConfidence &&
          other.parentTaskId == this.parentTaskId &&
          other.recurrenceRule == this.recurrenceRule &&
          other.isExceptionOfRule == this.isExceptionOfRule &&
          other.exceptionOriginalId == this.exceptionOriginalId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt);
}
class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> notes;
  final Value<int?> deadlineAt;
  final Value<int?> startAt;
  final Value<int?> endAt;
  final Value<bool> isAllDay;
  final Value<bool> isPinned;
  final Value<int> estMin;
  final Value<int?> actualMin;
  final Value<TaskStatus> status;
  final Value<TaskPriority> priority;
  final Value<double> aiConfidence;
  final Value<String?> parentTaskId;
  final Value<String?> recurrenceRule;
  final Value<bool> isExceptionOfRule;
  final Value<String?> exceptionOriginalId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> completedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.deadlineAt = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.estMin = const Value.absent(),
    this.actualMin = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.aiConfidence = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.isExceptionOfRule = const Value.absent(),
    this.exceptionOriginalId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    this.deadlineAt = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.estMin = const Value.absent(),
    this.actualMin = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.aiConfidence = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.isExceptionOfRule = const Value.absent(),
    this.exceptionOriginalId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? deadlineAt,
    Expression<int>? startAt,
    Expression<int>? endAt,
    Expression<bool>? isAllDay,
    Expression<bool>? isPinned,
    Expression<int>? estMin,
    Expression<int>? actualMin,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<double>? aiConfidence,
    Expression<String>? parentTaskId,
    Expression<String>? recurrenceRule,
    Expression<bool>? isExceptionOfRule,
    Expression<String>? exceptionOriginalId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (deadlineAt != null) 'deadline_at': deadlineAt,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (isPinned != null) 'is_pinned': isPinned,
      if (estMin != null) 'est_min': estMin,
      if (actualMin != null) 'actual_min': actualMin,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (aiConfidence != null) 'ai_confidence': aiConfidence,
      if (parentTaskId != null) 'parent_task_id': parentTaskId,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (isExceptionOfRule != null) 'is_exception_of_rule': isExceptionOfRule,
      if (exceptionOriginalId != null)
        'exception_original_id': exceptionOriginalId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }
  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? notes,
      Value<int?>? deadlineAt,
      Value<int?>? startAt,
      Value<int?>? endAt,
      Value<bool>? isAllDay,
      Value<bool>? isPinned,
      Value<int>? estMin,
      Value<int?>? actualMin,
      Value<TaskStatus>? status,
      Value<TaskPriority>? priority,
      Value<double>? aiConfidence,
      Value<String?>? parentTaskId,
      Value<String?>? recurrenceRule,
      Value<bool>? isExceptionOfRule,
      Value<String?>? exceptionOriginalId,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? completedAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isAllDay: isAllDay ?? this.isAllDay,
      isPinned: isPinned ?? this.isPinned,
      estMin: estMin ?? this.estMin,
      actualMin: actualMin ?? this.actualMin,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      isExceptionOfRule: isExceptionOfRule ?? this.isExceptionOfRule,
      exceptionOriginalId: exceptionOriginalId ?? this.exceptionOriginalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deadlineAt.present) {
      map['deadline_at'] = Variable<int>(deadlineAt.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<int>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<int>(endAt.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (estMin.present) {
      map['est_min'] = Variable<int>(estMin.value);
    }
    if (actualMin.present) {
      map['actual_min'] = Variable<int>(actualMin.value);
    }
    if (status.present) {
      map['status'] =
          Variable<String>($TasksTable.$converterstatus.toSql(status.value));
    }
    if (priority.present) {
      map['priority'] = Variable<String>(
          $TasksTable.$converterpriority.toSql(priority.value));
    }
    if (aiConfidence.present) {
      map['ai_confidence'] = Variable<double>(aiConfidence.value);
    }
    if (parentTaskId.present) {
      map['parent_task_id'] = Variable<String>(parentTaskId.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (isExceptionOfRule.present) {
      map['is_exception_of_rule'] = Variable<bool>(isExceptionOfRule.value);
    }
    if (exceptionOriginalId.present) {
      map['exception_original_id'] =
          Variable<String>(exceptionOriginalId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }
  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('isPinned: $isPinned, ')
          ..write('estMin: $estMin, ')
          ..write('actualMin: $actualMin, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('aiConfidence: $aiConfidence, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('isExceptionOfRule: $isExceptionOfRule, ')
          ..write('exceptionOriginalId: $exceptionOriginalId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
class $TaskTagsTable extends TaskTags with TableInfo<$TaskTagsTable, TaskTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagNameMeta =
      const VerificationMeta('tagName');
  @override
  late final GeneratedColumn<String> tagName = GeneratedColumn<String>(
      'tag_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, taskId, tagName, isPrimary];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_tags';
  @override
  VerificationContext validateIntegrity(Insertable<TaskTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('tag_name')) {
      context.handle(_tagNameMeta,
          tagName.isAcceptableOrUnknown(data['tag_name']!, _tagNameMeta));
    } else if (isInserting) {
      context.missing(_tagNameMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    return context;
  }
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      tagName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_name'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
    );
  }
  @override
  $TaskTagsTable createAlias(String alias) {
    return $TaskTagsTable(attachedDatabase, alias);
  }
}
class TaskTag extends DataClass implements Insertable<TaskTag> {
  final String id;
  final String taskId;
  final String tagName;
  final bool isPrimary;
  const TaskTag(
      {required this.id,
      required this.taskId,
      required this.tagName,
      required this.isPrimary});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['tag_name'] = Variable<String>(tagName);
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }
  TaskTagsCompanion toCompanion(bool nullToAbsent) {
    return TaskTagsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      tagName: Value(tagName),
      isPrimary: Value(isPrimary),
    );
  }
  factory TaskTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTag(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      tagName: serializer.fromJson<String>(json['tagName']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'tagName': serializer.toJson<String>(tagName),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }
  TaskTag copyWith(
          {String? id, String? taskId, String? tagName, bool? isPrimary}) =>
      TaskTag(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        tagName: tagName ?? this.tagName,
        isPrimary: isPrimary ?? this.isPrimary,
      );
  TaskTag copyWithCompanion(TaskTagsCompanion data) {
    return TaskTag(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      tagName: data.tagName.present ? data.tagName.value : this.tagName,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }
  @override
  String toString() {
    return (StringBuffer('TaskTag(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('tagName: $tagName, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }
  @override
  int get hashCode => Object.hash(id, taskId, tagName, isPrimary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTag &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.tagName == this.tagName &&
          other.isPrimary == this.isPrimary);
}
class TaskTagsCompanion extends UpdateCompanion<TaskTag> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> tagName;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const TaskTagsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.tagName = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTagsCompanion.insert({
    required String id,
    required String taskId,
    required String tagName,
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        tagName = Value(tagName);
  static Insertable<TaskTag> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? tagName,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (tagName != null) 'tag_name': tagName,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }
  TaskTagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<String>? tagName,
      Value<bool>? isPrimary,
      Value<int>? rowid}) {
    return TaskTagsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      tagName: tagName ?? this.tagName,
      isPrimary: isPrimary ?? this.isPrimary,
      rowid: rowid ?? this.rowid,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (tagName.present) {
      map['tag_name'] = Variable<String>(tagName.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }
  @override
  String toString() {
    return (StringBuffer('TaskTagsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('tagName: $tagName, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
class $TaskRemindersTable extends TaskReminders
    with TableInfo<$TaskRemindersTable, TaskReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  static const VerificationMeta _remindAtMeta =
      const VerificationMeta('remindAt');
  @override
  late final GeneratedColumn<int> remindAt = GeneratedColumn<int>(
      'remind_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isSentMeta = const VerificationMeta('isSent');
  @override
  late final GeneratedColumn<bool> isSent = GeneratedColumn<bool>(
      'is_sent', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_sent" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, taskId, remindAt, isSent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_reminders';
  @override
  VerificationContext validateIntegrity(Insertable<TaskReminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('remind_at')) {
      context.handle(_remindAtMeta,
          remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta));
    } else if (isInserting) {
      context.missing(_remindAtMeta);
    }
    if (data.containsKey('is_sent')) {
      context.handle(_isSentMeta,
          isSent.isAcceptableOrUnknown(data['is_sent']!, _isSentMeta));
    }
    return context;
  }
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskReminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      remindAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remind_at'])!,
      isSent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_sent'])!,
    );
  }
  @override
  $TaskRemindersTable createAlias(String alias) {
    return $TaskRemindersTable(attachedDatabase, alias);
  }
}
class TaskReminder extends DataClass implements Insertable<TaskReminder> {
  final String id;
  final String taskId;
  final int remindAt;
  final bool isSent;
  const TaskReminder(
      {required this.id,
      required this.taskId,
      required this.remindAt,
      required this.isSent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['remind_at'] = Variable<int>(remindAt);
    map['is_sent'] = Variable<bool>(isSent);
    return map;
  }
  TaskRemindersCompanion toCompanion(bool nullToAbsent) {
    return TaskRemindersCompanion(
      id: Value(id),
      taskId: Value(taskId),
      remindAt: Value(remindAt),
      isSent: Value(isSent),
    );
  }
  factory TaskReminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskReminder(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      remindAt: serializer.fromJson<int>(json['remindAt']),
      isSent: serializer.fromJson<bool>(json['isSent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'remindAt': serializer.toJson<int>(remindAt),
      'isSent': serializer.toJson<bool>(isSent),
    };
  }
  TaskReminder copyWith(
          {String? id, String? taskId, int? remindAt, bool? isSent}) =>
      TaskReminder(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        remindAt: remindAt ?? this.remindAt,
        isSent: isSent ?? this.isSent,
      );
  TaskReminder copyWithCompanion(TaskRemindersCompanion data) {
    return TaskReminder(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      isSent: data.isSent.present ? data.isSent.value : this.isSent,
    );
  }
  @override
  String toString() {
    return (StringBuffer('TaskReminder(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('remindAt: $remindAt, ')
          ..write('isSent: $isSent')
          ..write(')'))
        .toString();
  }
  @override
  int get hashCode => Object.hash(id, taskId, remindAt, isSent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskReminder &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.remindAt == this.remindAt &&
          other.isSent == this.isSent);
}
class TaskRemindersCompanion extends UpdateCompanion<TaskReminder> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<int> remindAt;
  final Value<bool> isSent;
  final Value<int> rowid;
  const TaskRemindersCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.isSent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskRemindersCompanion.insert({
    required String id,
    required String taskId,
    required int remindAt,
    this.isSent = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        remindAt = Value(remindAt);
  static Insertable<TaskReminder> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<int>? remindAt,
    Expression<bool>? isSent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (remindAt != null) 'remind_at': remindAt,
      if (isSent != null) 'is_sent': isSent,
      if (rowid != null) 'rowid': rowid,
    });
  }
  TaskRemindersCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<int>? remindAt,
      Value<bool>? isSent,
      Value<int>? rowid}) {
    return TaskRemindersCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      remindAt: remindAt ?? this.remindAt,
      isSent: isSent ?? this.isSent,
      rowid: rowid ?? this.rowid,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<int>(remindAt.value);
    }
    if (isSent.present) {
      map['is_sent'] = Variable<bool>(isSent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }
  @override
  String toString() {
    return (StringBuffer('TaskRemindersCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('remindAt: $remindAt, ')
          ..write('isSent: $isSent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
class $TaskChecklistItemsTable extends TaskChecklistItems
    with TableInfo<$TaskChecklistItemsTable, TaskChecklistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskChecklistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, taskId, title, isDone, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_checklist_items';
  @override
  VerificationContext validateIntegrity(Insertable<TaskChecklistItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    return context;
  }
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskChecklistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskChecklistItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }
  @override
  $TaskChecklistItemsTable createAlias(String alias) {
    return $TaskChecklistItemsTable(attachedDatabase, alias);
  }
}
class TaskChecklistItem extends DataClass
    implements Insertable<TaskChecklistItem> {
  final String id;
  final String taskId;
  final String title;
  final bool isDone;
  final int orderIndex;
  const TaskChecklistItem(
      {required this.id,
      required this.taskId,
      required this.title,
      required this.isDone,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['is_done'] = Variable<bool>(isDone);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }
  TaskChecklistItemsCompanion toCompanion(bool nullToAbsent) {
    return TaskChecklistItemsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      isDone: Value(isDone),
      orderIndex: Value(orderIndex),
    );
  }
  factory TaskChecklistItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskChecklistItem(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'isDone': serializer.toJson<bool>(isDone),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }
  TaskChecklistItem copyWith(
          {String? id,
          String? taskId,
          String? title,
          bool? isDone,
          int? orderIndex}) =>
      TaskChecklistItem(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  TaskChecklistItem copyWithCompanion(TaskChecklistItemsCompanion data) {
    return TaskChecklistItem(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }
  @override
  String toString() {
    return (StringBuffer('TaskChecklistItem(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isDone: $isDone, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
  @override
  int get hashCode => Object.hash(id, taskId, title, isDone, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskChecklistItem &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.isDone == this.isDone &&
          other.orderIndex == this.orderIndex);
}
class TaskChecklistItemsCompanion extends UpdateCompanion<TaskChecklistItem> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> title;
  final Value<bool> isDone;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const TaskChecklistItemsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.isDone = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskChecklistItemsCompanion.insert({
    required String id,
    required String taskId,
    required String title,
    this.isDone = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        title = Value(title);
  static Insertable<TaskChecklistItem> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<bool>? isDone,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (isDone != null) 'is_done': isDone,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }
  TaskChecklistItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<String>? title,
      Value<bool>? isDone,
      Value<int>? orderIndex,
      Value<int>? rowid}) {
    return TaskChecklistItemsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }
  @override
  String toString() {
    return (StringBuffer('TaskChecklistItemsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isDone: $isDone, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
class $UserCheckinsTable extends UserCheckins
    with TableInfo<$UserCheckinsTable, UserCheckin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _moodScoreMeta =
      const VerificationMeta('moodScore');
  @override
  late final GeneratedColumn<int> moodScore = GeneratedColumn<int>(
      'mood_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productivityMeta =
      const VerificationMeta('productivity');
  @override
  late final GeneratedColumn<int> productivity = GeneratedColumn<int>(
      'productivity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
      'energy', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, moodScore, productivity, energy, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_checkins';
  @override
  VerificationContext validateIntegrity(Insertable<UserCheckin> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('mood_score')) {
      context.handle(_moodScoreMeta,
          moodScore.isAcceptableOrUnknown(data['mood_score']!, _moodScoreMeta));
    } else if (isInserting) {
      context.missing(_moodScoreMeta);
    }
    if (data.containsKey('productivity')) {
      context.handle(
          _productivityMeta,
          productivity.isAcceptableOrUnknown(
              data['productivity']!, _productivityMeta));
    } else if (isInserting) {
      context.missing(_productivityMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(_energyMeta,
          energy.isAcceptableOrUnknown(data['energy']!, _energyMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {date},
      ];
  @override
  UserCheckin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCheckin(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
      moodScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mood_score'])!,
      productivity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}productivity'])!,
      energy: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}energy'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }
  @override
  $UserCheckinsTable createAlias(String alias) {
    return $UserCheckinsTable(attachedDatabase, alias);
  }
}
class UserCheckin extends DataClass implements Insertable<UserCheckin> {
  final String id;
  final int date;
  final int moodScore;
  final int productivity;
  final int energy;
  final String note;
  final int createdAt;
  const UserCheckin(
      {required this.id,
      required this.date,
      required this.moodScore,
      required this.productivity,
      required this.energy,
      required this.note,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<int>(date);
    map['mood_score'] = Variable<int>(moodScore);
    map['productivity'] = Variable<int>(productivity);
    map['energy'] = Variable<int>(energy);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }
  UserCheckinsCompanion toCompanion(bool nullToAbsent) {
    return UserCheckinsCompanion(
      id: Value(id),
      date: Value(date),
      moodScore: Value(moodScore),
      productivity: Value(productivity),
      energy: Value(energy),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }
  factory UserCheckin.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCheckin(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<int>(json['date']),
      moodScore: serializer.fromJson<int>(json['moodScore']),
      productivity: serializer.fromJson<int>(json['productivity']),
      energy: serializer.fromJson<int>(json['energy']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<int>(date),
      'moodScore': serializer.toJson<int>(moodScore),
      'productivity': serializer.toJson<int>(productivity),
      'energy': serializer.toJson<int>(energy),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }
  UserCheckin copyWith(
          {String? id,
          int? date,
          int? moodScore,
          int? productivity,
          int? energy,
          String? note,
          int? createdAt}) =>
      UserCheckin(
        id: id ?? this.id,
        date: date ?? this.date,
        moodScore: moodScore ?? this.moodScore,
        productivity: productivity ?? this.productivity,
        energy: energy ?? this.energy,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );
  UserCheckin copyWithCompanion(UserCheckinsCompanion data) {
    return UserCheckin(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      moodScore: data.moodScore.present ? data.moodScore.value : this.moodScore,
      productivity: data.productivity.present
          ? data.productivity.value
          : this.productivity,
      energy: data.energy.present ? data.energy.value : this.energy,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('UserCheckin(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('moodScore: $moodScore, ')
          ..write('productivity: $productivity, ')
          ..write('energy: $energy, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
  @override
  int get hashCode =>
      Object.hash(id, date, moodScore, productivity, energy, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCheckin &&
          other.id == this.id &&
          other.date == this.date &&
          other.moodScore == this.moodScore &&
          other.productivity == this.productivity &&
          other.energy == this.energy &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}
class UserCheckinsCompanion extends UpdateCompanion<UserCheckin> {
  final Value<String> id;
  final Value<int> date;
  final Value<int> moodScore;
  final Value<int> productivity;
  final Value<int> energy;
  final Value<String> note;
  final Value<int> createdAt;
  final Value<int> rowid;
  const UserCheckinsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.moodScore = const Value.absent(),
    this.productivity = const Value.absent(),
    this.energy = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCheckinsCompanion.insert({
    required String id,
    required int date,
    required int moodScore,
    required int productivity,
    this.energy = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        moodScore = Value(moodScore),
        productivity = Value(productivity),
        createdAt = Value(createdAt);
  static Insertable<UserCheckin> custom({
    Expression<String>? id,
    Expression<int>? date,
    Expression<int>? moodScore,
    Expression<int>? productivity,
    Expression<int>? energy,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (moodScore != null) 'mood_score': moodScore,
      if (productivity != null) 'productivity': productivity,
      if (energy != null) 'energy': energy,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }
  UserCheckinsCompanion copyWith(
      {Value<String>? id,
      Value<int>? date,
      Value<int>? moodScore,
      Value<int>? productivity,
      Value<int>? energy,
      Value<String>? note,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return UserCheckinsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      moodScore: moodScore ?? this.moodScore,
      productivity: productivity ?? this.productivity,
      energy: energy ?? this.energy,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (moodScore.present) {
      map['mood_score'] = Variable<int>(moodScore.value);
    }
    if (productivity.present) {
      map['productivity'] = Variable<int>(productivity.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }
  @override
  String toString() {
    return (StringBuffer('UserCheckinsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('moodScore: $moodScore, ')
          ..write('productivity: $productivity, ')
          ..write('energy: $energy, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
class $AiProfileTable extends AiProfile
    with TableInfo<$AiProfileTable, AiProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('main'));
  static const VerificationMeta _correctionFactorMeta =
      const VerificationMeta('correctionFactor');
  @override
  late final GeneratedColumn<double> correctionFactor = GeneratedColumn<double>(
      'correction_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _avgMoodScoreMeta =
      const VerificationMeta('avgMoodScore');
  @override
  late final GeneratedColumn<double> avgMoodScore = GeneratedColumn<double>(
      'avg_mood_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _peakHoursStartMeta =
      const VerificationMeta('peakHoursStart');
  @override
  late final GeneratedColumn<int> peakHoursStart = GeneratedColumn<int>(
      'peak_hours_start', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(9));
  static const VerificationMeta _peakHoursEndMeta =
      const VerificationMeta('peakHoursEnd');
  @override
  late final GeneratedColumn<int> peakHoursEnd = GeneratedColumn<int>(
      'peak_hours_end', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(12));
  static const VerificationMeta _totalCheckinsMeta =
      const VerificationMeta('totalCheckins');
  @override
  late final GeneratedColumn<int> totalCheckins = GeneratedColumn<int>(
      'total_checkins', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        correctionFactor,
        avgMoodScore,
        peakHoursStart,
        peakHoursEnd,
        totalCheckins,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_profile';
  @override
  VerificationContext validateIntegrity(Insertable<AiProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('correction_factor')) {
      context.handle(
          _correctionFactorMeta,
          correctionFactor.isAcceptableOrUnknown(
              data['correction_factor']!, _correctionFactorMeta));
    }
    if (data.containsKey('avg_mood_score')) {
      context.handle(
          _avgMoodScoreMeta,
          avgMoodScore.isAcceptableOrUnknown(
              data['avg_mood_score']!, _avgMoodScoreMeta));
    }
    if (data.containsKey('peak_hours_start')) {
      context.handle(
          _peakHoursStartMeta,
          peakHoursStart.isAcceptableOrUnknown(
              data['peak_hours_start']!, _peakHoursStartMeta));
    }
    if (data.containsKey('peak_hours_end')) {
      context.handle(
          _peakHoursEndMeta,
          peakHoursEnd.isAcceptableOrUnknown(
              data['peak_hours_end']!, _peakHoursEndMeta));
    }
    if (data.containsKey('total_checkins')) {
      context.handle(
          _totalCheckinsMeta,
          totalCheckins.isAcceptableOrUnknown(
              data['total_checkins']!, _totalCheckinsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      correctionFactor: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}correction_factor'])!,
      avgMoodScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}avg_mood_score'])!,
      peakHoursStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}peak_hours_start'])!,
      peakHoursEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}peak_hours_end'])!,
      totalCheckins: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_checkins'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }
  @override
  $AiProfileTable createAlias(String alias) {
    return $AiProfileTable(attachedDatabase, alias);
  }
}
class AiProfileData extends DataClass implements Insertable<AiProfileData> {
  final String id;
  final double correctionFactor;
  final double avgMoodScore;
  final int peakHoursStart;
  final int peakHoursEnd;
  final int totalCheckins;
  final int updatedAt;
  const AiProfileData(
      {required this.id,
      required this.correctionFactor,
      required this.avgMoodScore,
      required this.peakHoursStart,
      required this.peakHoursEnd,
      required this.totalCheckins,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['correction_factor'] = Variable<double>(correctionFactor);
    map['avg_mood_score'] = Variable<double>(avgMoodScore);
    map['peak_hours_start'] = Variable<int>(peakHoursStart);
    map['peak_hours_end'] = Variable<int>(peakHoursEnd);
    map['total_checkins'] = Variable<int>(totalCheckins);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }
  AiProfileCompanion toCompanion(bool nullToAbsent) {
    return AiProfileCompanion(
      id: Value(id),
      correctionFactor: Value(correctionFactor),
      avgMoodScore: Value(avgMoodScore),
      peakHoursStart: Value(peakHoursStart),
      peakHoursEnd: Value(peakHoursEnd),
      totalCheckins: Value(totalCheckins),
      updatedAt: Value(updatedAt),
    );
  }
  factory AiProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiProfileData(
      id: serializer.fromJson<String>(json['id']),
      correctionFactor: serializer.fromJson<double>(json['correctionFactor']),
      avgMoodScore: serializer.fromJson<double>(json['avgMoodScore']),
      peakHoursStart: serializer.fromJson<int>(json['peakHoursStart']),
      peakHoursEnd: serializer.fromJson<int>(json['peakHoursEnd']),
      totalCheckins: serializer.fromJson<int>(json['totalCheckins']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'correctionFactor': serializer.toJson<double>(correctionFactor),
      'avgMoodScore': serializer.toJson<double>(avgMoodScore),
      'peakHoursStart': serializer.toJson<int>(peakHoursStart),
      'peakHoursEnd': serializer.toJson<int>(peakHoursEnd),
      'totalCheckins': serializer.toJson<int>(totalCheckins),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }
  AiProfileData copyWith(
          {String? id,
          double? correctionFactor,
          double? avgMoodScore,
          int? peakHoursStart,
          int? peakHoursEnd,
          int? totalCheckins,
          int? updatedAt}) =>
      AiProfileData(
        id: id ?? this.id,
        correctionFactor: correctionFactor ?? this.correctionFactor,
        avgMoodScore: avgMoodScore ?? this.avgMoodScore,
        peakHoursStart: peakHoursStart ?? this.peakHoursStart,
        peakHoursEnd: peakHoursEnd ?? this.peakHoursEnd,
        totalCheckins: totalCheckins ?? this.totalCheckins,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AiProfileData copyWithCompanion(AiProfileCompanion data) {
    return AiProfileData(
      id: data.id.present ? data.id.value : this.id,
      correctionFactor: data.correctionFactor.present
          ? data.correctionFactor.value
          : this.correctionFactor,
      avgMoodScore: data.avgMoodScore.present
          ? data.avgMoodScore.value
          : this.avgMoodScore,
      peakHoursStart: data.peakHoursStart.present
          ? data.peakHoursStart.value
          : this.peakHoursStart,
      peakHoursEnd: data.peakHoursEnd.present
          ? data.peakHoursEnd.value
          : this.peakHoursEnd,
      totalCheckins: data.totalCheckins.present
          ? data.totalCheckins.value
          : this.totalCheckins,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }
  @override
  String toString() {
    return (StringBuffer('AiProfileData(')
          ..write('id: $id, ')
          ..write('correctionFactor: $correctionFactor, ')
          ..write('avgMoodScore: $avgMoodScore, ')
          ..write('peakHoursStart: $peakHoursStart, ')
          ..write('peakHoursEnd: $peakHoursEnd, ')
          ..write('totalCheckins: $totalCheckins, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
  @override
  int get hashCode => Object.hash(id, correctionFactor, avgMoodScore,
      peakHoursStart, peakHoursEnd, totalCheckins, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiProfileData &&
          other.id == this.id &&
          other.correctionFactor == this.correctionFactor &&
          other.avgMoodScore == this.avgMoodScore &&
          other.peakHoursStart == this.peakHoursStart &&
          other.peakHoursEnd == this.peakHoursEnd &&
          other.totalCheckins == this.totalCheckins &&
          other.updatedAt == this.updatedAt);
}
class AiProfileCompanion extends UpdateCompanion<AiProfileData> {
  final Value<String> id;
  final Value<double> correctionFactor;
  final Value<double> avgMoodScore;
  final Value<int> peakHoursStart;
  final Value<int> peakHoursEnd;
  final Value<int> totalCheckins;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AiProfileCompanion({
    this.id = const Value.absent(),
    this.correctionFactor = const Value.absent(),
    this.avgMoodScore = const Value.absent(),
    this.peakHoursStart = const Value.absent(),
    this.peakHoursEnd = const Value.absent(),
    this.totalCheckins = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiProfileCompanion.insert({
    this.id = const Value.absent(),
    this.correctionFactor = const Value.absent(),
    this.avgMoodScore = const Value.absent(),
    this.peakHoursStart = const Value.absent(),
    this.peakHoursEnd = const Value.absent(),
    this.totalCheckins = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<AiProfileData> custom({
    Expression<String>? id,
    Expression<double>? correctionFactor,
    Expression<double>? avgMoodScore,
    Expression<int>? peakHoursStart,
    Expression<int>? peakHoursEnd,
    Expression<int>? totalCheckins,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (correctionFactor != null) 'correction_factor': correctionFactor,
      if (avgMoodScore != null) 'avg_mood_score': avgMoodScore,
      if (peakHoursStart != null) 'peak_hours_start': peakHoursStart,
      if (peakHoursEnd != null) 'peak_hours_end': peakHoursEnd,
      if (totalCheckins != null) 'total_checkins': totalCheckins,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }
  AiProfileCompanion copyWith(
      {Value<String>? id,
      Value<double>? correctionFactor,
      Value<double>? avgMoodScore,
      Value<int>? peakHoursStart,
      Value<int>? peakHoursEnd,
      Value<int>? totalCheckins,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return AiProfileCompanion(
      id: id ?? this.id,
      correctionFactor: correctionFactor ?? this.correctionFactor,
      avgMoodScore: avgMoodScore ?? this.avgMoodScore,
      peakHoursStart: peakHoursStart ?? this.peakHoursStart,
      peakHoursEnd: peakHoursEnd ?? this.peakHoursEnd,
      totalCheckins: totalCheckins ?? this.totalCheckins,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (correctionFactor.present) {
      map['correction_factor'] = Variable<double>(correctionFactor.value);
    }
    if (avgMoodScore.present) {
      map['avg_mood_score'] = Variable<double>(avgMoodScore.value);
    }
    if (peakHoursStart.present) {
      map['peak_hours_start'] = Variable<int>(peakHoursStart.value);
    }
    if (peakHoursEnd.present) {
      map['peak_hours_end'] = Variable<int>(peakHoursEnd.value);
    }
    if (totalCheckins.present) {
      map['total_checkins'] = Variable<int>(totalCheckins.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }
  @override
  String toString() {
    return (StringBuffer('AiProfileCompanion(')
          ..write('id: $id, ')
          ..write('correctionFactor: $correctionFactor, ')
          ..write('avgMoodScore: $avgMoodScore, ')
          ..write('peakHoursStart: $peakHoursStart, ')
          ..write('peakHoursEnd: $peakHoursEnd, ')
          ..write('totalCheckins: $totalCheckins, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }
  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }
  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}
class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }
  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }
  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }
  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }
  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}
class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }
  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }
  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskTagsTable taskTags = $TaskTagsTable(this);
  late final $TaskRemindersTable taskReminders = $TaskRemindersTable(this);
  late final $TaskChecklistItemsTable taskChecklistItems =
      $TaskChecklistItemsTable(this);
  late final $UserCheckinsTable userCheckins = $UserCheckinsTable(this);
  late final $AiProfileTable aiProfile = $AiProfileTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  late final TaskTagsDao taskTagsDao = TaskTagsDao(this as AppDatabase);
  late final TaskRemindersDao taskRemindersDao =
      TaskRemindersDao(this as AppDatabase);
  late final ChecklistDao checklistDao = ChecklistDao(this as AppDatabase);
  late final CheckInsDao checkInsDao = CheckInsDao(this as AppDatabase);
  late final AiProfileDao aiProfileDao = AiProfileDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        tasks,
        taskTags,
        taskReminders,
        taskChecklistItems,
        userCheckins,
        aiProfile,
        settings
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task_reminders', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task_checklist_items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String title,
  Value<String> notes,
  Value<int?> deadlineAt,
  Value<int?> startAt,
  Value<int?> endAt,
  Value<bool> isAllDay,
  Value<bool> isPinned,
  Value<int> estMin,
  Value<int?> actualMin,
  Value<TaskStatus> status,
  Value<TaskPriority> priority,
  Value<double> aiConfidence,
  Value<String?> parentTaskId,
  Value<String?> recurrenceRule,
  Value<bool> isExceptionOfRule,
  Value<String?> exceptionOriginalId,
  required int createdAt,
  required int updatedAt,
  Value<int?> completedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> notes,
  Value<int?> deadlineAt,
  Value<int?> startAt,
  Value<int?> endAt,
  Value<bool> isAllDay,
  Value<bool> isPinned,
  Value<int> estMin,
  Value<int?> actualMin,
  Value<TaskStatus> status,
  Value<TaskPriority> priority,
  Value<double> aiConfidence,
  Value<String?> parentTaskId,
  Value<String?> recurrenceRule,
  Value<bool> isExceptionOfRule,
  Value<String?> exceptionOriginalId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> completedAt,
  Value<int> rowid,
});
final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);
  static $TasksTable _parentTaskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('tasks__parent_task_id__tasks__id');
  $$TasksTableProcessedTableManager? get parentTaskId {
    final $_column = $_itemColumn<String>('parent_task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentTaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
  static MultiTypedResultKey<$TaskTagsTable, List<TaskTag>> _taskTagsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.taskTags,
          aliasName: 'tasks__id__task_tags__task_id');
  $$TaskTagsTableProcessedTableManager get taskTagsRefs {
    final manager = $$TaskTagsTableTableManager($_db, $_db.taskTags)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));
    final cache = $_typedResult.readTableOrNull(_taskTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
  static MultiTypedResultKey<$TaskRemindersTable, List<TaskReminder>>
      _taskRemindersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.taskReminders,
              aliasName: 'tasks__id__task_reminders__task_id');
  $$TaskRemindersTableProcessedTableManager get taskRemindersRefs {
    final manager = $$TaskRemindersTableTableManager($_db, $_db.taskReminders)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));
    final cache = $_typedResult.readTableOrNull(_taskRemindersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
  static MultiTypedResultKey<$TaskChecklistItemsTable, List<TaskChecklistItem>>
      _taskChecklistItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.taskChecklistItems,
              aliasName: 'tasks__id__task_checklist_items__task_id');
  $$TaskChecklistItemsTableProcessedTableManager get taskChecklistItemsRefs {
    final manager =
        $$TaskChecklistItemsTableTableManager($_db, $_db.taskChecklistItems)
            .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));
    final cache =
        $_typedResult.readTableOrNull(_taskChecklistItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}
class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get deadlineAt => $composableBuilder(
      column: $table.deadlineAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<bool> get isAllDay => $composableBuilder(
      column: $table.isAllDay, builder: (column) => ColumnFilters(column));
  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get estMin => $composableBuilder(
      column: $table.estMin, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get actualMin => $composableBuilder(
      column: $table.actualMin, builder: (column) => ColumnFilters(column));
  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, String> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));
  ColumnWithTypeConverterFilters<TaskPriority, TaskPriority, String>
      get priority => $composableBuilder(
          column: $table.priority,
          builder: (column) => ColumnWithTypeConverterFilters(column));
  ColumnFilters<double> get aiConfidence => $composableBuilder(
      column: $table.aiConfidence, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule,
      builder: (column) => ColumnFilters(column));
  ColumnFilters<bool> get isExceptionOfRule => $composableBuilder(
      column: $table.isExceptionOfRule,
      builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get exceptionOriginalId => $composableBuilder(
      column: $table.exceptionOriginalId,
      builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
  $$TasksTableFilterComposer get parentTaskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTaskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
  Expression<bool> taskTagsRefs(
      Expression<bool> Function($$TaskTagsTableFilterComposer f) f) {
    final $$TaskTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskTags,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTagsTableFilterComposer(
              $db: $db,
              $table: $db.taskTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
  Expression<bool> taskRemindersRefs(
      Expression<bool> Function($$TaskRemindersTableFilterComposer f) f) {
    final $$TaskRemindersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskReminders,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskRemindersTableFilterComposer(
              $db: $db,
              $table: $db.taskReminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
  Expression<bool> taskChecklistItemsRefs(
      Expression<bool> Function($$TaskChecklistItemsTableFilterComposer f) f) {
    final $$TaskChecklistItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskChecklistItems,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskChecklistItemsTableFilterComposer(
              $db: $db,
              $table: $db.taskChecklistItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}
class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get deadlineAt => $composableBuilder(
      column: $table.deadlineAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<bool> get isAllDay => $composableBuilder(
      column: $table.isAllDay, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get estMin => $composableBuilder(
      column: $table.estMin, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get actualMin => $composableBuilder(
      column: $table.actualMin, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<double> get aiConfidence => $composableBuilder(
      column: $table.aiConfidence,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<bool> get isExceptionOfRule => $composableBuilder(
      column: $table.isExceptionOfRule,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get exceptionOriginalId => $composableBuilder(
      column: $table.exceptionOriginalId,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
  $$TasksTableOrderingComposer get parentTaskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTaskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);
  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
  GeneratedColumn<int> get deadlineAt => $composableBuilder(
      column: $table.deadlineAt, builder: (column) => column);
  GeneratedColumn<int> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);
  GeneratedColumn<int> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);
  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);
  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);
  GeneratedColumn<int> get estMin =>
      $composableBuilder(column: $table.estMin, builder: (column) => column);
  GeneratedColumn<int> get actualMin =>
      $composableBuilder(column: $table.actualMin, builder: (column) => column);
  GeneratedColumnWithTypeConverter<TaskStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
  GeneratedColumnWithTypeConverter<TaskPriority, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);
  GeneratedColumn<double> get aiConfidence => $composableBuilder(
      column: $table.aiConfidence, builder: (column) => column);
  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
      column: $table.recurrenceRule, builder: (column) => column);
  GeneratedColumn<bool> get isExceptionOfRule => $composableBuilder(
      column: $table.isExceptionOfRule, builder: (column) => column);
  GeneratedColumn<String> get exceptionOriginalId => $composableBuilder(
      column: $table.exceptionOriginalId, builder: (column) => column);
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
  $$TasksTableAnnotationComposer get parentTaskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentTaskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
  Expression<T> taskTagsRefs<T extends Object>(
      Expression<T> Function($$TaskTagsTableAnnotationComposer a) f) {
    final $$TaskTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskTags,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.taskTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
  Expression<T> taskRemindersRefs<T extends Object>(
      Expression<T> Function($$TaskRemindersTableAnnotationComposer a) f) {
    final $$TaskRemindersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskReminders,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskRemindersTableAnnotationComposer(
              $db: $db,
              $table: $db.taskReminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
  Expression<T> taskChecklistItemsRefs<T extends Object>(
      Expression<T> Function($$TaskChecklistItemsTableAnnotationComposer a) f) {
    final $$TaskChecklistItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.taskChecklistItems,
            getReferencedColumn: (t) => t.taskId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TaskChecklistItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.taskChecklistItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}
class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function(
        {bool parentTaskId,
        bool taskTagsRefs,
        bool taskRemindersRefs,
        bool taskChecklistItemsRefs})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<int?> deadlineAt = const Value.absent(),
            Value<int?> startAt = const Value.absent(),
            Value<int?> endAt = const Value.absent(),
            Value<bool> isAllDay = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<int> estMin = const Value.absent(),
            Value<int?> actualMin = const Value.absent(),
            Value<TaskStatus> status = const Value.absent(),
            Value<TaskPriority> priority = const Value.absent(),
            Value<double> aiConfidence = const Value.absent(),
            Value<String?> parentTaskId = const Value.absent(),
            Value<String?> recurrenceRule = const Value.absent(),
            Value<bool> isExceptionOfRule = const Value.absent(),
            Value<String?> exceptionOriginalId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            title: title,
            notes: notes,
            deadlineAt: deadlineAt,
            startAt: startAt,
            endAt: endAt,
            isAllDay: isAllDay,
            isPinned: isPinned,
            estMin: estMin,
            actualMin: actualMin,
            status: status,
            priority: priority,
            aiConfidence: aiConfidence,
            parentTaskId: parentTaskId,
            recurrenceRule: recurrenceRule,
            isExceptionOfRule: isExceptionOfRule,
            exceptionOriginalId: exceptionOriginalId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> notes = const Value.absent(),
            Value<int?> deadlineAt = const Value.absent(),
            Value<int?> startAt = const Value.absent(),
            Value<int?> endAt = const Value.absent(),
            Value<bool> isAllDay = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<int> estMin = const Value.absent(),
            Value<int?> actualMin = const Value.absent(),
            Value<TaskStatus> status = const Value.absent(),
            Value<TaskPriority> priority = const Value.absent(),
            Value<double> aiConfidence = const Value.absent(),
            Value<String?> parentTaskId = const Value.absent(),
            Value<String?> recurrenceRule = const Value.absent(),
            Value<bool> isExceptionOfRule = const Value.absent(),
            Value<String?> exceptionOriginalId = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            title: title,
            notes: notes,
            deadlineAt: deadlineAt,
            startAt: startAt,
            endAt: endAt,
            isAllDay: isAllDay,
            isPinned: isPinned,
            estMin: estMin,
            actualMin: actualMin,
            status: status,
            priority: priority,
            aiConfidence: aiConfidence,
            parentTaskId: parentTaskId,
            recurrenceRule: recurrenceRule,
            isExceptionOfRule: isExceptionOfRule,
            exceptionOriginalId: exceptionOriginalId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {parentTaskId = false,
              taskTagsRefs = false,
              taskRemindersRefs = false,
              taskChecklistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (taskTagsRefs) db.taskTags,
                if (taskRemindersRefs) db.taskReminders,
                if (taskChecklistItemsRefs) db.taskChecklistItems
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (parentTaskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentTaskId,
                    referencedTable:
                        $$TasksTableReferences._parentTaskIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._parentTaskIdTable(db).id,
                  ) as T;
                }
                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskTagsRefs)
                    await $_getPrefetchedData<Task, $TasksTable, TaskTag>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._taskTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).taskTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (taskRemindersRefs)
                    await $_getPrefetchedData<Task, $TasksTable, TaskReminder>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._taskRemindersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .taskRemindersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (taskChecklistItemsRefs)
                    await $_getPrefetchedData<Task, $TasksTable,
                            TaskChecklistItem>(
                        currentTable: table,
                        referencedTable: $$TasksTableReferences
                            ._taskChecklistItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .taskChecklistItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}
typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function(
        {bool parentTaskId,
        bool taskTagsRefs,
        bool taskRemindersRefs,
        bool taskChecklistItemsRefs})>;
typedef $$TaskTagsTableCreateCompanionBuilder = TaskTagsCompanion Function({
  required String id,
  required String taskId,
  required String tagName,
  Value<bool> isPrimary,
  Value<int> rowid,
});
typedef $$TaskTagsTableUpdateCompanionBuilder = TaskTagsCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<String> tagName,
  Value<bool> isPrimary,
  Value<int> rowid,
});
final class $$TaskTagsTableReferences
    extends BaseReferences<_$AppDatabase, $TaskTagsTable, TaskTag> {
  $$TaskTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);
  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_tags__task_id__tasks__id');
  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}
class $$TaskTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get tagName => $composableBuilder(
      column: $table.tagName, builder: (column) => ColumnFilters(column));
  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));
  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TaskTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get tagName => $composableBuilder(
      column: $table.tagName, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));
  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TaskTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn<String> get tagName =>
      $composableBuilder(column: $table.tagName, builder: (column) => column);
  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);
  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TaskTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskTagsTable,
    TaskTag,
    $$TaskTagsTableFilterComposer,
    $$TaskTagsTableOrderingComposer,
    $$TaskTagsTableAnnotationComposer,
    $$TaskTagsTableCreateCompanionBuilder,
    $$TaskTagsTableUpdateCompanionBuilder,
    (TaskTag, $$TaskTagsTableReferences),
    TaskTag,
    PrefetchHooks Function({bool taskId})> {
  $$TaskTagsTableTableManager(_$AppDatabase db, $TaskTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<String> tagName = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTagsCompanion(
            id: id,
            taskId: taskId,
            tagName: tagName,
            isPrimary: isPrimary,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required String tagName,
            Value<bool> isPrimary = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTagsCompanion.insert(
            id: id,
            taskId: taskId,
            tagName: tagName,
            isPrimary: isPrimary,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TaskTagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable: $$TaskTagsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TaskTagsTableReferences._taskIdTable(db).id,
                  ) as T;
                }
                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}
typedef $$TaskTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskTagsTable,
    TaskTag,
    $$TaskTagsTableFilterComposer,
    $$TaskTagsTableOrderingComposer,
    $$TaskTagsTableAnnotationComposer,
    $$TaskTagsTableCreateCompanionBuilder,
    $$TaskTagsTableUpdateCompanionBuilder,
    (TaskTag, $$TaskTagsTableReferences),
    TaskTag,
    PrefetchHooks Function({bool taskId})>;
typedef $$TaskRemindersTableCreateCompanionBuilder = TaskRemindersCompanion
    Function({
  required String id,
  required String taskId,
  required int remindAt,
  Value<bool> isSent,
  Value<int> rowid,
});
typedef $$TaskRemindersTableUpdateCompanionBuilder = TaskRemindersCompanion
    Function({
  Value<String> id,
  Value<String> taskId,
  Value<int> remindAt,
  Value<bool> isSent,
  Value<int> rowid,
});
final class $$TaskRemindersTableReferences
    extends BaseReferences<_$AppDatabase, $TaskRemindersTable, TaskReminder> {
  $$TaskRemindersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);
  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_reminders__task_id__tasks__id');
  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}
class $$TaskRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $TaskRemindersTable> {
  $$TaskRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get remindAt => $composableBuilder(
      column: $table.remindAt, builder: (column) => ColumnFilters(column));
  ColumnFilters<bool> get isSent => $composableBuilder(
      column: $table.isSent, builder: (column) => ColumnFilters(column));
  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TaskRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskRemindersTable> {
  $$TaskRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get remindAt => $composableBuilder(
      column: $table.remindAt, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<bool> get isSent => $composableBuilder(
      column: $table.isSent, builder: (column) => ColumnOrderings(column));
  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TaskRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskRemindersTable> {
  $$TaskRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn<int> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);
  GeneratedColumn<bool> get isSent =>
      $composableBuilder(column: $table.isSent, builder: (column) => column);
  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TaskRemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskRemindersTable,
    TaskReminder,
    $$TaskRemindersTableFilterComposer,
    $$TaskRemindersTableOrderingComposer,
    $$TaskRemindersTableAnnotationComposer,
    $$TaskRemindersTableCreateCompanionBuilder,
    $$TaskRemindersTableUpdateCompanionBuilder,
    (TaskReminder, $$TaskRemindersTableReferences),
    TaskReminder,
    PrefetchHooks Function({bool taskId})> {
  $$TaskRemindersTableTableManager(_$AppDatabase db, $TaskRemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<int> remindAt = const Value.absent(),
            Value<bool> isSent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskRemindersCompanion(
            id: id,
            taskId: taskId,
            remindAt: remindAt,
            isSent: isSent,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required int remindAt,
            Value<bool> isSent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskRemindersCompanion.insert(
            id: id,
            taskId: taskId,
            remindAt: remindAt,
            isSent: isSent,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TaskRemindersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$TaskRemindersTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TaskRemindersTableReferences._taskIdTable(db).id,
                  ) as T;
                }
                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}
typedef $$TaskRemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskRemindersTable,
    TaskReminder,
    $$TaskRemindersTableFilterComposer,
    $$TaskRemindersTableOrderingComposer,
    $$TaskRemindersTableAnnotationComposer,
    $$TaskRemindersTableCreateCompanionBuilder,
    $$TaskRemindersTableUpdateCompanionBuilder,
    (TaskReminder, $$TaskRemindersTableReferences),
    TaskReminder,
    PrefetchHooks Function({bool taskId})>;
typedef $$TaskChecklistItemsTableCreateCompanionBuilder
    = TaskChecklistItemsCompanion Function({
  required String id,
  required String taskId,
  required String title,
  Value<bool> isDone,
  Value<int> orderIndex,
  Value<int> rowid,
});
typedef $$TaskChecklistItemsTableUpdateCompanionBuilder
    = TaskChecklistItemsCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<String> title,
  Value<bool> isDone,
  Value<int> orderIndex,
  Value<int> rowid,
});
final class $$TaskChecklistItemsTableReferences extends BaseReferences<
    _$AppDatabase, $TaskChecklistItemsTable, TaskChecklistItem> {
  $$TaskChecklistItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);
  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_checklist_items__task_id__tasks__id');
  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}
class $$TaskChecklistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskChecklistItemsTable> {
  $$TaskChecklistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));
  ColumnFilters<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));
  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TaskChecklistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskChecklistItemsTable> {
  $$TaskChecklistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));
  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TaskChecklistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskChecklistItemsTable> {
  $$TaskChecklistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);
  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);
  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);
  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}
class $$TaskChecklistItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskChecklistItemsTable,
    TaskChecklistItem,
    $$TaskChecklistItemsTableFilterComposer,
    $$TaskChecklistItemsTableOrderingComposer,
    $$TaskChecklistItemsTableAnnotationComposer,
    $$TaskChecklistItemsTableCreateCompanionBuilder,
    $$TaskChecklistItemsTableUpdateCompanionBuilder,
    (TaskChecklistItem, $$TaskChecklistItemsTableReferences),
    TaskChecklistItem,
    PrefetchHooks Function({bool taskId})> {
  $$TaskChecklistItemsTableTableManager(
      _$AppDatabase db, $TaskChecklistItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskChecklistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskChecklistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskChecklistItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskChecklistItemsCompanion(
            id: id,
            taskId: taskId,
            title: title,
            isDone: isDone,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required String title,
            Value<bool> isDone = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskChecklistItemsCompanion.insert(
            id: id,
            taskId: taskId,
            title: title,
            isDone: isDone,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TaskChecklistItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$TaskChecklistItemsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TaskChecklistItemsTableReferences._taskIdTable(db).id,
                  ) as T;
                }
                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}
typedef $$TaskChecklistItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskChecklistItemsTable,
    TaskChecklistItem,
    $$TaskChecklistItemsTableFilterComposer,
    $$TaskChecklistItemsTableOrderingComposer,
    $$TaskChecklistItemsTableAnnotationComposer,
    $$TaskChecklistItemsTableCreateCompanionBuilder,
    $$TaskChecklistItemsTableUpdateCompanionBuilder,
    (TaskChecklistItem, $$TaskChecklistItemsTableReferences),
    TaskChecklistItem,
    PrefetchHooks Function({bool taskId})>;
typedef $$UserCheckinsTableCreateCompanionBuilder = UserCheckinsCompanion
    Function({
  required String id,
  required int date,
  required int moodScore,
  required int productivity,
  Value<int> energy,
  Value<String> note,
  required int createdAt,
  Value<int> rowid,
});
typedef $$UserCheckinsTableUpdateCompanionBuilder = UserCheckinsCompanion
    Function({
  Value<String> id,
  Value<int> date,
  Value<int> moodScore,
  Value<int> productivity,
  Value<int> energy,
  Value<String> note,
  Value<int> createdAt,
  Value<int> rowid,
});
class $$UserCheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $UserCheckinsTable> {
  $$UserCheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get moodScore => $composableBuilder(
      column: $table.moodScore, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get productivity => $composableBuilder(
      column: $table.productivity, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get energy => $composableBuilder(
      column: $table.energy, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}
class $$UserCheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCheckinsTable> {
  $$UserCheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get moodScore => $composableBuilder(
      column: $table.moodScore, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get productivity => $composableBuilder(
      column: $table.productivity,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get energy => $composableBuilder(
      column: $table.energy, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}
class $$UserCheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCheckinsTable> {
  $$UserCheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
  GeneratedColumn<int> get moodScore =>
      $composableBuilder(column: $table.moodScore, builder: (column) => column);
  GeneratedColumn<int> get productivity => $composableBuilder(
      column: $table.productivity, builder: (column) => column);
  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);
  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}
class $$UserCheckinsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserCheckinsTable,
    UserCheckin,
    $$UserCheckinsTableFilterComposer,
    $$UserCheckinsTableOrderingComposer,
    $$UserCheckinsTableAnnotationComposer,
    $$UserCheckinsTableCreateCompanionBuilder,
    $$UserCheckinsTableUpdateCompanionBuilder,
    (
      UserCheckin,
      BaseReferences<_$AppDatabase, $UserCheckinsTable, UserCheckin>
    ),
    UserCheckin,
    PrefetchHooks Function()> {
  $$UserCheckinsTableTableManager(_$AppDatabase db, $UserCheckinsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> date = const Value.absent(),
            Value<int> moodScore = const Value.absent(),
            Value<int> productivity = const Value.absent(),
            Value<int> energy = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserCheckinsCompanion(
            id: id,
            date: date,
            moodScore: moodScore,
            productivity: productivity,
            energy: energy,
            note: note,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int date,
            required int moodScore,
            required int productivity,
            Value<int> energy = const Value.absent(),
            Value<String> note = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserCheckinsCompanion.insert(
            id: id,
            date: date,
            moodScore: moodScore,
            productivity: productivity,
            energy: energy,
            note: note,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}
typedef $$UserCheckinsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserCheckinsTable,
    UserCheckin,
    $$UserCheckinsTableFilterComposer,
    $$UserCheckinsTableOrderingComposer,
    $$UserCheckinsTableAnnotationComposer,
    $$UserCheckinsTableCreateCompanionBuilder,
    $$UserCheckinsTableUpdateCompanionBuilder,
    (
      UserCheckin,
      BaseReferences<_$AppDatabase, $UserCheckinsTable, UserCheckin>
    ),
    UserCheckin,
    PrefetchHooks Function()>;
typedef $$AiProfileTableCreateCompanionBuilder = AiProfileCompanion Function({
  Value<String> id,
  Value<double> correctionFactor,
  Value<double> avgMoodScore,
  Value<int> peakHoursStart,
  Value<int> peakHoursEnd,
  Value<int> totalCheckins,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$AiProfileTableUpdateCompanionBuilder = AiProfileCompanion Function({
  Value<String> id,
  Value<double> correctionFactor,
  Value<double> avgMoodScore,
  Value<int> peakHoursStart,
  Value<int> peakHoursEnd,
  Value<int> totalCheckins,
  Value<int> updatedAt,
  Value<int> rowid,
});
class $$AiProfileTableFilterComposer
    extends Composer<_$AppDatabase, $AiProfileTable> {
  $$AiProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));
  ColumnFilters<double> get correctionFactor => $composableBuilder(
      column: $table.correctionFactor,
      builder: (column) => ColumnFilters(column));
  ColumnFilters<double> get avgMoodScore => $composableBuilder(
      column: $table.avgMoodScore, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get peakHoursStart => $composableBuilder(
      column: $table.peakHoursStart,
      builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get peakHoursEnd => $composableBuilder(
      column: $table.peakHoursEnd, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get totalCheckins => $composableBuilder(
      column: $table.totalCheckins, builder: (column) => ColumnFilters(column));
  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}
class $$AiProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $AiProfileTable> {
  $$AiProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<double> get correctionFactor => $composableBuilder(
      column: $table.correctionFactor,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<double> get avgMoodScore => $composableBuilder(
      column: $table.avgMoodScore,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get peakHoursStart => $composableBuilder(
      column: $table.peakHoursStart,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get peakHoursEnd => $composableBuilder(
      column: $table.peakHoursEnd,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get totalCheckins => $composableBuilder(
      column: $table.totalCheckins,
      builder: (column) => ColumnOrderings(column));
  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}
class $$AiProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiProfileTable> {
  $$AiProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
  GeneratedColumn<double> get correctionFactor => $composableBuilder(
      column: $table.correctionFactor, builder: (column) => column);
  GeneratedColumn<double> get avgMoodScore => $composableBuilder(
      column: $table.avgMoodScore, builder: (column) => column);
  GeneratedColumn<int> get peakHoursStart => $composableBuilder(
      column: $table.peakHoursStart, builder: (column) => column);
  GeneratedColumn<int> get peakHoursEnd => $composableBuilder(
      column: $table.peakHoursEnd, builder: (column) => column);
  GeneratedColumn<int> get totalCheckins => $composableBuilder(
      column: $table.totalCheckins, builder: (column) => column);
  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}
class $$AiProfileTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiProfileTable,
    AiProfileData,
    $$AiProfileTableFilterComposer,
    $$AiProfileTableOrderingComposer,
    $$AiProfileTableAnnotationComposer,
    $$AiProfileTableCreateCompanionBuilder,
    $$AiProfileTableUpdateCompanionBuilder,
    (
      AiProfileData,
      BaseReferences<_$AppDatabase, $AiProfileTable, AiProfileData>
    ),
    AiProfileData,
    PrefetchHooks Function()> {
  $$AiProfileTableTableManager(_$AppDatabase db, $AiProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double> correctionFactor = const Value.absent(),
            Value<double> avgMoodScore = const Value.absent(),
            Value<int> peakHoursStart = const Value.absent(),
            Value<int> peakHoursEnd = const Value.absent(),
            Value<int> totalCheckins = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiProfileCompanion(
            id: id,
            correctionFactor: correctionFactor,
            avgMoodScore: avgMoodScore,
            peakHoursStart: peakHoursStart,
            peakHoursEnd: peakHoursEnd,
            totalCheckins: totalCheckins,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double> correctionFactor = const Value.absent(),
            Value<double> avgMoodScore = const Value.absent(),
            Value<int> peakHoursStart = const Value.absent(),
            Value<int> peakHoursEnd = const Value.absent(),
            Value<int> totalCheckins = const Value.absent(),
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AiProfileCompanion.insert(
            id: id,
            correctionFactor: correctionFactor,
            avgMoodScore: avgMoodScore,
            peakHoursStart: peakHoursStart,
            peakHoursEnd: peakHoursEnd,
            totalCheckins: totalCheckins,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}
typedef $$AiProfileTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiProfileTable,
    AiProfileData,
    $$AiProfileTableFilterComposer,
    $$AiProfileTableOrderingComposer,
    $$AiProfileTableAnnotationComposer,
    $$AiProfileTableCreateCompanionBuilder,
    $$AiProfileTableUpdateCompanionBuilder,
    (
      AiProfileData,
      BaseReferences<_$AppDatabase, $AiProfileTable, AiProfileData>
    ),
    AiProfileData,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});
class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));
  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}
class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));
  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}
class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);
  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}
class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}
typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskTagsTableTableManager get taskTags =>
      $$TaskTagsTableTableManager(_db, _db.taskTags);
  $$TaskRemindersTableTableManager get taskReminders =>
      $$TaskRemindersTableTableManager(_db, _db.taskReminders);
  $$TaskChecklistItemsTableTableManager get taskChecklistItems =>
      $$TaskChecklistItemsTableTableManager(_db, _db.taskChecklistItems);
  $$UserCheckinsTableTableManager get userCheckins =>
      $$UserCheckinsTableTableManager(_db, _db.userCheckins);
  $$AiProfileTableTableManager get aiProfile =>
      $$AiProfileTableTableManager(_db, _db.aiProfile);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}

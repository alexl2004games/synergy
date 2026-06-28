import 'package:drift/drift.dart';
enum TaskStatus {
  pending,
  inProgress,
  completed,
  overdue,
  cancelled,
}
enum TaskPriority {
  low,
  medium,
  high,
}
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get deadlineAt => integer().nullable()();
  IntColumn get startAt => integer().nullable()();
  IntColumn get endAt => integer().nullable()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get estMin => integer().withDefault(const Constant(30))();
  IntColumn get actualMin => integer().nullable()();
  TextColumn get status =>
      textEnum<TaskStatus>().withDefault(const Constant('pending'))();
  TextColumn get priority =>
      textEnum<TaskPriority>().withDefault(const Constant('medium'))();
  RealColumn get aiConfidence => real().withDefault(const Constant(1.0))();
  TextColumn get parentTaskId => text().nullable().references(Tasks, #id)();
  TextColumn get recurrenceRule => text().nullable()();
  BoolColumn get isExceptionOfRule =>
      boolean().withDefault(const Constant(false))();
  TextColumn get exceptionOriginalId => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}
class TaskTags extends Table {
  TextColumn get id => text()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagName => text()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}
class TaskReminders extends Table {
  TextColumn get id => text()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get remindAt => integer()();
  BoolColumn get isSent => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}
class TaskChecklistItems extends Table {
  TextColumn get id => text()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}
class UserCheckins extends Table {
  TextColumn get id => text()();
  IntColumn get date => integer()();
  IntColumn get moodScore => integer()();
  IntColumn get productivity => integer()();
  IntColumn get energy => integer().withDefault(const Constant(3))();
  TextColumn get note => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer()();
  @override
  List<Set<Column>> get uniqueKeys => [
        {date},
      ];
  @override
  Set<Column> get primaryKey => {id};
}
class AiProfile extends Table {
  TextColumn get id => text().withDefault(const Constant('main'))();
  RealColumn get correctionFactor => real().withDefault(const Constant(1.0))();
  RealColumn get avgMoodScore => real().withDefault(const Constant(0.0))();
  IntColumn get peakHoursStart => integer().withDefault(const Constant(9))();
  IntColumn get peakHoursEnd => integer().withDefault(const Constant(12))();
  IntColumn get totalCheckins => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

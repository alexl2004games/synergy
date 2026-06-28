import 'package:path/path.dart' as p;
class BackupSnapshot {
  const BackupSnapshot({
    required this.filePath,
    required this.timestamp,
  });
  final String filePath;
  final int timestamp;
  String get fileName => p.basename(filePath);
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}

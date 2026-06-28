import 'package:freezed_annotation/freezed_annotation.dart';
part 'setting_entry.freezed.dart';
@freezed
abstract class SettingEntry with _$SettingEntry {
  const factory SettingEntry({
    required String key,
    required String value,
  }) = _SettingEntry;
}

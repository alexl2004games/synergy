import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'morning_proposal_notifier.dart';
class TaskSchedulingRefreshTrigger {
  TaskSchedulingRefreshTrigger(
    this._ref, {
    Duration debounce = const Duration(milliseconds: 600),
    DateTime Function()? now,
  })  : _debounce = debounce,
        _now = now ?? DateTime.now;
  final Ref _ref;
  final Duration _debounce;
  final DateTime Function() _now;
  Timer? _timer;
  bool _isRunning = false;
  bool _pending = false;
  void schedule() {
    _pending = true;
    _timer?.cancel();
    _timer = Timer(_debounce, _runIfNeeded);
  }
  Future<void> runNow() async {
    _pending = true;
    _timer?.cancel();
    await _runIfNeeded(force: true);
  }
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
  Future<void> _runIfNeeded({bool force = false}) async {
    if (_isRunning) {
      _pending = true;
      return;
    }
    if (!force && !_pending) {
      return;
    }
    _timer?.cancel();
    _timer = null;
    _isRunning = true;
    _pending = false;
    try {
      await _ref.read(morningProposalProvider.notifier).recalculate(_now());
    } finally {
      _isRunning = false;
      if (_pending) {
        schedule();
      }
    }
  }
}
final taskSchedulingRefreshTriggerProvider =
    Provider<TaskSchedulingRefreshTrigger>((ref) {
  final trigger = TaskSchedulingRefreshTrigger(ref);
  ref.onDispose(trigger.dispose);
  return trigger;
});

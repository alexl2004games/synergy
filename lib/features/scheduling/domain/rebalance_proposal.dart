import '../../../core/database/app_database.dart';
import 'reschedule_proposal.dart';
class RebalanceProposal {
  const RebalanceProposal({
    required this.moveOut,
    required this.totalLoad,
    required this.availableTime,
    this.day,
    this.keptTasks = const <Task>[],
    this.overflowTasks = const <Task>[],
    this.totalEstimatedMinutes = 0,
    this.workWindowMinutes = 0,
  });
  final List<RescheduleProposal> moveOut;
  final Duration totalLoad;
  final Duration availableTime;
  final DateTime? day;
  final List<Task> keptTasks;
  final List<Task> overflowTasks;
  final int totalEstimatedMinutes;
  final int workWindowMinutes;
  bool get isOverloaded => totalEstimatedMinutes > workWindowMinutes;
  int get overflowMinutes {
    final overflow = totalEstimatedMinutes - workWindowMinutes;
    if (overflow <= 0) {
      return 0;
    }
    return overflow;
  }
}

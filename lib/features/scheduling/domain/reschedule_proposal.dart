import '../../../core/database/app_database.dart';
import 'time_slot.dart';
class RescheduleProposal {
  const RescheduleProposal({
    required this.task,
    required this.proposedSlot,
    required this.reason,
  });
  final Task task;
  final TimeSlot? proposedSlot;
  final String reason;
  bool get requiresManualReview => proposedSlot == null;
}

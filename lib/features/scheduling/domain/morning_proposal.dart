import 'rebalance_proposal.dart';
import 'reschedule_proposal.dart';
class MorningProposal {
  const MorningProposal({
    required this.overdueProposals,
    this.todayBalance,
    this.tomorrowBalance,
  });
  final List<RescheduleProposal> overdueProposals;
  final RebalanceProposal? todayBalance;
  final RebalanceProposal? tomorrowBalance;
  bool get hasAnything =>
      overdueProposals.isNotEmpty ||
      todayBalance != null ||
      tomorrowBalance != null;
  int get totalProposalCount =>
      overdueProposals.length +
      (todayBalance?.moveOut.length ?? 0) +
      (tomorrowBalance?.moveOut.length ?? 0);
}

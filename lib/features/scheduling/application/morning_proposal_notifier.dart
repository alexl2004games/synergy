import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../domain/morning_proposal.dart';
import 'morning_recalculator_provider.dart';
class MorningProposalNotifier
    extends StateNotifier<AsyncValue<MorningProposal?>> {
  MorningProposalNotifier({
    required this.ref,
  }) : super(const AsyncValue.data(null));
  final Ref ref;
  Future<void> recalculate(DateTime today) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final calculator = ref.read(morningRecalculatorProvider);
      return calculator.recalculate(today);
    });
  }
  Future<void> apply(MorningProposal proposal, DateTime today) async {
    final calculator = ref.read(morningRecalculatorProvider);
    await calculator.applyProposal(proposal, today);
    state = const AsyncValue.data(null);
  }
  void dismiss() {
    state = const AsyncValue.data(null);
  }
}
final morningProposalProvider = StateNotifierProvider<MorningProposalNotifier,
    AsyncValue<MorningProposal?>>(
  (ref) => MorningProposalNotifier(ref: ref),
);

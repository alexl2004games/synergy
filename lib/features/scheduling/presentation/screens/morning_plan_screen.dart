import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/morning_proposal.dart';
import '../../domain/rebalance_proposal.dart';
import '../../domain/time_slot.dart';
class MorningPlanScreen extends ConsumerStatefulWidget {
  const MorningPlanScreen({
    required this.proposal,
    required this.onAcceptAll,
    required this.onCustomize,
    super.key,
  });
  final MorningProposal proposal;
  final VoidCallback onAcceptAll;
  final VoidCallback onCustomize;
  @override
  ConsumerState<MorningPlanScreen> createState() => _MorningPlanScreenState();
}
class _MorningPlanScreenState extends ConsumerState<MorningPlanScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.morningPlanTitle),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.proposal.overdueProposals.isNotEmpty)
                _buildOverdueSection(loc, theme),
              if (widget.proposal.todayBalance != null &&
                  widget.proposal.todayBalance!.isOverloaded)
                _buildRebalanceSection(
                  loc,
                  theme,
                  loc.morningTodayOverloadedTitle,
                  widget.proposal.todayBalance!,
                ),
              if (widget.proposal.tomorrowBalance != null &&
                  widget.proposal.tomorrowBalance!.isOverloaded)
                _buildRebalanceSection(
                  loc,
                  theme,
                  loc.morningTomorrowOverloadedTitle,
                  widget.proposal.tomorrowBalance!,
                ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCustomize,
                    child: Text(loc.morningCustomizeButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: widget.onAcceptAll,
                    child: Text(loc.morningAcceptAllButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildOverdueSection(AppLocalizations loc, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            loc.morningOverdueTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...widget.proposal.overdueProposals.map((proposal) {
          return _buildProposalTile(
            loc,
            theme,
            proposal.task,
            proposal.proposedSlot,
          );
        }),
      ],
    );
  }
  Widget _buildRebalanceSection(
    AppLocalizations loc,
    ThemeData theme,
    String title,
    RebalanceProposal balance,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${balance.overflowMinutes} ${loc.morningMinutes}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        ...balance.moveOut.map((proposal) {
          return _buildProposalTile(
            loc,
            theme,
            proposal.task,
            proposal.proposedSlot,
          );
        }),
      ],
    );
  }
  Widget _buildProposalTile(
    AppLocalizations loc,
    ThemeData theme,
    Task task,
    TimeSlot? slot,
  ) {
    final slotText = slot != null
        ? '${_formatTime(slot.startAt)} – ${_formatTime(slot.endAt)}'
        : loc.morningNoSlotFound;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                slotText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/morning_proposal.dart';
import '../../domain/rebalance_proposal.dart';
import '../../domain/time_slot.dart';
class MorningSettingsScreen extends ConsumerStatefulWidget {
  const MorningSettingsScreen({
    required this.proposal,
    required this.onApply,
    super.key,
  });
  final MorningProposal proposal;
  final void Function(MorningProposal) onApply;
  @override
  ConsumerState<MorningSettingsScreen> createState() =>
      _MorningSettingsScreenState();
}
class _MorningSettingsScreenState extends ConsumerState<MorningSettingsScreen> {
  late Map<int, bool> _selectedProposals;
  @override
  void initState() {
    super.initState();
    _selectedProposals = {};
    _initializeSelections();
  }
  void _initializeSelections() {
    var index = 0;
    for (final _ in widget.proposal.overdueProposals) {
      _selectedProposals[index++] = true;
    }
    if (widget.proposal.todayBalance != null) {
      for (final _ in widget.proposal.todayBalance!.moveOut) {
        _selectedProposals[index++] = true;
      }
    }
    if (widget.proposal.tomorrowBalance != null) {
      for (final _ in widget.proposal.tomorrowBalance!.moveOut) {
        _selectedProposals[index++] = true;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.morningCustomizeTitle),
      ),
      body: ListView(
        children: [
          if (widget.proposal.overdueProposals.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                loc.morningOverdueTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._buildOverdueProposals(),
          ],
          if (widget.proposal.todayBalance != null &&
              widget.proposal.todayBalance!.isOverloaded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                loc.morningTodayOverloadedTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._buildRebalanceProposals(
              widget.proposal.todayBalance!,
              widget.proposal.overdueProposals.length,
            ),
          ],
          if (widget.proposal.tomorrowBalance != null &&
              widget.proposal.tomorrowBalance!.isOverloaded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                loc.morningTomorrowOverloadedTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._buildRebalanceProposals(
              widget.proposal.tomorrowBalance!,
              widget.proposal.overdueProposals.length +
                  (widget.proposal.todayBalance?.moveOut.length ?? 0),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _applySelected,
            child: Text(loc.morningApplyButton),
          ),
        ),
      ),
    );
  }
  List<Widget> _buildOverdueProposals() {
    return widget.proposal.overdueProposals.asMap().entries.map((entry) {
      final index = entry.key;
      final proposal = entry.value;
      return _buildProposalCheckbox(
        index,
        proposal.task,
        proposal.proposedSlot,
      );
    }).toList();
  }
  List<Widget> _buildRebalanceProposals(RebalanceProposal balance, int offset) {
    return balance.moveOut.asMap().entries.map((entry) {
      final index = offset + entry.key;
      final proposal = entry.value;
      return _buildProposalCheckbox(
        index,
        proposal.task,
        proposal.proposedSlot,
      );
    }).toList();
  }
  Widget _buildProposalCheckbox(int index, Task task, TimeSlot? slot) {
    final slotText = slot != null
        ? '${_formatTime(slot.startAt)} – ${_formatTime(slot.endAt)}'
        : AppLocalizations.of(context)!.morningNoSlotFound;
    final isSelected = _selectedProposals[index] ?? true;
    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) {
        setState(() {
          _selectedProposals[index] = value ?? false;
        });
      },
      title: Text(
        task.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(slotText),
    );
  }
  void _applySelected() {
    final filtered = MorningProposal(
      overdueProposals: widget.proposal.overdueProposals
          .asMap()
          .entries
          .where((entry) => _selectedProposals[entry.key] ?? true)
          .map((entry) => entry.value)
          .toList(),
      todayBalance: _filterRebalanceProposals(
        widget.proposal.todayBalance,
        widget.proposal.overdueProposals.length,
      ),
      tomorrowBalance: _filterRebalanceProposals(
        widget.proposal.tomorrowBalance,
        widget.proposal.overdueProposals.length +
            (widget.proposal.todayBalance?.moveOut.length ?? 0),
      ),
    );
    widget.onApply(filtered);
    Navigator.of(context).pop();
  }
  RebalanceProposal? _filterRebalanceProposals(
    RebalanceProposal? balance,
    int offset,
  ) {
    if (balance == null) {
      return null;
    }
    final filtered = balance.moveOut
        .asMap()
        .entries
        .where((entry) => _selectedProposals[offset + entry.key] ?? true)
        .map((entry) => entry.value)
        .toList();
    if (filtered.isEmpty) {
      return null;
    }
    return RebalanceProposal(
      moveOut: filtered,
      totalLoad: balance.totalLoad,
      availableTime: balance.availableTime,
      day: balance.day,
      keptTasks: balance.keptTasks,
      overflowTasks: balance.overflowTasks,
      totalEstimatedMinutes: balance.totalEstimatedMinutes,
      workWindowMinutes: balance.workWindowMinutes,
    );
  }
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

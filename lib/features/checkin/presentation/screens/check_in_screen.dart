import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../adaptation/application/adaptation_calculator.dart';
import '../../application/check_in_providers.dart';
import '../../application/check_in_repository_provider.dart';
import '../../domain/user_checkin.dart';
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});
  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}
class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  late final TextEditingController _notesController;
  int _mood = 3;
  int _productivity = 3;
  int _energy = 3;
  bool _loadedInitialCheckIn = false;
  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    unawaited(_loadExistingCheckIn());
  }
  Future<void> _loadExistingCheckIn() async {
    final existing = await ref.read(todayCheckInProvider.future);
    if (!mounted || existing == null || _loadedInitialCheckIn) {
      return;
    }
    setState(() {
      _mood = existing.moodScore;
      _productivity = existing.productivity;
      _energy = existing.energy;
      _notesController.text = existing.note;
      _loadedInitialCheckIn = true;
    });
  }
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  Future<void> _save() async {
    final checkInRepository = ref.read(checkInRepositoryProvider);
    final adaptationCalculator = ref.read(adaptationCalculatorProvider);
    final now = DateTime.now();
    final existing = await checkInRepository.getByDate(now);
    final checkIn = UserCheckin(
      id: existing?.id ?? '',
      date: DateTime(now.year, now.month, now.day),
      moodScore: _mood,
      productivity: _productivity,
      energy: _energy,
      note: _notesController.text.trim(),
      createdAt: existing?.createdAt ?? now,
    );
    await checkInRepository.save(checkIn);
    await adaptationCalculator.updateProfile();
    if (!mounted) {
      return;
    }
    context.pop();
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(l10n.checkinTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.checkinTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              _MoodSection(
                mood: _mood,
                onChanged: (value) => setState(() => _mood = value),
              ),
              const SizedBox(height: 20),
              _ProductivitySection(
                productivity: _productivity,
                onChanged: (value) => setState(() => _productivity = value),
              ),
              const SizedBox(height: 20),
              _EnergySection(
                energy: _energy,
                onChanged: (value) => setState(() => _energy = value),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.checkinNotes,
                  hintText: '',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(l10n.checkinSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _MoodSection extends StatelessWidget {
  const _MoodSection({required this.mood, required this.onChanged});
  final int mood;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.checkinMood, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.checkinMoodLowEmoji),
            Text(l10n.checkinMoodHighEmoji),
          ],
        ),
        Slider(
          value: mood.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '$mood',
          onChanged: (value) => onChanged(value.round()),
        ),
      ],
    );
  }
}
class _ProductivitySection extends StatelessWidget {
  const _ProductivitySection({
    required this.productivity,
    required this.onChanged,
  });
  final int productivity;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.checkinProductivity,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.checkinProductivityLowLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Flexible(
              child: Text(
                l10n.checkinProductivityHighLabel,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        Slider(
          value: productivity.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '$productivity',
          onChanged: (value) => onChanged(value.round()),
        ),
      ],
    );
  }
}
class _EnergySection extends StatelessWidget {
  const _EnergySection({
    required this.energy,
    required this.onChanged,
  });
  final int energy;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.checkinEnergy,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.checkinEnergyLowLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Flexible(
              child: Text(
                l10n.checkinEnergyHighLabel,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        Slider(
          value: energy.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '$energy',
          onChanged: (value) => onChanged(value.round()),
        ),
      ],
    );
  }
}

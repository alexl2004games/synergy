import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
class RecurrenceEditorDialog extends StatefulWidget {
  const RecurrenceEditorDialog({super.key, this.initialRRule});
  final String? initialRRule;
  @override
  State<RecurrenceEditorDialog> createState() => _RecurrenceEditorDialogState();
}
class _RecurrenceEditorDialogState extends State<RecurrenceEditorDialog> {
  late String _selectedRRule;
  @override
  void initState() {
    super.initState();
    _selectedRRule = widget.initialRRule ?? '';
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RadioGroup<String>(
      groupValue: _selectedRRule,
      onChanged: (value) {
        setState(() => _selectedRRule = value ?? '');
      },
      child: AlertDialog(
        title: Text(l10n.recurrenceTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(
                label: l10n.recurrenceNone,
                value: '',
              ),
              const SizedBox(height: 12),
              _buildOption(
                label: l10n.recurrenceDaily,
                value: 'FREQ=DAILY',
              ),
              const SizedBox(height: 12),
              _buildOption(
                label: l10n.recurrenceWeekdays,
                value: 'FREQ=DAILY;BYDAY=MO,TU,WE,TH,FR',
              ),
              const SizedBox(height: 12),
              _buildOption(
                label: l10n.recurrenceWeekly,
                value: 'FREQ=WEEKLY',
              ),
              const SizedBox(height: 12),
              _buildOption(
                label: l10n.recurrenceMonthly,
                value: 'FREQ=MONTHLY',
              ),
              const SizedBox(height: 12),
              _buildOption(
                label: l10n.recurrenceYearly,
                value: 'FREQ=YEARLY',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selectedRRule),
            child: Text(l10n.saveButton),
          ),
        ],
      ),
    );
  }
  Widget _buildOption({required String label, required String value}) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
      ),
      onTap: () => setState(() => _selectedRRule = value),
    );
  }
}

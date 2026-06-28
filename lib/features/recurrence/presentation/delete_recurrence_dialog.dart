import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
enum DeleteRecurrenceOption {
  instance,
  allFuture,
  all,
}
class DeleteRecurrenceDialog extends StatefulWidget {
  const DeleteRecurrenceDialog({super.key});
  @override
  State<DeleteRecurrenceDialog> createState() => _DeleteRecurrenceDialogState();
}
class _DeleteRecurrenceDialogState extends State<DeleteRecurrenceDialog> {
  late DeleteRecurrenceOption _selected;
  @override
  void initState() {
    super.initState();
    _selected = DeleteRecurrenceOption.instance;
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RadioGroup<DeleteRecurrenceOption>(
      groupValue: _selected,
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() => _selected = value);
      },
      child: AlertDialog(
        title: Text(l10n.deleteRecurrenceInstanceTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.deleteRecurrenceInstanceBody),
            const SizedBox(height: 16),
            _buildOption(
              label: l10n.deleteRecurrenceInstanceOnly,
              value: DeleteRecurrenceOption.instance,
            ),
            const SizedBox(height: 12),
            _buildOption(
              label: l10n.deleteRecurrenceInstanceFuture,
              value: DeleteRecurrenceOption.allFuture,
            ),
            const SizedBox(height: 12),
            _buildOption(
              label: l10n.deleteRecurrenceAllButton,
              value: DeleteRecurrenceOption.all,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
  }
  Widget _buildOption({
    required String label,
    required DeleteRecurrenceOption value,
  }) {
    return ListTile(
      title: Text(label),
      leading: Radio<DeleteRecurrenceOption>(
        value: value,
      ),
      onTap: () => setState(() => _selected = value),
    );
  }
}

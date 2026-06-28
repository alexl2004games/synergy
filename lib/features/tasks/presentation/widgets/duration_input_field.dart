import 'package:flutter/material.dart';
class DurationInputField extends StatefulWidget {
  const DurationInputField({
    required this.initialMinutes,
    required this.onChanged,
    super.key,
  });
  final int initialMinutes;
  final ValueChanged<int> onChanged;
  @override
  State<DurationInputField> createState() => _DurationInputFieldState();
}
class _DurationInputFieldState extends State<DurationInputField> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMinutes.toString());
    _controller.addListener(_onTextChanged);
  }
  @override
  void didUpdateWidget(covariant DurationInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMinutes != widget.initialMinutes) {
      if (int.tryParse(_controller.text) != widget.initialMinutes) {
        _controller.text = widget.initialMinutes.toString();
      }
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _onTextChanged() {
    final val = int.tryParse(_controller.text);
    if (val != null && val > 0) {
      widget.onChanged(val);
    }
  }
  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final minLabel = isRu ? 'мин' : 'm';
    final presets = [15, 30, 45, 60, 90, 120];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixText: minLabel,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((p) {
            final isSelected = widget.initialMinutes == p;
            String label;
            if (p < 60) {
              label = '$p $minLabel';
            } else if (p == 60) {
              label = isRu ? '1 ч' : '1h';
            } else if (p == 90) {
              label = isRu ? '1.5 ч' : '1.5h';
            } else {
              label = isRu ? '${p ~/ 60} ч' : '${p ~/ 60}h';
            }
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _controller.text = p.toString();
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

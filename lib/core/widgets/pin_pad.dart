import 'package:flutter/material.dart';
class PinPad extends StatelessWidget {
  const PinPad({
    required this.value,
    required this.onChanged,
    this.onBackspace,
    this.maxLength = 6,
    super.key,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onBackspace;
  final int maxLength;
  void _onDigit(int d) {
    if (value.length >= maxLength) return;
    onChanged(value + d.toString());
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row
                .map(
                  (d) => _DigitButton(
                    label: d.toString(),
                    onTap: () => _onDigit(d),
                  ),
                )
                .toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80, height: 80),
            _DigitButton(label: '0', onTap: () => _onDigit(0)),
            SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: IconButton(
                  onPressed: onBackspace,
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: Icon(
                    Icons.backspace_outlined,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  iconSize: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class _DigitButton extends StatelessWidget {
  const _DigitButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    final contentColor = isDark ? Colors.white : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              baseColor.withValues(alpha: isDark ? 0.07 : 0.06),
              baseColor.withValues(alpha: isDark ? 0.02 : 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: baseColor.withValues(alpha: isDark ? 0.14 : 0.1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: -0.5,
                  color: contentColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
class ExpandableSection extends StatelessWidget {
  const ExpandableSection({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    super.key,
  });
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(title),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.centerLeft,
        childrenPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: children,
      ),
    );
  }
}

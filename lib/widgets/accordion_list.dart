import 'package:flutter/material.dart';

class AccordionList extends StatefulWidget {
  final String title;
  final Map<String, AccordionItem> items;
  final Color? headerColor;
  final Color? iconColor;
  final bool initiallyExpandedFirstItem;

  const AccordionList({
    super.key,
    required this.title,
    required this.items,
    this.headerColor,
    this.iconColor,
    this.initiallyExpandedFirstItem = true,
  });

  @override
  State<AccordionList> createState() => _AccordionListState();
}

class AccordionItem {
  final IconData icon;
  final List<String> content;
  final bool initiallyExpanded;

  AccordionItem({
    required this.icon,
    required this.content,
    this.initiallyExpanded = false,
  });
}

class _AccordionListState extends State<AccordionList> {
  late final Map<String, bool> _expandedState;

  @override
  void initState() {
    super.initState();
    _expandedState = {};

    // Initialize expanded state for each item
    var isFirstItem = true;
    for (var entry in widget.items.entries) {
      _expandedState[entry.key] =
          widget.initiallyExpandedFirstItem && isFirstItem
              ? true
              : entry.value.initiallyExpanded;
      isFirstItem = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerColor = widget.headerColor ?? theme.primaryColor;
    final iconColor = widget.iconColor ?? headerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
            ),
          ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: widget.items.entries.map((entry) {
              final title = entry.key;
              final item = entry.value;

              return _buildAccordionItem(
                title: title,
                icon: item.icon,
                content: item.content,
                isExpanded: _expandedState[title] ?? false,
                iconColor: iconColor,
                onToggle: (expanded) {
                  setState(() {
                    _expandedState[title] = expanded;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAccordionItem({
    required String title,
    required IconData icon,
    required List<String> content,
    required bool isExpanded,
    required Color iconColor,
    required Function(bool) onToggle,
  }) {
    return ExpansionTile(
      key: Key(title),
      initiallyExpanded: isExpanded,
      onExpansionChanged: onToggle,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Column(
            children: content
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4, right: 8),
                          child: Icon(
                            Icons.fiber_manual_record,
                            size: 10,
                            color: iconColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

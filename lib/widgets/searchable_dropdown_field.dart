import 'package:flutter/material.dart';

class DropdownItem {
  final String value;
  final String label;

  DropdownItem({required this.value, required this.label});
}

class SearchableDropdownField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final List<DropdownItem> items;
  final bool enabled;
  final double borderRadius;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.items,
    this.enabled = true,
    this.borderRadius = 10,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? () => _showSearchableDialog(context) : null,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              enabled: enabled,
              decoration: InputDecoration(
                filled: true,
                fillColor: enabled ? Colors.grey[100] : Colors.grey[50],
                hintText: placeholder,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: validator ??
                  (value) {
                    if (value == null || value.isEmpty) {
                      return '$label harus dipilih';
                    }
                    return null;
                  },
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchableDialog(BuildContext context) {
    final searchController = TextEditingController();
    List<DropdownItem> filtered = List.from(items);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih $label',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                onChanged: (query) {
                  filtered = items
                      .where((e) =>
                          e.label.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                  (context as Element).markNeedsBuild(); // Force rebuild
                },
                decoration: InputDecoration(
                  hintText: 'Cari $label...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      title: Text(item.label),
                      onTap: () {
                        controller.text = item.label;
                        onChanged?.call(item.value);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

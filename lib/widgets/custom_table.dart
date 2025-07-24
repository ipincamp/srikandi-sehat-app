import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';

class CustomTable extends StatelessWidget {
  final List<Map<String, String>> users;
  final int currentPage;
  final int itemsPerPage;
  final int pageCount;
  final Function(int) onPageChanged;
  final int? scope; // 1 for urban (blue), 2 for rural (green)

  const CustomTable({
    super.key,
    required this.users,
    required this.currentPage,
    required this.itemsPerPage,
    required this.pageCount,
    required this.onPageChanged,
    this.scope = 1, // Default to urban (blue)
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on scope
    final primaryColor = scope == 2 ? Colors.green : Colors.blue;
    final lightColor = scope == 2 ? Colors.green[50] : Colors.blue[50];
    final darkColor = scope == 2 ? Colors.green[800] : Colors.blue[800];

    return Column(
      children: [
        // Table Header (with dynamic theming)
        Container(
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'No',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkColor,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Nama',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Aksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: darkColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table Body
        Container(
          height: 400, // Fixed height to show exactly 10 items
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${index + 1 + (currentPage * itemsPerPage)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        user['name']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        backgroundColor: primaryColor,
                        label: 'Detail',
                        textSize: 12,
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Pagination Controls (with dynamic theming)
        _buildPaginationControls(primaryColor, lightColor, darkColor!),
      ],
    );
  }

  Widget _buildPaginationControls(
      Color primaryColor, Color? lightColor, Color darkColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: currentPage > 0 ? lightColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              onPressed:
                  currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
              icon: Icon(
                Icons.chevron_left,
                size: 20,
                color: currentPage > 0 ? darkColor : Colors.grey,
              ),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 8),

          // Page Numbers
          if (currentPage > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextButton(
                  onPressed: () => onPageChanged(currentPage - 1),
                  child: Text(
                    '${currentPage}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

          // Current Page
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextButton(
                onPressed: null,
                child: Text(
                  '${currentPage + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Next Pages
          if (currentPage < pageCount - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextButton(
                  onPressed: () => onPageChanged(currentPage + 1),
                  child: Text(
                    '${currentPage + 2}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(width: 8),

          // Next Button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  currentPage < pageCount - 1 ? lightColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              onPressed: currentPage < pageCount - 1
                  ? () => onPageChanged(currentPage + 1)
                  : null,
              icon: Icon(
                Icons.chevron_right,
                size: 20,
                color: currentPage < pageCount - 1 ? darkColor : Colors.grey,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

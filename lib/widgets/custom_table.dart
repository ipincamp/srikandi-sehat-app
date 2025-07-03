import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';

class CustomTable extends StatelessWidget {
  final List<Map<String, String>> users;
  final int currentPage;
  final int itemsPerPage;
  final int pageCount;
  final Function(int) onPageChanged;

  const CustomTable({
    super.key,
    required this.users,
    required this.currentPage,
    required this.itemsPerPage,
    required this.pageCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Header Table
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: const Row(
              children: [
                Expanded(flex: 1, child: Text('No', style: _headerStyle)),
                Expanded(flex: 4, child: Text('Nama', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Aksi', style: _headerStyle)),
              ],
            ),
          ),

          // Data Rows (Scrollable)
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : Colors.grey[100],
                    border: const Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child:
                            Text('${index + 1 + currentPage * itemsPerPage}'),
                      ),
                      Expanded(flex: 4, child: Text(user['name']!)),
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          backgroundColor: Colors.blue,
                          label: 'Detail',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ✅ Pagination Controls (fixed)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Previous
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  onPressed: currentPage > 0
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left, size: 24),
                  padding: EdgeInsets.zero,
                ),
              ),

              // Tombol Nomor Halaman
              ...List.generate(pageCount, (i) => i).map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: currentPage == i
                          ? Colors.pinkAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextButton(
                      onPressed: () => onPageChanged(i),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color:
                              currentPage == i ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Tombol Next
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  onPressed: currentPage < pageCount - 1
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right, size: 24),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const TextStyle _headerStyle =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

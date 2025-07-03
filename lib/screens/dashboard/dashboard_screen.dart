import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/widgets/custom_table.dart';
import 'package:srikandi_sehat_app/widgets/custom_chart.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final List<Map<String, String>> allUsers = List.generate(
    25,
    (index) => {
      'name': 'User ${index + 1}',
      'region': index % 2 == 0 ? 'Kota' : 'Desa',
    },
  );

  int currentPage = 0;
  final int itemsPerPage = 10;
  bool showUrban = true;

  @override
  Widget build(BuildContext context) {
    final filteredUsers = allUsers
        .where((user) =>
            showUrban ? user['region'] == 'Kota' : user['region'] == 'Desa')
        .toList();

    final pageCount = (filteredUsers.length / itemsPerPage).ceil();
    final usersToShow = filteredUsers
        .skip(currentPage * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    int urbanCount = allUsers.where((user) => user['region'] == 'Kota').length;
    int ruralCount = allUsers.where((user) => user['region'] == 'Desa').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomChart(
              urbanCount: urbanCount,
              ruralCount: ruralCount,
              onDownloadPressed: () {},
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => showUrban = true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: showUrban ? Colors.white : Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: const Center(child: Text('Perkotaan')),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => showUrban = false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: !showUrban ? Colors.white : Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: const Center(child: Text('Pedesaan')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomTable(
              users: usersToShow,
              currentPage: currentPage,
              itemsPerPage: itemsPerPage,
              pageCount: pageCount,
              onPageChanged: (index) => setState(() => currentPage = index),
            ),
          ],
        ),
      ),
    );
  }
}

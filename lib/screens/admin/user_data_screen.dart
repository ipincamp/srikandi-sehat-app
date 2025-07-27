import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/csv_download_provider.dart';
import 'package:srikandi_sehat_app/provider/user_data_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_chart.dart';
import 'package:srikandi_sehat_app/widgets/custom_table.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  int? selectedScope; // 1 for urban, 2 for rural

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchInitialUsers();
    });
  }

  Future<void> fetchInitialUsers() async {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    await provider.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDataProvider>(context);
    final allUsers = userProvider.allUsers;
    final currentPage = userProvider.currentPage;
    final pageCount = userProvider.lastPage;
    final urbanCount = userProvider.urbanCount;
    final ruralCount = userProvider.ruralCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: userProvider.isLoading && allUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CustomChart(
                      urbanCount: urbanCount,
                      ruralCount: ruralCount,
                      onDownloadPressed: () {
                        final provider = Provider.of<CsvDownloadProvider>(
                            context,
                            listen: false);
                        provider.downloadUserCsv();
                      }),
                  const SizedBox(height: 20),
                  // Filter Buttons (with improved styling)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedScope = 1);
                              userProvider.fetchUsers(scope: 1);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: selectedScope == 1
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                boxShadow: selectedScope == 1
                                    ? [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Perkotaan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedScope == 1
                                        ? Colors.blue
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedScope = 2);
                              userProvider.fetchUsers(scope: 2);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: selectedScope == 2
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                boxShadow: selectedScope == 2
                                    ? [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Pedesaan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedScope == 2
                                        ? Colors.green
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Table with fixed height for 10 items
                  CustomTable(
                    users: allUsers
                        .map((u) => {
                              'name': u.name,
                              'region': u.scope == 1 ? 'Kota' : 'Desa',
                            })
                        .toList(),
                    currentPage: currentPage - 1, // Convert to 0-based index
                    itemsPerPage: 10,
                    pageCount: pageCount,
                    scope: selectedScope,
                    onPageChanged: (index) {
                      // Convert to 1-based index for API
                      userProvider.fetchUsers(
                        page: index + 1,
                        scope: selectedScope,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

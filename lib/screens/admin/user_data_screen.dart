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
  int? selectedScope;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    await provider.fetchUsers(context);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => userProvider.refreshData(context),
          ),
        ],
      ),
      body: userProvider.isLoading && allUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => userProvider.refreshData(context),
              child: SingleChildScrollView(
                controller: _scrollController,
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
                        provider.downloadUserCsv(context);
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildScopeFilter(context, userProvider),
                    const SizedBox(height: 20),
                    CustomTable(
                      users: allUsers
                          .map((u) => {
                                'id': u.id,
                                'name': u.name,
                                'region': u.scope == 1 ? 'Kota' : 'Desa',
                              })
                          .toList(),
                      currentPage: currentPage - 1,
                      itemsPerPage: 10,
                      pageCount: pageCount,
                      scope: selectedScope,
                      onPageChanged: (index) {
                        userProvider.fetchUsers(
                          context,
                          page: index + 1,
                          scope: selectedScope,
                        );
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildScopeFilter(BuildContext context, UserDataProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => selectedScope = 1);
                provider.fetchUsers(context, scope: 1);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selectedScope == 1 ? Colors.white : Colors.transparent,
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
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Perkotaan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          selectedScope == 1 ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => selectedScope = 2);
                provider.fetchUsers(context, scope: 2);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selectedScope == 2 ? Colors.white : Colors.transparent,
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
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Pedesaan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          selectedScope == 2 ? Colors.green : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

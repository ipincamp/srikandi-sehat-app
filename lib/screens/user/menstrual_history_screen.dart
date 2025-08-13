import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/menstural_history_model.dart';
import 'package:srikandi_sehat_app/provider/menstrual_history_provider.dart';
import 'package:srikandi_sehat_app/screens/user/mestrual_history_detail_screen.dart';

class MenstrualHistoryScreen extends StatefulWidget {
  const MenstrualHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MenstrualHistoryScreen> createState() => _MenstrualHistoryScreenState();
}

class _MenstrualHistoryScreenState extends State<MenstrualHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<MenstrualHistoryProvider>(
      context,
      listen: false,
    );
    await provider.fetchCycles();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<MenstrualHistoryProvider>(
        context,
        listen: false,
      );
      provider.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Riwayat Menstruasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink, Colors.pinkAccent],
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              _buildLimitSelector(
                Provider.of<MenstrualHistoryProvider>(context),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
                tooltip: 'Filter',
              ),
            ],
          ),
        ],
      ),
      body: Consumer<MenstrualHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.cycles.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              ),
            );
          }

          if (provider.errorMessage.isNotEmpty) {
            return _buildErrorState(provider.errorMessage);
          }

          if (provider.cycles.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refreshData,
                  color: Colors.pink,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.cycles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == provider.cycles.length) {
                        return provider.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.pink,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox();
                      }
                      return _buildCycleItem(
                        index + 1,
                        provider.cycles[index],
                        provider.cycles.length,
                      );
                    },
                  ),
                ),
              ),
              _buildPaginationControls(provider),
            ],
          );
        },
      ),
    );
  }

  // Widget _buildFilterControls(MenstrualHistoryProvider provider) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
  //     child: Row(children: [const Spacer(), _buildLimitSelector(provider)]),
  //   );
  // }

  Widget _buildLimitSelector(MenstrualHistoryProvider provider) {
    return PopupMenuButton<int>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.pink[100]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${provider.limit}',
              style: TextStyle(
                color: Colors.pink[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.pink),
          ],
        ),
      ),
      onSelected: (limit) => provider.fetchCycles(limit: limit),
      itemBuilder: (context) => [5, 10, 20, 50, 100].map((limit) {
        return PopupMenuItem<int>(
          value: limit,
          child: Text(
            '$limit items',
            style: TextStyle(
              color: provider.limit == limit ? Colors.pink : Colors.black87,
              fontWeight: provider.limit == limit
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCycleItem(int itemNumber, MenstrualCycle cycle, int totalItems) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(itemNumber, cycle, totalItems),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.white.withOpacity(0.02)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.pink, Colors.pinkAccent],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$itemNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.pink,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_formatDate(cycle.startDate)} - ${_formatDate(cycle.finishDate)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildInfoChip(
                                  '${cycle.periodLength} hari',
                                  Icons.calendar_today,
                                ),
                                if (cycle.cycleLength != null)
                                  _buildInfoChip(
                                    'Siklus ${cycle.cycleLength} hari',
                                    Icons.repeat,
                                  ),
                              ],
                            ),
                            Icon(
                              cycle.isPeriodNormal
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: cycle.isPeriodNormal
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 16),
      backgroundColor: Colors.grey[100],
      labelStyle: const TextStyle(fontSize: 12),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildPaginationControls(MenstrualHistoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.currentPage > 1
                ? () => _goToPage(provider.currentPage - 1, provider)
                : null,
            color: Colors.pink,
            disabledColor: Colors.grey[400],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${provider.currentPage}/${provider.totalPages}',
              style: TextStyle(
                color: Colors.pink[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.currentPage < provider.totalPages
                ? () => _goToPage(provider.currentPage + 1, provider)
                : null,
            color: Colors.pink,
            disabledColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history, size: 40, color: Colors.pink),
              ),
              const SizedBox(height: 24),
              const Text(
                'Belum Ada Riwayat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tidak ada riwayat menstruasi yang tercatat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInitialData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Muat Ulang',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInitialData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(int itemNumber, MenstrualCycle cycle, int totalItems) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenstrualHistoryDetailScreen(
          cycle: cycle,
          itemNumber: itemNumber,
          totalItems: totalItems,
        ),
      ),
    );
  }

  void _goToPage(int page, MenstrualHistoryProvider provider) {
    provider.fetchCycles(page: page);
  }

  void _showFilterDialog() {
    // Implement filter dialog if needed
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

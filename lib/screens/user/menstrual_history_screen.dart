import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/menstural_cycle_model.dart';
import 'package:srikandi_sehat_app/provider/menstrual_cycle_provider.dart';
import 'package:srikandi_sehat_app/screens/user/mestrual_history_detail_screen.dart';

class MenstrualHistoryScreen extends StatefulWidget {
  const MenstrualHistoryScreen({super.key});

  @override
  State<MenstrualHistoryScreen> createState() => _MenstrualHistoryScreenState();
}

class _MenstrualHistoryScreenState extends State<MenstrualHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentLimit = 5;
  final List<int> _limitOptions = [5, 10, 20, 50, 100];

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
    final provider = Provider.of<MenstrualCycleProvider>(
      context,
      listen: false,
    );
    await provider.fetchCycles(limit: _currentLimit);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<MenstrualCycleProvider>(
        context,
        listen: false,
      );
      provider.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Menstruasi'),
        backgroundColor: const Color(0xFFED1C24),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showLimitDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Consumer<MenstrualCycleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.cycles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return _buildErrorState(provider.errorMessage);
          }

          if (provider.cycles.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildDataCountHeader(provider),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refreshData(),
                  color: const Color(0xFFED1C24),
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: provider.cycles.length + 1,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index < provider.cycles.length) {
                        return _buildCycleItem(
                          index + 1,
                          provider.cycles[index],
                          provider.totalData,
                        );
                      }
                      return _buildPaginationFooter(provider);
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

  Widget _buildDataCountHeader(MenstrualCycleProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: const Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Data: ${provider.totalData}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Menampilkan: ${provider.cycles.length}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleItem(int itemNumber, MenstrualCycle cycle, int totalItems) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _navigateToDetail(itemNumber, cycle, totalItems),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildItemNumber(itemNumber),
              const SizedBox(width: 12),
              _buildStatusIndicator(cycle),
              const SizedBox(width: 16),
              Expanded(child: _buildCycleInfo(cycle)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemNumber(int number) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFED1C24),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(MenstrualCycle cycle) {
    return Container(
      width: 8,
      height: 60,
      decoration: BoxDecoration(
        color: cycle.isPeriodNormal ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCycleInfo(MenstrualCycle cycle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_formatDate(cycle.startDate)} - ${_formatDate(cycle.finishDate)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Icon(
              cycle.isPeriodNormal ? Icons.check_circle : Icons.warning,
              color: cycle.isPeriodNormal ? Colors.green : Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildInfoChip('${cycle.periodLength} hari', Icons.calendar_today),
            if (cycle.cycleLength != null)
              _buildInfoChip('Siklus ${cycle.cycleLength} hari', Icons.repeat),
          ],
        ),
      ],
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

  Widget _buildPaginationControls(MenstrualCycleProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: provider.currentPage > 1
                ? () => _goToPage(provider.currentPage - 1, provider)
                : null,
          ),
          Text(
            'Halaman ${provider.currentPage}/${provider.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: provider.currentPage < provider.totalPages
                ? () => _goToPage(provider.currentPage + 1, provider)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(MenstrualCycleProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          if (provider.currentPage < provider.totalPages)
            ElevatedButton(
              onPressed: provider.loadNextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFED1C24),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Muat Lebih Banyak'),
            ),
          const SizedBox(height: 8),
          Text(
            'Menampilkan ${provider.cycles.length} dari ${provider.totalData} data',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFED1C24),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Belum ada riwayat menstruasi'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFED1C24),
              foregroundColor: Colors.white,
            ),
            child: const Text('Muat Ulang'),
          ),
        ],
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

  void _goToPage(int page, MenstrualCycleProvider provider) {
    provider.fetchCycles(page: page, limit: _currentLimit);
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Item per Halaman'),
          content: SizedBox(
            width: double.maxFinite,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _limitOptions.map((limit) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() => _currentLimit = limit);
                    Provider.of<MenstrualCycleProvider>(
                      context,
                      listen: false,
                    ).fetchCycles(page: 1, limit: limit);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentLimit == limit
                        ? const Color(0xFFED1C24)
                        : Colors.grey[200],
                    foregroundColor: _currentLimit == limit
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: Text('$limit'),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

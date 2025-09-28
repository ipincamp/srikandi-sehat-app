import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:srikandi_sehat_app/models/menstural_history_model.dart';
import 'package:srikandi_sehat_app/provider/menstrual_history_provider.dart';
import 'package:srikandi_sehat_app/screens/user/menstrual_history_detail_screen.dart';
import 'package:srikandi_sehat_app/widgets/connection_error_card.dart';

class MenstrualHistoryScreen extends StatefulWidget {
  const MenstrualHistoryScreen({super.key});

  @override
  State<MenstrualHistoryScreen> createState() => _MenstrualHistoryScreenState();
}

class _MenstrualHistoryScreenState extends State<MenstrualHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _initialLoadComplete = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isRefreshing = true);

      final hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        throw Exception('Tidak ada koneksi internet');
      }

      final provider = Provider.of<MenstrualHistoryProvider>(
        context,
        listen: false,
      );
      await provider.fetchCycles();
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      if (await _checkInternetConnection()) {
        final provider = Provider.of<MenstrualHistoryProvider>(
          context,
          listen: false,
        );
        await provider.fetchCycles();
      } else {
        throw e;
      }
    } finally {
      if (mounted) {
        setState(() {
          _initialLoadComplete = true;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    try {
      setState(() => _isRefreshing = true);

      final hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        throw Exception('Tidak ada koneksi internet');
      }

      final provider = Provider.of<MenstrualHistoryProvider>(
        context,
        listen: false,
      );
      await provider.refreshData();
    } catch (e) {
      // Jika gagal, coba sekali lagi setelah delay
      await Future.delayed(const Duration(seconds: 1));

      if (await _checkInternetConnection()) {
        final provider = Provider.of<MenstrualHistoryProvider>(
          context,
          listen: false,
        );
        await provider.refreshData();
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _scrollListener() {
    final provider = Provider.of<MenstrualHistoryProvider>(
      context,
      listen: false,
    );
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !provider.isLoading &&
        provider.currentPage < provider.totalPages) {
      provider.fetchCycles(page: provider.currentPage + 1);
    }
  }

  Widget _buildAppBar(MenstrualHistoryProvider provider) {
    return AppBar(
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
      centerTitle: false,
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
        if (provider.selectedDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.pink[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    DateFormat('dd/MM/yy').format(provider.selectedDate!),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: _isRefreshing ? null : provider.clearDateFilter,
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        IconButton(
          icon: _isRefreshing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh),
          onPressed: _isRefreshing ? null : _handleRefresh,
        ),
      ],
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text(
          'Riwayat Menstruasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: ConnectionErrorWidget(
          message: "Tidak ada koneksi, periksa jaringan anda",
          icon: Icons.wifi_off,
          iconColor: Colors.red,
          iconSize: 60,
          isLoading: _isRefreshing,
          onRetry: _isRefreshing ? null : _handleRefresh,
          retryText: 'Refresh',
        ),
      ),
    );
  }

  Widget _buildLimitSelector(
    MenstrualHistoryProvider provider, {
    bool inAppBar = false,
  }) {
    return PopupMenuButton<int>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: inAppBar ? Colors.pink[400] : Colors.pink[50],
          borderRadius: BorderRadius.circular(20),
          border: inAppBar ? null : Border.all(color: Colors.pink[100]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${provider.limit} items',
              style: TextStyle(
                color: inAppBar ? Colors.white : Colors.pink[800],
                fontWeight: FontWeight.w500,
                fontSize: inAppBar ? 14 : null,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: inAppBar ? Colors.white : Colors.pink,
            ),
          ],
        ),
      ),
      onSelected: (limit) async {
        setState(() => _isRefreshing = true);
        try {
          await provider.setLimit(limit);
        } finally {
          if (mounted) {
            setState(() => _isRefreshing = false);
          }
        }
      },
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

  Widget _buildPaginationControls(MenstrualHistoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _isRefreshing || provider.currentPage <= 1
                ? null
                : () async {
                    setState(() => _isRefreshing = true);
                    try {
                      await provider.fetchCycles(
                        page: provider.currentPage - 1,
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isRefreshing = false);
                      }
                    }
                  },
            color: Colors.pink,
            disabledColor: Colors.grey[400],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.pink[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${provider.currentPage}/${provider.totalPages} pages',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                _isRefreshing || provider.currentPage >= provider.totalPages
                ? null
                : () async {
                    setState(() => _isRefreshing = true);
                    try {
                      await provider.fetchCycles(
                        page: provider.currentPage + 1,
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isRefreshing = false);
                      }
                    }
                  },
            color: Colors.pink,
            disabledColor: Colors.grey[400],
          ),
          _buildLimitSelector(provider, inAppBar: true),
        ],
      ),
    );
  }

  Widget _buildEmptyState(MenstrualHistoryProvider provider) {
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
              Text(
                provider.selectedDate == null
                    ? 'Belum Ada Riwayat'
                    : 'Tidak Ada Data Pada Tanggal Ini',
                style: const TextStyle(
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
              if (provider.selectedDate != null)
                ElevatedButton(
                  onPressed: _isRefreshing ? null : provider.clearDateFilter,
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
                  child: _isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lihat Semua Riwayat',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleItem(
    MenstrualCycle item,
    int index,
    MenstrualHistoryProvider provider,
  ) {
    final itemNumber =
        index + 1 + ((provider.currentPage - 1) * provider.limit);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MenstrualHistoryDetailScreen(
                  cycleId: item.id,
                  itemNumber: itemNumber,
                  totalItems: provider.totalData,
                ),
              ),
            );
          },
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
                                '${DateFormat('dd MMM yyyy').format(item.startDate)} - ${DateFormat('dd MMM yyyy').format(item.finishDate)}',
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.medical_services,
                                color: Colors.pink,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.periodLength} hari menstruasi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              item.isPeriodNormal
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: item.isPeriodNormal
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.pink, Colors.pinkAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MenstrualHistoryDetailScreen(
                              cycleId: item.id,
                              itemNumber: itemNumber,
                              totalItems: provider.totalData,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.visibility_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Detail',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MenstrualHistoryProvider provider) {
    if (!_initialLoadComplete ||
        (provider.isLoading && provider.cycles.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
        ),
      );
    }

    // if (provider.errorMessage.isNotEmpty) {
    //   return _buildErrorScreen();
    // }

    if (provider.cycles.isEmpty) {
      return _buildEmptyState(provider);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Card(
            elevation: 2,
            color: Colors.pink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.timeline, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Riwayat',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          '${provider.totalData} catatan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // History List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Colors.pink,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: provider.cycles.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.cycles.length) {
                  return provider.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.pink,
                            ),
                          ),
                        )
                      : const SizedBox();
                }
                return _buildCycleItem(provider.cycles[index], index, provider);
              },
            ),
          ),
        ),

        // Pagination Controls
        _buildPaginationControls(provider),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenstrualHistoryProvider>(context);

    if (provider.errorMessage.isNotEmpty &&
        !provider.errorMessage.contains("You have no cycle history")) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildAppBar(provider),
          Expanded(child: _buildContent(provider)),
        ],
      ),
    );
  }
}

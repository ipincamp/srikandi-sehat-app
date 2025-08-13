import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/symptom_history_model.dart';
import 'package:srikandi_sehat_app/provider/symptom_history_provider.dart';
import 'package:srikandi_sehat_app/screens/user/symptom_detail_screen.dart';

class SymptomHistoryScreen extends StatefulWidget {
  const SymptomHistoryScreen({super.key});

  @override
  State<SymptomHistoryScreen> createState() => _SymptomHistoryScreenState();
}

class _SymptomHistoryScreenState extends State<SymptomHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

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

  void _loadInitialData() {
    final provider = Provider.of<SymptomHistoryProvider>(
      context,
      listen: false,
    );
    provider.fetchSymptomHistory();
  }

  void _scrollListener() {
    final provider = Provider.of<SymptomHistoryProvider>(
      context,
      listen: false,
    );
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        provider.metadata.currentPage < provider.metadata.totalPages) {
      provider.goToPage(provider.metadata.currentPage + 1);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pink,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final provider = Provider.of<SymptomHistoryProvider>(
        context,
        listen: false,
      );
      await provider.fetchSymptomHistory(date: picked);
    }
  }

  Widget _buildAppBar(SymptomHistoryProvider provider) {
    return AppBar(
      title: Row(
        children: [
          const Text(
            'Riwayat Gejala',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          if (provider.metadata.totalData > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${provider.metadata.totalData}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
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
                    onPressed: provider.clearDateFilter,
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        _buildLimitSelector(provider, inAppBar: true),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
          tooltip: 'Filter Tanggal',
        ),
      ],
    );
  }

  Widget _buildLimitSelector(
    SymptomHistoryProvider provider, {
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
              '${provider.limit}',
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
      onSelected: provider.setLimit,
      itemBuilder: (context) => provider.availableLimits.map((limit) {
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

  Widget _buildPaginationControls(SymptomHistoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.metadata.currentPage > 1
                ? () => provider.goToPage(provider.metadata.currentPage - 1)
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
              '${provider.metadata.currentPage}/${provider.metadata.totalPages}',
              style: TextStyle(
                color: Colors.pink[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                provider.metadata.currentPage < provider.metadata.totalPages
                ? () => provider.goToPage(provider.metadata.currentPage + 1)
                : null,
            color: Colors.pink,
            disabledColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(SymptomHistoryProvider provider) {
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
                'Tidak ada riwayat gejala yang tercatat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 16),
              if (provider.selectedDate != null)
                ElevatedButton(
                  onPressed: provider.clearDateFilter,
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

  Widget _buildSymptomItem(
    Symptom item,
    int index,
    SymptomHistoryProvider provider,
  ) {
    final itemNumber =
        index + 1 + ((provider.metadata.currentPage - 1) * provider.limit);

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
                builder: (_) => SymptomDetailScreen(symptomId: item.id),
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
                                DateFormat('dd MMM yyyy').format(item.logDate),
                                style: const TextStyle(
                                  fontSize: 16,
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
                              '${item.totalSymptoms} gejala tercatat',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
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
                            builder: (_) =>
                                SymptomDetailScreen(symptomId: item.id),
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

  Widget _buildContent(SymptomHistoryProvider provider) {
    if (provider.isLoading && provider.symptoms.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
        ),
      );
    }

    if (provider.symptoms.isEmpty) {
      return _buildEmptyState(provider);
    }

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.timeline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Riwayat Gejala',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${provider.metadata.totalData} catatan',
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

        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.refresh,
            color: Colors.pink,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.symptoms.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.symptoms.length) {
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
                return _buildSymptomItem(
                  provider.symptoms[index],
                  index,
                  provider,
                );
              },
            ),
          ),
        ),
        _buildPaginationControls(provider),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<SymptomHistoryProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildAppBar(provider),
              Expanded(child: _buildContent(provider)),
            ],
          );
        },
      ),
    );
  }
}

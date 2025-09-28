import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/menstural_history_detail_model.dart';
import 'package:srikandi_sehat_app/provider/menstrual_history_detail_provider.dart';

class MenstrualHistoryDetailScreen extends StatefulWidget {
  final int cycleId;
  final int itemNumber;
  final int totalItems;

  const MenstrualHistoryDetailScreen({
    super.key,
    required this.cycleId,
    required this.itemNumber,
    required this.totalItems,
  });

  @override
  State<MenstrualHistoryDetailScreen> createState() =>
      _MenstrualHistoryDetailScreenState();
}

class _MenstrualHistoryDetailScreenState
    extends State<MenstrualHistoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenstrualHistoryDetailProvider>(
        context,
        listen: false,
      ).fetchCycleDetail(widget.cycleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detail Siklus Menstruasi'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Consumer<MenstrualHistoryDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => provider.fetchCycleDetail(widget.cycleId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.detail == null) {
            return const Center(child: Text('Data tidak tersedia'));
          }

          return _buildDetailContent(provider.detail!);
        },
      ),
    );
  }

  Widget _buildDetailContent(MenstrualCycleDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCycleInfoCard(detail),
          const SizedBox(height: 20),
          _buildSymptomsList(detail.symptoms),
        ],
      ),
    );
  }

  Widget _buildCycleInfoCard(MenstrualCycleDetail detail) {
    return Card(
      color: Colors.pink[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${widget.itemNumber}/${widget.totalItems}',
                    style: TextStyle(
                      color: Colors.pink[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  detail.isPeriodNormal ? Icons.check_circle : Icons.warning,
                  color: detail.isPeriodNormal ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Tanggal Mulai',
              value: DateFormat('dd MMMM yyyy').format(detail.startDate),
            ),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Tanggal Selesai',
              value: DateFormat('dd MMMM yyyy').format(detail.finishDate),
            ),
            _buildInfoRow(
              icon: Icons.timelapse,
              label: 'Durasi Menstruasi',
              value: '${detail.periodLength} hari',
            ),
            _buildInfoRow(
              icon: Icons.cyclone,
              label: 'Panjang Siklus',
              value: '${detail.cycleLength} hari',
            ),
            _buildInfoRow(
              icon: Icons.health_and_safety,
              label: 'Status Siklus',
              value: detail.isCycleNormal ? 'Normal' : 'Tidak Normal',
              isWarning: !detail.isCycleNormal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.pink),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.orange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsList(List<CycleSymptom> symptoms) {
    if (symptoms.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Tidak ada gejala yang dicatat'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gejala yang Dicatat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...symptoms.map((symptom) => _buildSymptomCard(symptom)).toList(),
      ],
    );
  }

  Widget _buildSymptomCard(CycleSymptom symptom) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy HH:mm').format(symptom.loggedAt),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (symptom.note != null && symptom.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                symptom.note!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptom.details
                  .map(
                    (detail) => Chip(
                      backgroundColor: _getSymptomColor(
                        detail.symptomName,
                      ).withOpacity(0.1),
                      label: detail.selectedOption != null
                          ? Text(
                              '${detail.symptomName} (${detail.selectedOption})',
                            )
                          : Text(detail.symptomName),
                      labelStyle: TextStyle(
                        color: _getSymptomColor(detail.symptomName),
                        fontWeight: FontWeight.w600,
                      ),
                      avatar: Icon(
                        _getSymptomIcon(detail.symptomName),
                        color: _getSymptomColor(detail.symptomName),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSymptomIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dismenore')) return Icons.healing;
    if (lower.contains('mood')) return Icons.mood;
    return Icons.medical_services;
  }

  Color _getSymptomColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dismenore')) return Colors.pink;
    if (lower.contains('mood')) return Colors.purple;
    return Colors.blue;
  }
}

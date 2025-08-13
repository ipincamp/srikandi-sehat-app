import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/models/menstural_history_model.dart';

class MenstrualHistoryDetailScreen extends StatelessWidget {
  final MenstrualCycle cycle;

  const MenstrualHistoryDetailScreen({
    super.key,
    required this.cycle,
    required int itemNumber,
    required int totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Log Menstruasi'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailCard(
              title: 'Periode Menstruasi',
              items: [
                _buildDetailItem('Mulai', _formatDate(cycle.startDate)),
                _buildDetailItem('Selesai', _formatDate(cycle.finishDate)),
                _buildDetailItem('Durasi', '${cycle.periodLength} hari'),
                _buildDetailItem(
                  'Status',
                  cycle.isPeriodNormal ? 'Normal' : 'Tidak Normal',
                  isNormal: cycle.isPeriodNormal,
                ),
              ],
            ),
            if (cycle.cycleLength != null) ...[
              const SizedBox(height: 16),
              _buildDetailCard(
                title: 'Siklus Menstruasi',
                items: [
                  _buildDetailItem(
                    'Panjang Siklus',
                    '${cycle.cycleLength} hari',
                  ),
                  _buildDetailItem(
                    'Status Siklus',
                    cycle.isCycleNormal ?? false ? 'Normal' : 'Tidak Normal',
                    isNormal: cycle.isCycleNormal,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool? isNormal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          if (isNormal != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isNormal ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNormal ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: isNormal ? Colors.green[800] : Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

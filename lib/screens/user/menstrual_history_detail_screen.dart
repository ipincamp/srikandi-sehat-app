import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app/models/menstural_history_detail_model.dart';
import 'package:app/provider/menstrual_history_detail_provider.dart';
import 'package:app/widgets/custom_alert.dart';

class MenstrualHistoryDetailScreen extends StatefulWidget {
  final int cycleId;
  final int itemNumber;
  final int totalItems;
  final bool isDeleted;
  final String? deletionReason;
  final DateTime? deletedAt;

  const MenstrualHistoryDetailScreen({
    super.key,
    required this.cycleId,
    required this.itemNumber,
    required this.totalItems,
    this.isDeleted = false,
    this.deletionReason,
    this.deletedAt,
  });

  @override
  State<MenstrualHistoryDetailScreen> createState() =>
      _MenstrualHistoryDetailScreenState();
}

class _MenstrualHistoryDetailScreenState
    extends State<MenstrualHistoryDetailScreen> {
  bool _isDeleting = false;
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
    return Consumer<MenstrualHistoryDetailProvider>(
      builder: (context, provider, _) {
        // Menentukan apakah siklus aktif (belum selesai)
        final bool isCycleActive =
            !widget.isDeleted &&
            (provider.detail == null || provider.detail?.cycleLength == null);

        // Tombol hapus hanya muncul jika TIDAK dihapus DAN TIDAK aktif
        final bool showDeleteButton = !widget.isDeleted && !isCycleActive;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Detail Siklus Menstruasi'),
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            actions: [
              if (showDeleteButton)
                IconButton(
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delete),
                  onPressed: _isDeleting
                      ? null
                      : () async {
                          final reason = await _showDeleteReasonDialog();
                          if (reason == null) return;

                          setState(() => _isDeleting = true);
                          await provider.deleteCycleDetail(
                            widget.cycleId,
                            reason,
                          );

                          setState(() => _isDeleting = false);

                          if (provider.error == null) {
                            CustomAlert.show(
                              context,
                              'Siklus berhasil dihapus',
                              type: AlertType.success,
                            );
                            Navigator.pop(context, true);
                            return;
                          } else {
                            CustomAlert.show(
                              context,
                              provider.error!,
                              type: AlertType.error,
                            );
                          }
                        },
                ),
            ],
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(MenstrualHistoryDetailProvider provider) {
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
  }

  Future<String?> _showDeleteReasonDialog() async {
    final TextEditingController controller = TextEditingController();
    String? errorText;
    return await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.delete_forever, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(child: Text('Hapus Siklus')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Berikan alasan mengapa kamu ingin menghapus siklus ini (minimal 5 karakter):',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    maxLength: 250,
                    decoration: InputDecoration(
                      hintText: 'Tulis alasan di sini...',
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) {
                      setState(() => errorText = 'Alasan wajib diisi');
                      return;
                    }
                    if (text.length < 5) {
                      setState(() => errorText = 'Minimal 5 karakter');
                      return;
                    }
                    Navigator.of(context).pop(text);
                  },
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailContent(MenstrualCycleDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isDeleted)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_forever, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Siklus ini telah dihapus',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            if (widget.deletionReason != null)
                              Text(
                                widget.deletionReason!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            if (widget.deletedAt != null)
                              Text(
                                DateFormat(
                                  'dd MMM yyyy HH:mm',
                                ).format(widget.deletedAt!),
                                style: const TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _buildCycleInfoCard(detail),
          const SizedBox(height: 20),
          _buildSymptomsList(detail.symptoms),
        ],
      ),
    );
  }

  Widget _buildCycleInfoCard(MenstrualCycleDetail detail) {
    // Tentukan apakah siklus aktif (jika cycleLength masih null)
    final bool isCycleActive = detail.cycleLength == null;

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
              // Jika aktif, tampilkan "Sedang Berlangsung", jika tidak, format tanggal
              value: isCycleActive
                  ? 'Sedang Berlangsung'
                  : DateFormat('dd MMMM yyyy').format(detail.finishDate),
              valueColor: isCycleActive ? Colors.orange[700] : null,
            ),
            _buildInfoRow(
              icon: Icons.timelapse,
              label: 'Durasi Menstruasi',
              value: '${detail.periodLength} hari',
            ),
            _buildInfoRow(
              icon: Icons.cyclone,
              label: 'Panjang Siklus',
              // Jika aktif, tampilkan "Belum Selesai"
              value: detail.cycleLength != null
                  ? '${detail.cycleLength} hari'
                  : 'Belum Selesai',
            ),
            _buildInfoRow(
              icon: Icons.health_and_safety,
              label: 'Status Siklus',
              // Jika aktif, tampilkan "Belum Selesai"
              value: detail.isCycleNormal == null
                  ? 'Belum Selesai'
                  : detail.isCycleNormal!
                  ? 'Normal'
                  : 'Tidak Normal',
              isWarning: detail.isCycleNormal == false,
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
    Color? valueColor,
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
              color: valueColor ?? (isWarning ? Colors.orange : Colors.black),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/symptom_detail_model.dart';
import 'package:app/provider/symptom_history_detail_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SymptomDetailScreen extends StatefulWidget {
  final int symptomId;

  const SymptomDetailScreen({super.key, required this.symptomId});

  @override
  State<SymptomDetailScreen> createState() => _SymptomDetailScreenState();
}

class _SymptomDetailScreenState extends State<SymptomDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Provider.of<SymptomDetailProvider>(
      context,
      listen: false,
    ).fetchDetail(widget.symptomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detail Gejala'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SymptomDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _ErrorView(error: provider.error!, onRetry: _loadData);
          }

          if (provider.detail == null) {
            return _ErrorView(error: 'Data tidak tersedia', onRetry: _loadData);
          }

          return _ContentDetailView(detail: provider.detail!);
        },
      ),
    );
  }
}

class _ContentDetailView extends StatelessWidget {
  final SymptomDetail detail;

  const _ContentDetailView({required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _DateCard(logDate: detail.logDate),
          const SizedBox(height: 20),
          if (detail.note != null && detail.note!.isNotEmpty) ...[
            _NotesSection(notes: detail.note!),
            const SizedBox(height: 20),
          ],
          _SymptomsList(details: detail.details),
          const SizedBox(height: 20),
          _RecommendationsList(recommendations: detail.recommendations),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String logDate;

  const _DateCard({required this.logDate});

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      twoDigits(int n) => n.toString().padLeft(2, '0');

      final day = date.day;
      final month = months[date.month - 1];
      final year = date.year;
      final hour = twoDigits(date.hour);
      final minute = twoDigits(date.minute);

      return '$day $month $year • $hour:$minute';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.pink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanggal Pencatatan',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  _formatDate(logDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SymptomsList extends StatelessWidget {
  final List<SymptomItem> details;

  const _SymptomsList({required this.details});

  IconData _getSymptomIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dismenore')) return Icons.healing;
    if (lower.contains('mood')) return Icons.mood;
    if (lower.contains('5l')) return Icons.water_drop;
    if (lower.contains('kram')) return Icons.sick;
    return Icons.medical_services;
  }

  Color _getSymptomColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dismenore')) return Colors.pink;
    if (lower.contains('mood')) return Colors.purple;
    if (lower.contains('5l')) return Colors.blue;
    if (lower.contains('kram')) return Colors.orange;
    return Colors.pink;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gejala yang Dialami',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: details
                    .map(
                      (item) => Chip(
                        backgroundColor: _getSymptomColor(
                          item.symptomName,
                        ).withOpacity(0.1),
                        label: item.selectedOption != null
                            ? Text(
                                '${item.symptomName} (${item.selectedOption})',
                              )
                            : Text(item.symptomName),
                        labelStyle: TextStyle(
                          color: _getSymptomColor(item.symptomName),
                          fontWeight: FontWeight.w600,
                        ),
                        avatar: Icon(
                          _getSymptomIcon(item.symptomName),
                          color: _getSymptomColor(item.symptomName),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationsList extends StatelessWidget {
  final List<Recommendation> recommendations;

  const _RecommendationsList({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rekomendasi Penanganan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recommendations.map(
              (rec) => _RecommendationItem(recommendation: rec),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final Recommendation recommendation;

  const _RecommendationItem({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recommendation.forSymptom.isNotEmpty) ...[
            Text(
              recommendation.forSymptom,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            recommendation.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (recommendation.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(recommendation.description),
          ],
          if (recommendation.videoUrl != null &&
              recommendation.videoUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _YouTubeVideoButton(
              url: recommendation.videoUrl!,
              title: recommendation.title,
            ),
          ],
        ],
      ),
    );
  }
}

class _YouTubeVideoButton extends StatelessWidget {
  final String url;
  final String title;

  const _YouTubeVideoButton({required this.url, required this.title});

  Future<void> _launchYouTube(BuildContext context) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka YouTube')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchYouTube(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.play_circle_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final String notes;

  const _NotesSection({required this.notes});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catatan Pengguna',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(notes),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.pink),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

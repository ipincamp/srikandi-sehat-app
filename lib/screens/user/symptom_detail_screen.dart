import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_log_get_detail.dart';

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
    Future.microtask(() =>
        Provider.of<SymptomDetailProvider>(context, listen: false)
            .fetchDetail(widget.symptomId));
  }

  // Mapping icon untuk nama gejala tertentu
  IconData getSymptomIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('kram')) return Icons.soup_kitchen;
    if (lower.contains('mual')) return Icons.sick;
    if (lower.contains('pusing')) return Icons.blur_on;
    if (lower.contains('5l')) return Icons.bed;
    if (lower.contains('mood')) return Icons.mood_bad;
    return Icons.healing;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SymptomDetailProvider>(context);
    final detail = provider.detail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Gejala',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text('Tanggal: ${detail.logDate}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // Gejala
                      const Text('Gejala yang Dialami:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.grey[200],
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: detail.loggedSymptoms
                              .map((e) => Chip(
                                    color: WidgetStateProperty.all(
                                        Colors.transparent),
                                    label: Text(e),
                                    avatar: Icon(getSymptomIcon(e), size: 20),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Rekomendasi
                      const Text('Rekomendasi Penanganan:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...detail.recommendations.map((rec) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Icon(getSymptomIcon(rec.symptomName),
                                  size: 32),
                              title: Text(rec.symptomName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(rec.recommendationText),
                            ),
                          )),

                      // Catatan
                      if (detail.notes != null) ...[
                        const SizedBox(height: 24),
                        const Text('Catatan Pengguna:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(detail.notes!,
                              style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

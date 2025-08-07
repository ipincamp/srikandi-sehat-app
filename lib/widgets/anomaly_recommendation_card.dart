import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/cycle_provider.dart';

class AnomalyRecommendationCard extends StatefulWidget {
  const AnomalyRecommendationCard({super.key});

  @override
  State<AnomalyRecommendationCard> createState() =>
      _AnomalyRecommendationCardState();
}

class _AnomalyRecommendationCardState extends State<AnomalyRecommendationCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final flags = cycleProvider.notificationFlags;

    final hasAnomaly = flags['period_is_prolonged'] == true ||
        flags['period_is_short'] == true ||
        flags['cycle_is_late'] == true ||
        flags['cycle_is_short'] == true;

    if (!hasAnomaly) return const SizedBox.shrink();

    return Column(
      children: [
        // Header yang bisa diklik
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Icon(Icons.warning_rounded, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Peringatan Kesehatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const Spacer(),
                Badge(
                  backgroundColor: Colors.red.shade100,
                  textColor: Colors.red,
                  label: Text(_countAnomalies(flags).toString()),
                ),
              ],
            ),
          ),
        ),

        // Konten yang bisa di-expand/collapse
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.all(
                Radius.circular(12),
              ),
              border: Border.all(color: Colors.orange.shade200),
            ),
            clipBehavior: Clip.antiAlias,
            child:
                _isExpanded ? _buildContent(flags) : const SizedBox(height: 0),
          ),
        ),
      ],
    );
  }

  int _countAnomalies(Map<String, dynamic> flags) {
    return [
      flags['period_is_prolonged'],
      flags['period_is_short'],
      flags['cycle_is_late'],
      flags['cycle_is_short'],
    ].where((e) => e == true).length;
  }

  Widget _buildContent(Map<String, dynamic> flags) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian diagnosis anomali
          if (flags['period_is_prolonged'] == true)
            _buildAnomalyAlert(
              "Durasi Haid Panjang",
              "Menstruasi lebih dari 7 hari",
              Colors.red,
            ),

          if (flags['period_is_short'] == true)
            _buildAnomalyAlert(
              "Durasi Haid Pendek",
              "Menstruasi kurang dari 3 hari",
              Colors.blue,
            ),

          if (flags['cycle_is_late'] == true)
            _buildAnomalyAlert(
              "Siklus Terlambat",
              "Terlambat lebih dari 7 hari",
              Colors.purple,
            ),

          if (flags['cycle_is_short'] == true)
            _buildAnomalyAlert(
              "Siklus Pendek",
              "Siklus kurang dari 21 hari",
              Colors.green,
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Rekomendasi
          _buildRecommendationSection(),
        ],
      ),
    );
  }

  Widget _buildAnomalyAlert(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 2),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekomendasi:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
          ),
        ),
        const SizedBox(height: 8),
        _buildAdviceItem('🏋️ Latihan ringan 30 menit/hari'),
        _buildAdviceItem('🥗 Konsumsi makanan kaya zat besi dan omega-3'),
        _buildAdviceItem('💧 Minum 2-3L air putih sehari'),
        _buildAdviceItem('😴 Tidur 7-9 jam dengan kualitas baik'),
        _buildAdviceItem('🧘 Lakukan relaksasi untuk mengurangi stres'),
        const SizedBox(height: 12),
        Text(
          'Segera ke dokter jika:',
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildAdviceItem('• Nyeri tidak tertahankan'),
        _buildAdviceItem('• Perdarahan sangat deras'),
        _buildAdviceItem('• Gejala berlangsung >3 siklus'),
      ],
    );
  }

  Widget _buildAdviceItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

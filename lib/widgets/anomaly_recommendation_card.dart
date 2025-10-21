import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/cycle_status_model.dart';
import 'package:app/provider/cycle_provider.dart';

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
    final cycleStatus = cycleProvider.cycleStatus;

    final hasAnomaly =
        flags['period_is_prolonged'] == true ||
        flags['period_is_short'] == true ||
        flags['cycle_is_late'] == true ||
        flags['cycle_is_short'] == true ||
        cycleStatus?.isPeriodNormal == false ||
        cycleStatus?.isCycleNormal == false;

    if (!hasAnomaly) return const SizedBox.shrink();

    return Column(
      children: [
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
                  label: Text(_countAnomalies(flags, cycleStatus).toString()),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              border: Border.all(color: Colors.orange.shade200),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isExpanded
                ? _buildContent(flags, cycleStatus)
                : const SizedBox(height: 0),
          ),
        ),
      ],
    );
  }

  int _countAnomalies(Map<String, dynamic> flags, CycleStatus? cycleStatus) {
    int count = [
      flags['period_is_prolonged'],
      flags['period_is_short'],
      flags['cycle_is_late'],
      flags['cycle_is_short'],
    ].where((e) => e == true).length;

    if (cycleStatus?.isPeriodNormal == false) count++;
    if (cycleStatus?.isCycleNormal == false) count++;

    return count;
  }

  Widget _buildContent(Map<String, dynamic> flags, CycleStatus? cycleStatus) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Duration Anomalies
          if (flags['period_is_prolonged'] == true ||
              cycleStatus?.isPeriodNormal == false)
            _buildDurationAlert(
              "Durasi Haid",
              "Durasi saat ini: ${cycleStatus?.lastPeriodLength ?? cycleStatus?.currentPeriodDay} hari",
              "Durasi normal: 3-7 hari",
              Colors.red,
              isAbnormal: true,
            ),

          if (flags['period_is_short'] == true)
            _buildDurationAlert(
              "Durasi Haid Pendek",
              "Durasi saat ini: ${cycleStatus?.lastPeriodLength ?? cycleStatus?.currentPeriodDay} hari",
              "Durasi normal: Minimal 3 hari",
              Colors.blue,
              isAbnormal: true,
            ),

          // Cycle Length Anomalies
          if (flags['cycle_is_late'] == true ||
              flags['cycle_is_short'] == true ||
              cycleStatus?.isCycleNormal == false)
            _buildDurationAlert(
              "Panjang Siklus",
              "Siklus saat ini: ${cycleStatus?.lastCycleLength ?? cycleStatus?.currentPeriodDay} hari",
              "Siklus normal: 21-35 hari",
              Colors.purple,
              isAbnormal: !(cycleStatus?.isCycleNormal ?? true),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Rekomendasi spesifik berdasarkan durasi
          _buildDurationSpecificRecommendations(cycleStatus),
        ],
      ),
    );
  }

  Widget _buildDurationAlert(
    String title,
    String currentDuration,
    String normalDuration,
    Color color, {
    bool isAbnormal = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8, top: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isAbnormal ? color : Colors.green,
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
                        color: isAbnormal ? color : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(currentDuration, style: const TextStyle(fontSize: 13)),
                    Text(
                      normalDuration,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isAbnormal) const SizedBox(height: 8),
          if (isAbnormal)
            Text(
              _getDurationAdvice(title, currentDuration),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  String _getDurationAdvice(String title, String currentDuration) {
    if (title.contains("Durasi Haid")) {
      return "• Perbanyak konsumsi makanan kaya zat besi\n• Hindari aktivitas berat selama menstruasi";
    } else if (title.contains("Panjang Siklus")) {
      return "• Catat siklus menstruasi secara teratur\n• Kelola stres dengan teknik relaksasi";
    }
    return "• Konsultasikan dengan dokter kandungan";
  }

  Widget _buildDurationSpecificRecommendations(CycleStatus? cycleStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekomendasi Berdasarkan Durasi:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
          ),
        ),
        const SizedBox(height: 8),

        if (cycleStatus?.lastPeriodLength != null)
          _buildAdviceItem(
            '📆 Durasi haid terakhir: ${cycleStatus!.lastPeriodLength} hari '
            '(${cycleStatus.lastPeriodLength! < 3
                ? "Pendek"
                : cycleStatus.lastPeriodLength! > 7
                ? "Panjang"
                : "Normal"})',
          ),

        if (cycleStatus?.lastCycleLength != null)
          _buildAdviceItem(
            '🔄 Panjang siklus terakhir: ${cycleStatus!.lastCycleLength} hari '
            '(${cycleStatus.lastCycleLength! < 21
                ? "Pendek"
                : cycleStatus.lastCycleLength! > 35
                ? "Panjang"
                : "Normal"})',
          ),

        if (cycleStatus?.currentPeriodDay != null)
          _buildAdviceItem(
            '⏳ Hari menstruasi saat ini: ${cycleStatus!.currentPeriodDay}',
          ),

        if (cycleStatus?.daysUntilNextPeriod != null)
          _buildAdviceItem(
            '⏱ Perkiraan menstruasi berikutnya: ${cycleStatus!.daysUntilNextPeriod} hari lagi',
          ),

        const SizedBox(height: 12),
        Text(
          'Tips Menjaga Siklus Sehat:',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildAdviceItem(
          '• Konsumsi makanan seimbang dengan zat besi dan vitamin B',
        ),
        _buildAdviceItem('• Olahraga teratur 3-5 kali seminggu'),
        _buildAdviceItem('• Tidur cukup 7-9 jam per hari'),
        _buildAdviceItem('• Kelola stres dengan meditasi atau yoga'),
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
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

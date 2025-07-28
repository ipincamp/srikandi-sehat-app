// widgets/cycle_status_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/cycle_provider.dart';

class CycleStatusCard extends StatelessWidget {
  const CycleStatusCard({super.key});

  String _getPhaseText(bool isMenstruating, String? periodStatus) {
    if (isMenstruating) return 'Fase Menstruasi';
    if (periodStatus == 'follicular') return 'Fase Folikular';
    if (periodStatus == 'ovulation') return 'Fase Ovulasi';
    if (periodStatus == 'luteal') return 'Fase Luteal';
    return 'Fase Luteal'; // Default
  }

  String _getStatusText(bool isMenstruating, int? day) {
    if (isMenstruating) {
      return 'Menstruasi sedang berlangsung';
    }
    return 'Menstruasi Berikutnya dalam:';
  }

  String _getDayText(bool isMenstruating, int? day) {
    if (isMenstruating) {
      return day != null ? 'Hari ke-$day' : 'Hari ke-1';
    }
    return day != null ? '$day Hari' : '--';
  }

  double _getProgressValue(bool isMenstruating, int? day, int? totalDays) {
    if (isMenstruating) {
      if (day == null || totalDays == null || totalDays == 0) return 0.2;
      return day / totalDays;
    }
    // For non-menstruating, we'll use a fixed value as in the original
    return 0.75;
  }

  String _getProgressText(bool isMenstruating, int? day, int? totalDays) {
    if (isMenstruating) {
      if (day == null || totalDays == null || totalDays == 0) return '20%';
      return '${((day / totalDays) * 100).round()}%';
    }
    return '75%'; // Fixed value as in original
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final isMenstruating = cycleProvider.isMenstruating;
    final cycleStatus = cycleProvider.cycleStatus;

    final phaseText = _getPhaseText(isMenstruating, cycleStatus?.periodStatus);
    final statusText = _getStatusText(
      isMenstruating,
      isMenstruating
          ? cycleStatus?.periodLengthDays
          : cycleStatus?.cycleDurationDays,
    );
    final dayText = _getDayText(
      isMenstruating,
      isMenstruating
          ? cycleStatus?.periodLengthDays
          : cycleStatus?.cycleDurationDays,
    );
    final progressValue = _getProgressValue(
      isMenstruating,
      isMenstruating ? cycleStatus?.periodLengthDays : null,
      isMenstruating ? 7 : null, // Assuming 7 days for menstruation
    );
    final progressText = _getProgressText(
      isMenstruating,
      isMenstruating ? cycleStatus?.periodLengthDays : null,
      isMenstruating ? 7 : null, // Assuming 7 days for menstruation
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perkiraan Hari Ini:',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            phaseText,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progressValue,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.pink.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.pink,
                      ),
                    ),
                  ),
                  Text(
                    progressText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

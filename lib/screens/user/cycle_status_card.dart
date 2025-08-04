// widgets/cycle_status_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/cycle_provider.dart';

class CycleStatusCard extends StatelessWidget {
  const CycleStatusCard({super.key});

  String _getPhaseText(String? cycleStatus, String? periodStatus) {
    if (periodStatus?.toLowerCase() == 'pendek' ||
        periodStatus?.toLowerCase() == 'panjang' ||
        periodStatus?.toLowerCase() == 'menstruating') {
      return 'Fase Menstruasi';
    }
    if (cycleStatus?.toLowerCase() == 'polimenorea') return 'Fase Polimenorea';
    if (cycleStatus?.toLowerCase() == 'oligomenorea') {
      return 'Fase Oligomenorea';
    }
    if (cycleStatus?.toLowerCase() == 'amenorea') return 'Fase Amenorea';
    return 'Fase Normal'; // Default
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
      return (day / totalDays).clamp(0.0, 1.0); // Ensure value is between 0-1
    }
    // For non-menstruating, show progress based on cycle duration
    if (day != null && totalDays != null && totalDays > 0) {
      return (day / totalDays).clamp(0.0, 1.0);
    }
    return 0.75; // Default value if no cycle data
  }

  String _getProgressText(bool isMenstruating, int? day, int? totalDays) {
    if (isMenstruating) {
      if (day == null || totalDays == null || totalDays == 0) return '20%';
      return '${((day / totalDays) * 100).round()}%';
    }
    // For non-menstruating
    if (day != null && totalDays != null && totalDays > 0) {
      return '${((day / totalDays) * 100).round()}%';
    }
    return '75%'; // Default value
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final isMenstruating = cycleProvider.isMenstruating;
    final cycleStatus = cycleProvider.cycleStatus;

    final phaseText =
        _getPhaseText(cycleStatus?.cycleStatus, cycleStatus?.periodStatus);
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
      isMenstruating
          ? cycleStatus?.periodLengthDays
          : cycleStatus?.cycleDurationDays,
      isMenstruating ? 7 : 28, // 7 days for menstruation, 28 for full cycle
    );
    final progressText = _getProgressText(
      isMenstruating,
      isMenstruating
          ? cycleStatus?.periodLengthDays
          : cycleStatus?.cycleDurationDays,
      isMenstruating ? 7 : 28, // 7 days for menstruation, 28 for full cycle
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
            'Status Siklus Menstruasi:',
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
          if (cycleStatus?.cycleStatus != null) ...[
            const SizedBox(height: 8),
            Text(
              '(${cycleStatus?.cycleStatus})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.pink[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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

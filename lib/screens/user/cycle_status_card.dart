import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/cycle_status_model.dart';
import 'package:srikandi_sehat_app/provider/cycle_provider.dart';

class CycleStatusCard extends StatelessWidget {
  const CycleStatusCard({super.key});

  bool _hasNoCycleData(CycleStatus? status) {
    return status != null &&
        status.message != null &&
        status.message!.contains("No cycle data") &&
        status.currentPeriodDay == null &&
        status.daysUntilNextPeriod == null &&
        status.lastCycleLength == null &&
        status.lastPeriodLength == null;
  }

  String _getPhaseText(CycleStatus? status) {
    if (status == null) return 'Memuat...';
    if (_hasNoCycleData(status)) return 'Belum Ada Data Siklus';

    if (status.isOnCycle && status.isMenstruating) {
      return 'Fase Menstruasi';
    }
    if (status.isCycleNormal == false) {
      return 'Fase Tidak Normal';
    }
    if (status.isPeriodNormal == false) {
      return 'Fase Menstruasi Tidak Normal';
    }
    if (!status.isOnCycle) {
      return status.daysUntilNextPeriod != null
          ? 'Fase Folikular'
          : 'Fase Luteal';
    }
    return 'Fase Normal';
  }

  String _getStatusText(CycleStatus? status) {
    if (status == null) return 'Memuat status...';
    if (_hasNoCycleData(status))
      return status.message ?? 'Belum ada data siklus';

    return status.message ??
        (status.isOnCycle
            ? 'Sedang dalam siklus menstruasi'
            : status.daysUntilNextPeriod != null
            ? 'Menuju menstruasi berikutnya'
            : 'Masa subur / Fase luteal');
  }

  String _getDayText(CycleStatus? status) {
    if (status == null) return '...';
    if (_hasNoCycleData(status)) return '-';

    if (status.isOnCycle && status.currentPeriodDay != null) {
      return 'Hari ke-${status.currentPeriodDay}';
    }
    if (!status.isOnCycle && status.daysUntilNextPeriod != null) {
      return '${status.daysUntilNextPeriod} hari lagi';
    }
    if (status.lastCycleLength != null) {
      return 'Siklus ${status.lastCycleLength} hari';
    }
    return 'Siklus Normal';
  }

  double _getProgressValue(CycleStatus? status) {
    if (status == null || _hasNoCycleData(status)) return 0.0;

    // During menstruation
    if (status.isOnCycle &&
        status.currentPeriodDay != null &&
        status.lastPeriodLength != null) {
      return (status.currentPeriodDay! / status.lastPeriodLength!).clamp(
        0.0,
        1.0,
      );
    }

    // During cycle (follicular/luteal phase)
    if (!status.isOnCycle &&
        status.daysUntilNextPeriod != null &&
        status.lastCycleLength != null) {
      final daysPassed = status.lastCycleLength! - status.daysUntilNextPeriod!;
      return (daysPassed / status.lastCycleLength!).clamp(0.0, 1.0);
    }

    return 0.0;
  }

  String _getProgressText(CycleStatus? status) {
    if (_hasNoCycleData(status)) return '-';

    final value = _getProgressValue(status);
    if (value == 0.0) return '-';

    if (status?.isOnCycle == true) {
      return '${(value * 100).round()}% selesai';
    } else {
      return '${((1 - value) * 100).round()}% menuju haid';
    }
  }

  Color _getProgressColor(CycleStatus? status) {
    if (status == null || _hasNoCycleData(status)) return Colors.pink;

    if (status.isOnCycle) {
      return Colors.pink;
    } else if (status.daysUntilNextPeriod != null &&
        status.daysUntilNextPeriod! <= 7) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<CycleProvider>(context);
    final status = statusProvider.cycleStatus;
    final noCycleData = _hasNoCycleData(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: noCycleData ? Colors.grey.shade200 : Colors.pink.shade50,
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
            style: TextStyle(
              fontSize: 16,
              color: noCycleData ? Colors.grey : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPhaseText(status),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: noCycleData ? Colors.grey : Colors.pink,
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
                      _getStatusText(status),
                      style: TextStyle(
                        fontSize: 14,
                        color: noCycleData ? Colors.grey : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDayText(status),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: noCycleData ? Colors.grey : Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),
              if (!noCycleData)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _getProgressValue(status),
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.pink.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(status),
                        ),
                      ),
                    ),
                    Text(
                      _getProgressText(status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(status),
                      ),
                    ),
                  ],
                ),
              if (noCycleData)
                const Icon(Icons.error_outline, size: 40, color: Colors.grey),
            ],
          ),
          if (statusProvider.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

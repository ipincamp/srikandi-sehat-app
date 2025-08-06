// widgets/cycle_status_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
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

  String _getStatusText(bool isMenstruating) {
    if (isMenstruating) {
      return 'Menstruasi sedang berlangsung';
    }
    return 'Masa Subur / Fase Luteal'; // Teks default jika tidak menstruasi
  }

  String _getDayText(bool isMenstruating, int? runningDays) {
    if (isMenstruating) {
      // Gunakan data dari cycle summary
      return runningDays != null ? 'Hari ke-$runningDays' : 'Memproses...';
    }
    // Teks jika tidak sedang menstruasi
    return 'Siklus Normal';
  }

  double _getProgressValue(int? day, int? totalDays) {
    if (day == null || totalDays == null || totalDays == 0) return 0.0;
    final double progress = day / totalDays;
    // Gunakan .clamp() untuk membatasi nilai antara 0.0 dan 1.0
    return progress.clamp(0.0, 1.0);
  }

  String _getProgressText(int? day, int? totalDays) {
    if (day == null || totalDays == null || totalDays == 0) return '0%';
    final rawPercentage = (day / totalDays) * 100;
    // Gunakan min() untuk memastikan nilai tidak lebih dari 100
    final displayPercentage = min(100, rawPercentage.round());
    return '$displayPercentage%';
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final isMenstruating = cycleProvider.isMenstruating;

    final runningDays = cycleProvider.activeCycleRunningDays;
    final phaseText = _getPhaseText(cycleProvider.cycleStatus?.cycleStatus,
        cycleProvider.cycleStatus?.periodStatus);
    final statusText = _getStatusText(isMenstruating);
    final dayText = _getDayText(isMenstruating, runningDays);

    // --- PERBAIKAN LOGIKA DI SINI ---
    final double progressValue;
    final String progressText;

    // Hanya hitung progres jika sedang menstruasi
    if (isMenstruating) {
      // Asumsi periode menstruasi normal adalah 7 hari untuk progress bar
      progressValue = _getProgressValue(runningDays, 7);
      progressText = _getProgressText(runningDays, 7);
    } else {
      // Jika tidak menstruasi, paksa progres menjadi 0
      progressValue = 0.0;
      progressText = '0%';
    }

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
          // ... (Teks (cycleStatus) tidak perlu diubah)
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText, // Menggunakan variabel yang sudah diperbarui
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayText, // Menggunakan variabel yang sudah diperbarui
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

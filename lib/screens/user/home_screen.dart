import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/cycle_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/cycle_action_button.dart';
import 'package:srikandi_sehat_app/widgets/log_symptom_button.dart';
import 'package:srikandi_sehat_app/widgets/reminder_tile.dart';
import 'package:srikandi_sehat_app/widgets/tips_education_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
    // context.read<CycleProvider>().loadCycleStatus();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<SymptomProvider>(context, listen: false).fetchSymptoms();
    // });
  }

  Future<void> _initializeData() async {
    try {
      // Load cycle status first
      await context.read<CycleProvider>().loadCycleStatus();

      // Then load symptoms
      await Provider.of<SymptomProvider>(context, listen: false)
          .fetchSymptoms();
    } catch (e) {
      if (mounted) {
        CustomAlert.show(context, 'Gagal memuat data: ${e.toString()}');
      }
    }
  }

  // Handler: mulai siklus
  Future<void> _handleStartCycle() async {
    try {
      await context.read<CycleProvider>().startCycle();
      if (mounted) {
        CustomAlert.show(context, 'Siklus menstruasi dimulai!',
            type: AlertType.success);
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.show(context, 'Gagal memulai siklus.',
            type: AlertType.error);
      }
    }
  }

  // Handler: akhiri siklus
  Future<void> _handleEndCycle() async {
    try {
      await context.read<CycleProvider>().endCycle();
      if (mounted) {
        CustomAlert.show(context, 'Siklus menstruasi diakhiri!',
            type: AlertType.success);
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.show(context, 'Gagal mengakhiri siklus.',
            type: AlertType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMenstruating = context.watch<CycleProvider>().isMenstruating;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'SriKandi Sehat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, User!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),

            // Kartu Informasi Siklus
            Container(
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
                    isMenstruating ? 'Fase Menstruasi' : 'Fase Luteal',
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
                              isMenstruating
                                  ? 'Menstruasi sedang berlangsung'
                                  : 'Menstruasi Berikutnya dalam:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isMenstruating ? 'Hari ke-2' : '5 Hari',
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
                              value: isMenstruating ? 0.2 : 0.75,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.pink.shade100,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.pink,
                              ),
                            ),
                          ),
                          Text(
                            isMenstruating ? '20%' : '75%',
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
            ),
            const SizedBox(height: 20),

            Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CycleActionButtons(
                    onStart: !isMenstruating ? _handleStartCycle : () {},
                    onEnd: isMenstruating ? _handleEndCycle : () {},
                    isMenstruating:
                        isMenstruating, // Gunakan nilai dari provider
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  flex: 1,
                  child: LogSymptomButton(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'Tips & Edukasi Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            const TipsEducationList(),
            const SizedBox(height: 20),
            Text(
              'Pengingat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            ReminderTile(message: 'Jangan lupa minum air cukup hari ini!'),
          ],
        ),
      ),
    );
  }
}

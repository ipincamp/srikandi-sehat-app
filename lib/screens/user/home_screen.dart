import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/provider/cycle_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_get_provider.dart';
import 'package:srikandi_sehat_app/screens/user/cycle_status_card.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_popup.dart';
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
  bool _showProfileCard = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkProfileStatus();
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

  Future<void> _checkProfileStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showProfileCard = !(prefs.getBool('hasProfile') ?? false);
    });
  }

  Future<void> _handleStartCycle() async {
    final confirmed = await CustomConfirmationPopup.show(
      context,
      title: 'Mulai Siklus Menstruasi',
      message: 'Apakah Anda yakin ingin memulai siklus menstruasi?',
      confirmText: 'Mulai',
      cancelText: 'Batal',
      confirmColor: Colors.pink,
      icon: Icons.play_circle_fill,
    );

    if (confirmed != true) return;

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

  Future<void> _handleEndCycle() async {
    final confirmed = await CustomConfirmationPopup.show(
      context,
      title: 'Akhiri Siklus Menstruasi',
      message: 'Apakah Anda yakin ingin mengakhiri siklus menstruasi?',
      confirmText: 'Akhiri',
      cancelText: 'Batal',
      confirmColor: Colors.pink,
      icon: Icons.stop_circle,
    );

    if (confirmed != true) return;

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

  Widget _buildProfileCompletionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/edit-profile').then((_) async {
          await _checkProfileStatus();
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lengkapi Profil Anda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Silakan lengkapi data profil Anda untuk melanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.orange.shade600),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMenstruating = context.watch<CycleProvider>().isMenstruating;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'SriKandi Sehat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (_showProfileCard) _buildProfileCompletionCard(),
            const SizedBox(height: 4),
            const CycleStatusCard(),
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
                    isMenstruating: isMenstruating,
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
            const ReminderTile(
                message: 'Jangan lupa minum air cukup hari ini!'),
          ],
        ),
      ),
    );
  }
}

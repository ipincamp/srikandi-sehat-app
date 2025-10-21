import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/provider/cycle_provider.dart';
import 'package:app/provider/symptom_log_get_provider.dart';
import 'package:app/screens/user/cycle_status_card.dart';
import 'package:app/widgets/anomaly_recommendation_card.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:app/widgets/custom_popup.dart';
import 'package:app/widgets/cycle_action_button.dart';
import 'package:app/widgets/log_symptom_button.dart';
import 'package:app/widgets/notification_icon_button.dart';
import 'package:app/widgets/reminder_tile.dart';
import 'package:app/widgets/tips_education_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showProfileCard = false;
  bool _useCustomStartDate = false;
  bool _useCustomEndDate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _checkProfileStatus();
    });
  }

  Future<void> _initializeData() async {
    try {
      await context.read<CycleProvider>().synchronizeState();
      await Provider.of<SymptomProvider>(
        context,
        listen: false,
      ).fetchSymptoms();
    } catch (e) {
      if (mounted) {
        CustomAlert.show(context, 'Gagal memuat data: ${e.toString()}');
      }
    }
  }

  Future<void> _checkProfileStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showProfileCard = !(prefs.getBool('profile_complete') ?? false);
    });
  }

  Future<void> _handleStartCycle() async {
    DateTime selectedDate = DateTime.now();

    if (_useCustomStartDate) {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now(),
        helpText: 'Pilih tanggal mulai menstruasi',
        cancelText: 'Batal',
        confirmText: 'Pilih',
      );

      if (pickedDate == null) return;
      selectedDate = pickedDate;
    }

    final confirmed = await CustomConfirmationPopup.show(
      context,
      title: 'Mulai Siklus Menstruasi',
      message:
          'Apakah Anda yakin ingin memulai siklus menstruasi${_useCustomStartDate ? ' pada ${DateFormat('dd MMMM yyyy').format(selectedDate)}' : ' sekarang'}?',
      confirmText: 'Mulai',
      cancelText: 'Batal',
      confirmColor: Colors.pink,
      icon: Icons.play_circle_fill,
      additionalWidget: CheckboxListTile(
        title: const Text(
          'Apakah Awal Menstruasi Sudah Terlewat? Pilih tanggal',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        value: _useCustomStartDate,
        onChanged: (value) {
          setState(() {
            _useCustomStartDate = value ?? false;
          });
          Navigator.of(context).pop(); // Close the dialog
          _handleStartCycle(); // Restart the process
        },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );

    if (confirmed != true) return;

    try {
      final String successMessage = await context
          .read<CycleProvider>()
          .startCycle(selectedDate, context);

      if (mounted) {
        CustomAlert.show(context, successMessage, type: AlertType.success);
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.show(
          context,
          'Gagal memulai siklus.',
          type: AlertType.error,
        );
      }
    }
  }

  Future<void> _handleEndCycle() async {
    DateTime selectedDate = DateTime.now();

    if (_useCustomEndDate) {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now(),
        helpText: 'Pilih tanggal selesai menstruasi',
        cancelText: 'Batal',
        confirmText: 'Pilih',
      );

      if (pickedDate == null) return;
      selectedDate = pickedDate;
    }

    final confirmed = await CustomConfirmationPopup.show(
      context,
      title: 'Akhiri Siklus Menstruasi',
      message:
          'Apakah Anda yakin ingin mengakhiri siklus menstruasi${_useCustomEndDate ? ' pada ${DateFormat('dd MMMM yyyy').format(selectedDate)}' : ' sekarang'}?',
      confirmText: 'Akhiri',
      cancelText: 'Batal',
      confirmColor: Colors.pink,
      icon: Icons.stop_circle,
      additionalWidget: CheckboxListTile(
        title: const Text(
          'Apakah Akhir Menstruasi Sudah Terlewat? Pilih tanggal',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        value: _useCustomEndDate,
        onChanged: (value) {
          setState(() {
            _useCustomEndDate = value ?? false;
          });
          Navigator.of(context).pop(); // Close the dialog
          _handleEndCycle(); // Restart the process
        },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<CycleProvider>().endCycle(selectedDate, context);
      if (mounted) {
        CustomAlert.show(
          context,
          'Siklus menstruasi diakhiri!',
          type: AlertType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.show(
          context,
          'Gagal mengakhiri siklus.',
          type: AlertType.error,
        );
      }
    }
  }

  Widget _buildProfileCompletionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/edit-profile');
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

  Widget _buildAnomalyNotifications() {
    final cycleProvider = context.watch<CycleProvider>();
    final flags = cycleProvider.notificationFlags;

    if (cycleProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (flags.isEmpty) {
      return const ReminderTile(
        message: 'Tidak ada menstruasi dan siklus yang terganggu',
      ); // Jangan tampilkan apa-apa jika tidak ada data
    }

    final List<Widget> notifications = [];

    if (flags['period_is_prolonged'] == true) {
      notifications.add(
        const ReminderTile(
          message:
              'Peringatan: Durasi menstruasi Anda lebih lama dari biasanya.',
        ),
      );
    }
    if (flags['period_is_short'] == true) {
      notifications.add(
        const ReminderTile(
          message: 'Info: Durasi menstruasi Anda lebih pendek dari biasanya.',
        ),
      );
    }
    if (flags['cycle_is_late'] == true) {
      notifications.add(
        const ReminderTile(
          message:
              'Peringatan: Siklus Anda terlambat. Pertimbangkan tes kehamilan.',
        ),
      );
    }
    if (flags['cycle_is_short'] == true) {
      notifications.add(
        const ReminderTile(
          message: 'Info: Siklus Anda lebih pendek dari biasanya.',
        ),
      );
    }

    if (notifications.isEmpty) {
      return const ReminderTile(
        message: 'Siklus Anda terpantau normal. Tetap jaga kesehatan!',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: notifications
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: item,
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final isOnCycle = cycleProvider.isOnCycle;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Srikandi Sehat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.pink,
        actions: [
         const NotificationIconButton(),
        ],
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
            const SizedBox(height: 10),
            const AnomalyRecommendationCard(),
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
                    onStart: !isOnCycle ? () => _handleStartCycle() : null,
                    onEnd: isOnCycle ? () => _handleEndCycle() : null,
                    isMenstruating:
                        cycleProvider.cycleStatus?.isMenstruating ?? false,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(flex: 1, child: SymptomLogButton()),
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
            // Ganti ReminderTile yang lama dengan widget baru kita
            _buildAnomalyNotifications(),
          ],
        ),
      ),
    );
  }
}

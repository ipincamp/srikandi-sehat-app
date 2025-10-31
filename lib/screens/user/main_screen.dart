import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/screens/user/education_screen.dart';
import 'package:app/screens/user/home_screen.dart';
import 'package:app/screens/user/profile_screen.dart';
import 'package:app/screens/user/support_screen.dart';
import 'package:app/screens/user/cycle_tracking_screen.dart';
import 'package:app/widgets/health_tips_modal.dart';
import 'package:app/widgets/navbar_button.dart';

class User {
  final String id;
  final String email;
  User({required this.id, required this.email});
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _slideController;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CycleTrackingScreen(),
    EducationScreen(),
    SupportScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _checkShowModalOnLogin();

    // WidgetsBinding.instance.addObserver(this);
    _checkAndRequestNotificationPermissionWithHandler();
  }

  @override
  void dispose() {
    _slideController.dispose();
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /* DEPRECATED: Using lifecycle state changes to check permissions can lead to repetitive prompts.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print("App resumed, checking permissions...");
      }
      _checkAndRequestNotificationPermissionWithHandler();
    }
  }
  */

  Future<void> _checkAndRequestNotificationPermissionWithHandler() async {
    if (!mounted) return;

    PermissionStatus status = await Permission.notification.status;
    if (kDebugMode) {
      print('Notification permission status (handler): $status');
    }

    if (!mounted) return;

    if (status.isDenied) {
      // Jika denied (belum pernah diminta atau ditolak sekali)
      if (kDebugMode) {
        print('Requesting notification permission (handler)...');
      }
      status = await Permission.notification.request();
      if (kDebugMode) {
        print('Permission requested. New status (handler): $status');
      }
      if (status.isPermanentlyDenied && mounted) {
        if (kDebugMode) {
          print('Permission permanently denied. Showing guidance.');
        }
        // Ditolak permanen (pengguna memilih "Jangan tanya lagi")
        _showSettingsGuidance();
      }
    } else if (status.isPermanentlyDenied) {
      if (kDebugMode) {
        print('Permission is permanently denied. Showing guidance.');
      }
      // Sudah ditolak permanen sebelumnya
      _showSettingsGuidance();
    } else if (status.isGranted) {
      if (kDebugMode) {
        print('Permission already granted (handler).');
      }
      // Izin sudah diberikan
    }
  }

  void _showSettingsGuidance() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aktifkan Izin Notifikasi'),
        content: const Text(
          'Izin notifikasi telah dinonaktifkan. Untuk menerima pembaruan, aktifkan izin notifikasi untuk aplikasi ini di Pengaturan perangkat Anda.',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text('Buka Pengaturan'),
            onPressed: () async {
              await openAppSettings();
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      _slideController.forward().then((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = index;
          });
        }
        _slideController.reverse();
      });
    }
  }

  Future<void> _checkShowModalOnLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final shouldShowModal = prefs.getBool('showLoginModal') ?? false;

    if (shouldShowModal && mounted) {
      await prefs.setBool('showLoginModal', false);

      // Delay sebentar agar context aman dipakai
      Future.delayed(Duration.zero, () {
        if (mounted) {
          HealthTipsModal.show(context, 'Kebersihan Diri', [
            'Mengganti pembalut sebanyak 3-5 kali dalam sehari.',
            'Membersihkan organ intim terlebih dulu sebelum mengganti pembalut.',
            'Cuci tangan sampai bersih usai membuang pembalut serta sebelum mengganti pembalut.',
            'Rutin mengganti celana dalam untuk menghindari resiko tidak nyaman di area kewanitaan. Pastikan memakai celana dalam yang terbuat dari bahan yang menyerap keringat.',
            'Menjaga kebersihan badan dengan mandi, keramas, dan potong kuku/ menjaga kebersihan kuku.',
          ]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarButton(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Beranda',
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                NavBarButton(
                  index: 1,
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month,
                  label: 'Pelacak',
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                NavBarButton(
                  index: 2,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: 'Edukasi',
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onItemTapped(2),
                ),
                NavBarButton(
                  index: 3,
                  icon: Icons.support_agent_outlined,
                  activeIcon: Icons.support_agent,
                  label: 'Dukungan',
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),
                NavBarButton(
                  index: 4,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profil',
                  isSelected: _selectedIndex == 4,
                  onTap: () => _onItemTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

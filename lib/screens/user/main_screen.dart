import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/screens/user/education_screen.dart';
import 'package:srikandi_sehat_app/screens/user/home_screen.dart';
import 'package:srikandi_sehat_app/screens/user/profile_screen.dart';
import 'package:srikandi_sehat_app/screens/user/support_screen.dart';
import 'package:srikandi_sehat_app/screens/user/tracker_screen.dart';
import 'package:srikandi_sehat_app/widgets/image_modal.dart';
import 'package:srikandi_sehat_app/widgets/navbar_button.dart'; // Import reusable NavBarButton

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

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _slideController;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TrackerScreen(),
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
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      _slideController.forward().then((_) {
        setState(() {
          _selectedIndex = index;
        });
        _slideController.reverse();
      });
    }
  }

  Future<void> _checkShowModalOnLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final shouldShowModal = prefs.getBool('showLoginModal') ?? false;

    if (shouldShowModal) {
      // Reset flag agar modal hanya muncul sekali
      await prefs.setBool('showLoginModal', false);

      // Delay sebentar agar context aman dipakai
      Future.delayed(Duration.zero, () {
        ImageModal.show(
          context,
          'https://pic.pnnet.dev/256x256',
        );
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

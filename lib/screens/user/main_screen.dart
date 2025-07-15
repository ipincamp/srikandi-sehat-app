import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/screens/user/education_screen.dart';
import 'package:srikandi_sehat_app/screens/user/home_screen.dart';
import 'package:srikandi_sehat_app/screens/user/profile_screen.dart';
import 'package:srikandi_sehat_app/screens/user/support_screen.dart';
import 'package:srikandi_sehat_app/screens/user/tracker_screen.dart';

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
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Beranda'),
                _buildNavItem(1, Icons.calendar_month_outlined,
                    Icons.calendar_month, 'Pelacak'),
                _buildNavItem(
                    2, Icons.menu_book_outlined, Icons.menu_book, 'Edukasi'),
                _buildNavItem(3, Icons.support_agent_outlined,
                    Icons.support_agent, 'Dukungan'),
                _buildNavItem(4, Icons.person_outline, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final bool isSelected = _selectedIndex == index;

    return Flexible(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          constraints: const BoxConstraints(minHeight: 55),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: isSelected
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.pink : Colors.transparent,
              borderRadius: BorderRadius.circular(isSelected ? 28 : 16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.elasticOut,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      key: ValueKey(
                          isSelected ? 'active_$index' : 'inactive_$index'),
                      color: isSelected ? Colors.white : Colors.grey,
                      size: isSelected ? 26 : 20,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: isSelected ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: isSelected ? 0 : null,
                    child: Column(
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

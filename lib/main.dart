import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/provider/cycle_provider.dart';
import 'package:srikandi_sehat_app/provider/district_provider.dart';
import 'package:srikandi_sehat_app/provider/password_provider.dart';
import 'package:srikandi_sehat_app/provider/profile_change_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_log_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_provider.dart';
import 'package:srikandi_sehat_app/provider/user_profile_provider.dart';
import 'package:srikandi_sehat_app/provider/village_provider.dart';

import 'package:srikandi_sehat_app/screens/auth/login_screen.dart';
import 'package:srikandi_sehat_app/screens/auth/register_screen.dart';
import 'package:srikandi_sehat_app/screens/user/change_password.dart' as user;
import 'package:srikandi_sehat_app/screens/user/edit_profile.dart' as user;
import 'package:srikandi_sehat_app/screens/user/home_screen.dart' as user;
import 'package:srikandi_sehat_app/screens/user/main_screen.dart' as user;
import 'package:srikandi_sehat_app/screens/user/profile_screen.dart' as user;
import 'package:srikandi_sehat_app/screens/user/detail_profile.dart' as user;
import 'package:srikandi_sehat_app/screens/user/cycle_history.dart' as user;
import 'package:srikandi_sehat_app/screens/admin/home_screen.dart' as admin;
import 'package:srikandi_sehat_app/screens/admin/main_screen.dart' as admin;
import 'package:srikandi_sehat_app/screens/admin/profile_screen.dart' as admin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final role = prefs.getString('role');

  runApp(
    DevicePreview(
      enabled: true,
      tools: const [
        ...DevicePreview.defaultTools,
      ],
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserProfileProvider()),
          ChangeNotifierProvider(create: (_) => ProfileChangeProvider()),
          ChangeNotifierProvider(create: (_) => DistrictProvider()),
          ChangeNotifierProvider(create: (_) => VillageProvider()),
          ChangeNotifierProvider(create: (_) => PasswordProvider()),
          ChangeNotifierProvider(create: (_) => CycleProvider()),
          ChangeNotifierProvider(create: (_) => SymptomProvider()),
          ChangeNotifierProvider(create: (_) => SymptomLogProvider()),

        ],
        child: MyApp(
          isLoggedIn: isLoggedIn,
          role: role,
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;

  const MyApp({super.key, required this.isLoggedIn, required this.role});

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;
    if (isLoggedIn && role == 'admin') {
      initialScreen = const admin.MainScreen();
    } else if (isLoggedIn && role == 'user') {
      initialScreen = const user.MainScreen();
    } else {
      initialScreen = const LoginScreen();
    }
    return MaterialApp(
      title: 'Sri Kandi Sehat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          elevation: 8,
        ),
        useMaterial3: true,
      ),
      home: initialScreen,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // User routes
        '/main': (context) => const user.MainScreen(),
        '/home': (context) => const user.HomeScreen(),
        '/profile': (context) => const user.ProfileScreen(),
        '/change-password': (context) => const user.ChangePasswordScreen(),
        '/edit-profile': (context) => const user.EditProfileScreen(),
        '/detail-profile': (context) => const user.DetailProfileScreen(),
        '/cycle-history': (context) => const user.CycleHistoryScreen(),

        // Admin routes
        '/admin': (context) => const admin.MainScreen(),
        '/admin/home': (context) => const admin.HomeScreen(),
        '/admin/profile': (context) => const admin.ProfileScreen(),
      },
    );
  }
}

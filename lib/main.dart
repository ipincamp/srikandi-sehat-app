import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/core/auth/notification_service.dart';
import 'package:srikandi_sehat_app/firebase_options.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/provider/csv_download_provider.dart';
import 'package:srikandi_sehat_app/provider/cycle_history_provider.dart';
import 'package:srikandi_sehat_app/provider/cycle_provider.dart';
import 'package:srikandi_sehat_app/provider/district_provider.dart';
import 'package:srikandi_sehat_app/provider/menstrual_history_detail_provider.dart';
import 'package:srikandi_sehat_app/provider/menstrual_history_provider.dart';
import 'package:srikandi_sehat_app/provider/password_provider.dart';
import 'package:srikandi_sehat_app/provider/profile_change_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_history_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_history_detail_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_log_post_provider.dart';
import 'package:srikandi_sehat_app/provider/symptom_log_get_provider.dart';
import 'package:srikandi_sehat_app/provider/user_data_provider.dart';
import 'package:srikandi_sehat_app/provider/user_data_stats_provider.dart';
import 'package:srikandi_sehat_app/provider/user_detail_provider.dart';
import 'package:srikandi_sehat_app/provider/user_profile_provider.dart';
import 'package:srikandi_sehat_app/provider/village_provider.dart';

import 'package:srikandi_sehat_app/screens/auth/login_screen.dart';
import 'package:srikandi_sehat_app/screens/auth/register_screen.dart';
import 'package:srikandi_sehat_app/screens/user/change_password_screen.dart'
    as user;
import 'package:srikandi_sehat_app/screens/user/edit_profile_screen.dart'
    as user;
import 'package:srikandi_sehat_app/screens/user/home_screen.dart' as user;
import 'package:srikandi_sehat_app/screens/user/main_screen.dart' as user;
import 'package:srikandi_sehat_app/screens/user/profile_screen.dart' as user;
import 'package:srikandi_sehat_app/screens/user/profile_detail_screen.dart'
    as user;
import 'package:srikandi_sehat_app/screens/user/symptom_history_screen.dart'
    as user;
import 'package:srikandi_sehat_app/screens/user/menstrual_history_screen.dart'
    as user;
import 'package:srikandi_sehat_app/screens/admin/home_screen.dart' as admin;
import 'package:srikandi_sehat_app/screens/admin/main_screen.dart' as admin;
import 'package:srikandi_sehat_app/screens/admin/profile_screen.dart' as admin;
import 'package:srikandi_sehat_app/screens/admin/user_data_screen.dart'
    as admin;
import 'package:srikandi_sehat_app/core/auth/route_observer.dart';
import 'package:srikandi_sehat_app/core/auth/auth_wrapper.dart';
import 'package:flutter/foundation.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  debugPrint('App started');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService().initialize(navigatorKey);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => const AppProviders(),
    ),
  );
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => CycleHistoryProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => UserDetailProvider()),
        ChangeNotifierProvider(create: (_) => UserDataStatsProvider()),
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
        ChangeNotifierProvider(create: (_) => SymptomProvider()),
        ChangeNotifierProvider(create: (_) => SymptomLogProvider()),
        ChangeNotifierProvider(create: (_) => SymptomHistoryProvider()),
        ChangeNotifierProvider(create: (_) => SymptomDetailProvider()),
        ChangeNotifierProvider(create: (_) => MenstrualHistoryProvider()),
        ChangeNotifierProvider(create: (_) => MenstrualHistoryDetailProvider()),
        ChangeNotifierProvider(create: (_) => DistrictProvider()),
        ChangeNotifierProvider(create: (_) => VillageProvider()),
        ChangeNotifierProvider(create: (_) => ProfileChangeProvider()),
        ChangeNotifierProvider(create: (_) => CsvDownloadProvider()),
      ],
      child: FutureBuilder(
        future: _checkInitialAuthState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }
          return MyApp(
            initialAuthState:
                snapshot.data ?? AuthState(isLoggedIn: false, role: null),
          );
        },
      ),
    );
  }

  Future<AuthState> _checkInitialAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthState(
      isLoggedIn: prefs.getBool('isLoggedIn') ?? false,
      role: prefs.getString('role'),
    );
  }
}

class AuthState {
  final bool isLoggedIn;
  final String? role;

  AuthState({required this.isLoggedIn, required this.role});
}

class MyApp extends StatelessWidget {
  final AuthState initialAuthState;
  final _routeObserver = AuthRouteObserver();

  MyApp({super.key, required this.initialAuthState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sri Kandi Sehat',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_routeObserver],
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
      home: AuthWrapper(
        initialAuthState: initialAuthState,
        adminChild: const admin.MainScreen(),
        userChild: const user.MainScreen(),
        guestChild: const LoginScreen(),
      ),
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
        '/symptom-history': (context) => const user.SymptomHistoryScreen(),
        '/menstrual-history': (context) => const user.MenstrualHistoryScreen(),

        // Admin routes
        '/admin': (context) => const admin.MainScreen(),
        '/admin/home': (context) => const admin.HomeScreen(),
        '/admin/data': (context) => const admin.UserDataScreen(),
        '/admin/profile': (context) => const admin.ProfileScreen(),
      },
    );
  }
}

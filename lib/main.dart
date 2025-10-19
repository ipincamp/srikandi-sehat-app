import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/firebase_options.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/provider/csv_download_provider.dart';
import 'package:srikandi_sehat_app/provider/cycle_tracking_provider.dart';
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
import 'package:srikandi_sehat_app/screens/splash/splash_screen.dart';
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
import 'package:srikandi_sehat_app/core/auth/auth_guard.dart';
import 'package:srikandi_sehat_app/core/auth/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:srikandi_sehat_app/provider/notification_provider.dart';
import 'package:srikandi_sehat_app/screens/user/notification_history_screen.dart'
    as user;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // debugPrint('App started');

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
        ChangeNotifierProvider(create: (_) => CycleTrackingProvider()),
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
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: FutureBuilder(
        future: _checkInitialAuthState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: SplashScreen(onInitializationComplete: () {}),
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
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Simulasi delay untuk splash screen
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
      title: 'Srikandi Sehat',
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
      routes: {
        '/': (context) => AuthWrapper(
          initialAuthState: initialAuthState,
          adminChild: const admin.MainScreen(),
          userChild: const user.MainScreen(),
          guestChild: const LoginScreen(),
        ),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const user.MainScreen(), // Rute untuk user
        '/admin': (context) => const admin.MainScreen(), // Rute untuk admin
        // Tambahkan rute detail lainnya di sini jika perlu
        '/notification-history': (context) =>
            const user.NotificationHistoryScreen(),
        '/change-password': (context) => const user.ChangePasswordScreen(),
        '/edit-profile': (context) => const user.EditProfileScreen(),
        '/detail-profile': (context) => const user.DetailProfileScreen(),
        '/symptom-history': (context) => const user.SymptomHistoryScreen(),
        '/menstrual-history': (context) => const user.MenstrualHistoryScreen(),
      },
      // home: AuthWrapper(
      //   initialAuthState: initialAuthState,
      //   adminChild: const admin.MainScreen(),
      //   userChild: const user.MainScreen(),
      //   guestChild: const LoginScreen(),
      // ),
      initialRoute: '/',
      // onGenerateRoute: (RouteSettings settings) {
      //   return MaterialPageRoute(
      //     builder: (context) => AuthWrapper(
      //       initialAuthState: initialAuthState,
      //       adminChild: _buildAdminScreen(settings.name),
      //       userChild: _buildUserScreen(settings.name),
      //       guestChild: _buildGuestScreen(settings.name),
      //     ),
      //     settings: settings, // Penting untuk mempertahankan settings
      //   );
      // },
      // Hapus routes: {} jika ada
    );
  }

  // Helper methods untuk membangun screen dengan loading state
  Widget _buildAdminScreen(String? routeName) {
    return FutureBuilder(
      future: AuthGuard.isValidSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!(snapshot.data ?? false)) return const LoginScreen();

        switch (routeName) {
          case '/admin':
            return const admin.MainScreen();
          case '/admin/home':
            return const admin.HomeScreen();
          case '/admin/data':
            return const admin.UserDataScreen();
          case '/admin/profile':
            return const admin.ProfileScreen();
          default:
            return const admin.MainScreen();
        }
      },
    );
  }

  Widget _buildUserScreen(String? routeName) {
    return FutureBuilder(
      future: AuthGuard.isValidSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!(snapshot.data ?? false)) return const LoginScreen();

        switch (routeName) {
          case '/main':
            return const user.MainScreen();
          case '/home':
            return const user.HomeScreen();
          case '/profile':
            return const user.ProfileScreen();
          case '/change-password':
            return const user.ChangePasswordScreen();
          case '/edit-profile':
            return const user.EditProfileScreen();
          case '/detail-profile':
            return const user.DetailProfileScreen();
          case '/symptom-history':
            return const user.SymptomHistoryScreen();
          case '/menstrual-history':
            return const user.MenstrualHistoryScreen();
          case '/notification-history':
            return const user.NotificationHistoryScreen();
          default:
            return const user.MainScreen();
        }
      },
    );
  }

  Widget _buildGuestScreen(String? routeName) {
    switch (routeName) {
      case '/register':
        return const RegisterScreen();
      case '/login':
      default:
        return const LoginScreen();
    }
  }
}

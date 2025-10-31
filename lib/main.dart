import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/firebase_options.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/csv_download_provider.dart';
import 'package:app/provider/cycle_tracking_provider.dart';
import 'package:app/provider/cycle_provider.dart';
import 'package:app/provider/district_provider.dart';
import 'package:app/provider/health_provider.dart';
import 'package:app/provider/menstrual_history_detail_provider.dart';
import 'package:app/provider/menstrual_history_provider.dart';
import 'package:app/provider/password_provider.dart';
import 'package:app/provider/profile_change_provider.dart';
import 'package:app/provider/symptom_history_provider.dart';
import 'package:app/provider/symptom_history_detail_provider.dart';
import 'package:app/provider/symptom_log_post_provider.dart';
import 'package:app/provider/symptom_log_get_provider.dart';
import 'package:app/provider/user_data_provider.dart';
import 'package:app/provider/user_data_stats_provider.dart';
import 'package:app/provider/user_detail_provider.dart';
import 'package:app/provider/user_profile_provider.dart';
import 'package:app/provider/village_provider.dart';

import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/auth/register_screen.dart';
import 'package:app/screens/splash/maintenance_screen.dart';
import 'package:app/screens/splash/splash_screen.dart';
import 'package:app/screens/user/change_password_screen.dart' as user;
import 'package:app/screens/user/edit_profile_screen.dart' as user;
import 'package:app/screens/user/main_screen.dart' as user;
import 'package:app/screens/user/profile_detail_screen.dart' as user;
import 'package:app/screens/user/symptom_history_screen.dart' as user;
import 'package:app/screens/user/menstrual_history_screen.dart' as user;
import 'package:app/screens/admin/main_screen.dart' as admin;
import 'package:app/core/auth/route_observer.dart';
import 'package:app/core/auth/auth_wrapper.dart';
import 'package:app/core/auth/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:app/provider/notification_provider.dart';
import 'package:app/screens/user/notification_history_screen.dart' as user;
import 'package:app/screens/user/verify_otp_screen.dart' as user;
import 'package:app/widgets/markdown_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

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
        ChangeNotifierProvider(create: (_) => HealthProvider()),
      ],
      child: const MainAppInitializer(),
      /*
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
      */
    );
  }

  /*
  Future<AuthState> _checkInitialAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 3));
    return AuthState(
      isLoggedIn: prefs.getBool('isLoggedIn') ?? false,
      role: prefs.getString('role'),
    );
  }
  */
}

class MainAppInitializer extends StatelessWidget {
  const MainAppInitializer({super.key});

  // Fungsi ini akan memuat data awal sebelum app build
  Future<void> _loadInitialData(BuildContext context) async {
    // Ambil provider (tanpa listen)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    // 1. Muat data user (termasuk status verifikasi) dari SharedPreferences
    await authProvider.loadUserData();

    // 2. Cek status server (maintenance, dll)
    await healthProvider.checkHealth();

    // 3. Tahan splash screen selama 3 detik (sesuai kode asli Anda)
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadInitialData(context),
      builder: (context, snapshot) {
        // Selama data sedang dimuat, tampilkan SplashScreen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(onInitializationComplete: () {}),
          );
        }

        // Setelah selesai, bangun aplikasi utama
        return const MyApp();
      },
    );
  }
}

class AuthState {
  final bool isLoggedIn;
  final String? role;

  AuthState({required this.isLoggedIn, required this.role});
}

class MyApp extends StatefulWidget {
  // final AuthState initialAuthState;

  // const MyApp({super.key, required this.initialAuthState});
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _routeObserver = AuthRouteObserver();

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        // Langsung return MaintenanceScreen jika dalam maintenance
        if (healthProvider.isMaintenance) {
          return MaterialApp(
            debugShowCheckedModeBanner: kDebugMode,
            home: const MaintenanceScreen(),
          );
        }

        // Jika tidak maintenance, return app normal
        return MaterialApp(
          title: 'Srikandi Sehat',
          debugShowCheckedModeBanner: kDebugMode,
          navigatorObservers: [_routeObserver],
          navigatorKey: navigatorKey,
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
          /*
          home: AuthWrapper(
            initialAuthState: widget.initialAuthState,
            adminChild: const admin.MainScreen(),
            userChild: const user.MainScreen(),
            guestChild: const LoginScreen(),
          ),
          */
          initialRoute: '/',
          routes: {
            '/': (context) => AuthWrapper(
              // initialAuthState: widget.initialAuthState,
              adminChild: const admin.MainScreen(),
              userChild: const user.MainScreen(),
              guestChild: const LoginScreen(),
            ),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/tos': (context) => const MarkdownScreen(
              title: 'Syarat dan Ketentuan',
              assetPath: 'assets/docs/term-of-service.md',
            ),
            '/privacy': (context) => const MarkdownScreen(
              title: 'Kebijakan Privasi',
              assetPath: 'assets/docs/privacy-policy.md',
            ),
            '/maintenance': (context) => const MaintenanceScreen(),
            '/main': (context) => const user.MainScreen(),
            '/admin': (context) => const admin.MainScreen(),
            '/notification-history': (context) =>
                const user.NotificationHistoryScreen(),
            '/change-password': (context) => const user.ChangePasswordScreen(),
            '/verify-otp': (context) => const user.VerifyOtpScreen(),
            '/edit-profile': (context) => const user.EditProfileScreen(),
            '/detail-profile': (context) => const user.DetailProfileScreen(),
            '/symptom-history': (context) => const user.SymptomHistoryScreen(),
            '/menstrual-history': (context) =>
                const user.MenstrualHistoryScreen(),
          },
        );
      },
    );
  }
}

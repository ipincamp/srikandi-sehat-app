import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/core/auth/auth_guard.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/provider/health_provider.dart';
import 'package:srikandi_sehat_app/screens/splash/maintenance_screen.dart';
import 'package:srikandi_sehat_app/widgets/markdown_screen.dart';

class AuthWrapper extends StatefulWidget {
  final dynamic initialAuthState;
  final Widget adminChild;
  final Widget userChild;
  final Widget guestChild;

  const AuthWrapper({
    super.key,
    required this.initialAuthState,
    required this.adminChild,
    required this.userChild,
    required this.guestChild,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with RouteAware {
  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);

    if (healthProvider.isMaintenance) {
      return const MaintenanceScreen();
    }

    return FutureBuilder(
      future: AuthGuard.isValidSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isValidSession = snapshot.data ?? false;
        if (!isValidSession) return widget.guestChild;

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final role = authProvider.role;

        if (role == 'admin') return widget.adminChild;
        if (role == 'user') return widget.userChild;

        return widget.guestChild;
      },
    );
  }
}

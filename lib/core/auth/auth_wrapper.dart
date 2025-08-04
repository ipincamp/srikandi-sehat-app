import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/core/auth/auth_guard.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/screens/auth/login_screen.dart';
import 'package:srikandi_sehat_app/screens/admin/main_screen.dart' as admin;
import 'package:srikandi_sehat_app/screens/user/main_screen.dart' as user;

class AuthWrapper extends StatelessWidget {
  final dynamic initialAuthState;
  final Widget adminChild;
  final Widget userChild;
  final Widget guestChild;

  const AuthWrapper({
    required this.initialAuthState,
    required this.adminChild,
    required this.userChild,
    required this.guestChild,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthGuard.isValidSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isValidSession = snapshot.data ?? false;

        if (!isValidSession) return guestChild;

        // Check role dari initial state atau provider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final role = initialAuthState.role ?? authProvider.role;

        if (role == 'admin') return adminChild;
        if (role == 'user') return userChild;

        return guestChild;
      },
    );
  }
}

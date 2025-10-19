import 'package:flutter/material.dart';
import 'auth_guard.dart';

class AuthRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  // 1. Buat daftar rute yang tidak memerlukan login
  final List<String> _publicRoutes = [
    '/login',
    '/register', // Sebaiknya tambahkan /register juga
    '/tos',
    '/privacy',
  ];

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _checkAuth(route);
  }

  void _checkAuth(Route route) async {
    // 2. Ubah kondisi 'if' Anda
    // Cek apakah rute saat ini TIDAK ada di dalam daftar publicRoutes
    if (!_publicRoutes.contains(route.settings.name) &&
        !await AuthGuard.isValidSession()) {
      // Jika rute BUKAN rute publik DAN sesi tidak valid,
      // baru lakukan redirect
      final context = (route as PageRoute).navigator?.context;
      if (context != null) {
        AuthGuard.redirectToLogin(context);
      }
    }
  }
}

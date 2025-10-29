import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'auth_guard.dart';

class AuthRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  // daftar rute yang tidak memerlukan login
  final List<String> _publicRoutes = [
    '/login',
    '/register',
    '/tos',
    '/privacy',
    '/maintenance',
  ];

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _checkAuth(route);
  }

  void _checkAuth(Route route) async {
    if (route is PageRoute) {
      final routeName = route.settings.name;
      if (routeName != null && !_publicRoutes.contains(routeName)) {
        if (!await AuthGuard.isValidSession()) {
          // Jika BUKAN rute publik DAN sesi tidak valid, baru redirect
          final context = route.navigator?.context;
          if (context != null && context.mounted) {
            AuthGuard.redirectToLogin(context);
          }
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          "AuthRouteObserver: Ignoring non-PageRoute: ${route.runtimeType}",
        );
      }
    }
  }
}

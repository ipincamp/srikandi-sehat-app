import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/logger.dart';
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
    
    if (kDebugMode && route is PageRoute) {
      final from = previousRoute?.settings.name ?? 'null';
      final to = route.settings.name ?? 'unknown';
      AppLogger.navigation(from, to);
    }
    
    _checkAuth(route);
  }

  void _checkAuth(Route route) async {
    if (route is PageRoute) {
      final routeName = route.settings.name;
      if (routeName != null && !_publicRoutes.contains(routeName)) {
        if (kDebugMode) {
          AppLogger.info('RouteObserver', 'Checking auth for route: $routeName');
        }
        
        if (!await AuthGuard.isValidSession()) {
          // Jika BUKAN rute publik DAN sesi tidak valid, baru redirect
          if (kDebugMode) {
            AppLogger.warning('RouteObserver', 'Session invalid for protected route: $routeName');
          }
          
          final context = route.navigator?.context;
          if (context != null && context.mounted) {
            AuthGuard.redirectToLogin(context);
          }
        } else {
          if (kDebugMode) {
            AppLogger.success('RouteObserver', 'Auth valid for route: $routeName');
          }
        }
      } else if (routeName != null) {
        if (kDebugMode) {
          AppLogger.info('RouteObserver', 'Public route accessed: $routeName');
        }
      }
    } else {
      if (kDebugMode) {
        AppLogger.warning(
          'RouteObserver',
          'Ignoring non-PageRoute: ${route.runtimeType}',
        );
      }
    }
  }
}

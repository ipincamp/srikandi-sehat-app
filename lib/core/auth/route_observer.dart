import 'package:flutter/material.dart';
import 'auth_guard.dart';

class AuthRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _checkAuth(route);
  }

  void _checkAuth(Route route) async {
    if (route.settings.name != '/login' && !await AuthGuard.isValidSession()) {
      final context = (route as PageRoute).navigator?.context;
      if (context != null) {
        AuthGuard.redirectToLogin(context);
      }
    }
  }
}

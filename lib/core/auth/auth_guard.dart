import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:app/utils/logger.dart';

class AuthGuard {
  static Future<bool> isValidSession() async {
    if (kDebugMode) {
      AppLogger.startSection('AuthGuard - Validate Session', emoji: '🔐');
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final expiry = prefs.getString('token_expiry');

      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          AppLogger.warning('AuthGuard', 'No token found');
          AppLogger.endSection(message: '│ ❌ Session invalid');
        }
        return false;
      }

      if (kDebugMode) {
        AppLogger.info('AuthGuard', 'Token present (${token.length} chars)');
      }

      if (expiry != null) {
        final expiryDate = DateTime.parse(expiry);
        if (expiryDate.isBefore(DateTime.now())) {
          if (kDebugMode) {
            AppLogger.warning('AuthGuard', 'Token expired at: $expiry');
            AppLogger.endSection(message: '│ ❌ Session expired');
          }
          return false;
        }
        
        if (kDebugMode) {
          final timeRemaining = expiryDate.difference(DateTime.now());
          AppLogger.info('AuthGuard', 'Token expires in: ${timeRemaining.inHours}h ${timeRemaining.inMinutes % 60}m');
        }
      } else {
        if (kDebugMode) {
          AppLogger.warning('AuthGuard', 'No expiry date found for token');
        }
      }

      if (kDebugMode) {
        AppLogger.success('AuthGuard', 'Session is valid');
        AppLogger.endSection();
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.exception(
          category: 'AuthGuard',
          error: e,
        );
        AppLogger.endSection();
      }
      return false;
    }
  }

  static Future<void> redirectToLogin(BuildContext context) async {
    if (kDebugMode) {
      AppLogger.warning('AuthGuard', 'Redirecting to login screen');
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

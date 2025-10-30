import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthGuard {
  static Future<bool> isValidSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final expiry = prefs.getString('token_expiry');

      // Debugging

      if (token == null || token.isEmpty) return false;

      if (expiry != null) {
        final expiryDate = DateTime.parse(expiry);
        if (expiryDate.isBefore(DateTime.now())) {
          if (kDebugMode) {
            debugPrint('Token expired');
          }
          return false;
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error validating session: $e');
      }
      return false;
    }
  }

  static Future<void> redirectToLogin(BuildContext context) async {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

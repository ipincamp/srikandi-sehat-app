import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard {
  static Future<bool> isValidSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final expiry = prefs.getString('token_expiry');

      // Debugging
      print('Token: $token');
      print('Expiry: $expiry');

      if (token == null || token.isEmpty) return false;

      if (expiry != null) {
        final expiryDate = DateTime.parse(expiry);
        if (expiryDate.isBefore(DateTime.now())) {
          // print('Token expired');
          return false;
        }
      }

      return true;
    } catch (e) {
      // print('Error validating session: $e');
      return false;
    }
  }

  static Future<void> redirectToLogin(BuildContext context) async {
    print('Redirecting to login...');
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

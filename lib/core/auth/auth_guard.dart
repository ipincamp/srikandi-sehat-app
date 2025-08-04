import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard {
  static Future<bool> isValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  static Future<void> redirectToLogin(BuildContext context) async {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

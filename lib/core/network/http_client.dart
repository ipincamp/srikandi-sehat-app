import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/core/auth/auth_guard.dart';
import 'package:srikandi_sehat_app/core/network/api_exceptions.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';

class HttpClient {
  static Future<http.Response> get(
    BuildContext context,
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    return _makeRequest(context, 'GET', endpoint);
  }

  static Future<http.Response> _makeRequest(
    BuildContext context,
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Attempt 1
    var response = await _attemptRequest(context, method, endpoint, body: body);

    // If unauthorized, try refresh token
    if (response.statusCode == 401) {
      print('Attempting token refresh...');
      final refreshSuccess = await authProvider.refreshToken();

      if (refreshSuccess) {
        print('Token refreshed, retrying request...');
        response = await _attemptRequest(context, method, endpoint, body: body);
      } else {
        print('Refresh token failed');
        AuthGuard.redirectToLogin(context);
        throw ApiException('Unauthorized', 401);
      }
    }

    return response;
  }

  static Future<http.Response> _attemptRequest(
    BuildContext context,
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    if (!await AuthGuard.isValidSession()) {
      print('Invalid session in attemptRequest');
      AuthGuard.redirectToLogin(context);
      throw ApiException('Unauthorized', 401);
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')!;
    print('Making $method request to $endpoint');

    try {
      final uri = Uri.parse('${dotenv.env['API_URL']}/$endpoint');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      http.Response response;
      switch (method) {
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          response = await http.get(uri, headers: headers);
      }

      print('Response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Request error: $e');
      throw ApiException(e.toString(), 500);
    }
  }
}

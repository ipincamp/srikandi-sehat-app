import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/core/auth/auth_guard.dart';
import 'package:srikandi_sehat_app/core/network/api_exceptions.dart';

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
    if (!await AuthGuard.isValidSession()) {
      AuthGuard.redirectToLogin(context);
      throw ApiException('Unauthorized', 401);
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')!;

    print('Making $method request to $endpoint with token: $token');

    try {
      final uri = Uri.parse('${dotenv.env['API_URL']}/$endpoint');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      http.Response response;
      switch (method) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: body);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          response = await http.get(uri, headers: headers);
      }

      if (response.statusCode == 401) {
        AuthGuard.redirectToLogin(context);
      }

      return response;
    } catch (e) {
      throw ApiException(e.toString(), 500);
    }
  }
}

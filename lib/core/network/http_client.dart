import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/core/auth/auth_guard.dart';
import 'package:app/core/network/api_exceptions.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/utils/logger.dart';

class HttpClient {
  static Future<http.Response> post(
    BuildContext context,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    if (kDebugMode) {
      AppLogger.startSection('HTTP POST Request', emoji: '📤');
      AppLogger.info('HttpClient', 'Endpoint: $endpoint');
    }
    
    final response = await _makeRequest(context, 'POST', endpoint, body: body);
    
    if (kDebugMode) {
      AppLogger.endSection();
    }
    
    return response;
  }

  static Future<http.Response> get(
    BuildContext context,
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    if (kDebugMode) {
      AppLogger.startSection('HTTP GET Request', emoji: '📥');
      AppLogger.info('HttpClient', 'Endpoint: $endpoint');
    }
    
    final response = await _makeRequest(context, 'GET', endpoint);
    
    if (kDebugMode) {
      AppLogger.endSection();
    }
    
    return response;
  }

  static Future<http.Response> _makeRequest(
    BuildContext context,
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (kDebugMode) {
      AppLogger.info('HttpClient', 'Making $method request to: $endpoint');
    }

    // Attempt 1
    var response = await _attemptRequest(context, method, endpoint, body: body);

    // If unauthorized, try refresh token
    if (response.statusCode == 401) {
      if (kDebugMode) {
        AppLogger.warning('HttpClient', 'Received 401, attempting token refresh');
      }
      
      final refreshSuccess = await authProvider.refreshToken(context);

      if (refreshSuccess) {
        if (kDebugMode) {
          AppLogger.success('HttpClient', 'Token refreshed, retrying request');
        }
        response = await _attemptRequest(context, method, endpoint, body: body);
      } else {
        if (kDebugMode) {
          AppLogger.error('HttpClient', 'Token refresh failed, redirecting to login');
        }
        AuthGuard.redirectToLogin(context);
        throw ApiException('Unauthorized', 401);
      }
    }

    if (kDebugMode) {
      AppLogger.apiResponse(
        statusCode: response.statusCode,
        endpoint: endpoint,
        errorMessage: response.statusCode >= 400 ? 'Request failed' : null,
      );
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
      if (kDebugMode) {
        AppLogger.warning('HttpClient', 'Invalid session detected');
      }
      AuthGuard.redirectToLogin(context);
      throw ApiException('Unauthorized', 401);
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')!;

    try {
      final uri = Uri.parse('${dotenv.env['API_URL']}/$endpoint');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (kDebugMode) {
        AppLogger.apiRequest(
          method: method,
          endpoint: endpoint,
          token: token,
          body: body,
        );
      }

      http.Response response;
      switch (method) {
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
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

      if (kDebugMode) {
        AppLogger.info('HttpClient', 'Response received: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.exception(
          category: 'HttpClient',
          error: e,
        );
      }
      throw ApiException(e.toString(), 500);
    }
  }
}

import 'package:flutter/foundation.dart';

/// Centralized logging utility for Srikandi Sehat App
/// Only logs in debug mode to avoid performance issues in production
class AppLogger {
  /// Log with a specific category/tag
  static void log(
    String category,
    String message, {
    String? emoji,
    LogLevel level = LogLevel.info,
  }) {
    if (!kDebugMode) return;

    final emojiPrefix = emoji ?? _getEmojiForLevel(level);
    debugPrint('│ $emojiPrefix [$category] $message');
  }

  /// Start a new log section with a header
  static void startSection(String title, {String? emoji}) {
    if (!kDebugMode) return;

    debugPrint('┌─────────────────────────────────────────');
    debugPrint('│ ${emoji ?? '📋'} $title');
  }

  /// End a log section
  static void endSection({String? message}) {
    if (!kDebugMode) return;

    if (message != null) {
      debugPrint('│ $message');
    }
    debugPrint('└─────────────────────────────────────────');
  }

  /// Log an info message
  static void info(String category, String message, {String? emoji}) {
    log(category, message, emoji: emoji, level: LogLevel.info);
  }

  /// Log a success message
  static void success(String category, String message, {String? emoji}) {
    log(category, message, emoji: emoji ?? '✅', level: LogLevel.success);
  }

  /// Log a warning message
  static void warning(String category, String message, {String? emoji}) {
    log(category, message, emoji: emoji ?? '⚠️', level: LogLevel.warning);
  }

  /// Log an error message
  static void error(String category, String message, {String? emoji}) {
    log(category, message, emoji: emoji ?? '❌', level: LogLevel.error);
  }

  /// Log an API request
  static void apiRequest({
    required String method,
    required String endpoint,
    String? token,
    Map<String, dynamic>? body,
  }) {
    if (!kDebugMode) return;

    debugPrint('│ 📡 API Request: $method $endpoint');
    if (token != null) {
      debugPrint(
        '│ 🔑 Token: ${token.isNotEmpty ? "✓ (${token.length} chars)" : "✗ Missing"}',
      );
    }
    if (body != null && body.isNotEmpty) {
      debugPrint('│ 📦 Body keys: ${body.keys.join(", ")}');
    }
  }

  /// Log an API response
  static void apiResponse({
    required int statusCode,
    required String endpoint,
    dynamic data,
    String? errorMessage,
  }) {
    if (!kDebugMode) return;

    debugPrint('│ 📊 Response Status: $statusCode');

    if (statusCode >= 200 && statusCode < 300) {
      debugPrint('│ ✅ Request successful');
      if (data != null) {
        if (data is List) {
          debugPrint('│ 📦 Data count: ${data.length}');
        } else if (data is Map) {
          debugPrint('│ 📦 Data keys: ${data.keys.join(", ")}');
        }
      }
    } else {
      debugPrint('│ ❌ Request failed');
      if (errorMessage != null) {
        debugPrint('│ 💬 Error: $errorMessage');
      }
    }
  }

  /// Log an exception
  static void exception({
    required String category,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    debugPrint('│ ❌ Exception caught!');
    debugPrint('│ 🔴 Category: $category');
    debugPrint('│ 🔥 Type: ${error.runtimeType}');
    debugPrint('│ 💬 Message: ${error.toString()}');

    if (stackTrace != null && kDebugMode) {
      debugPrint('│ 📚 Stack trace:');
      final lines = stackTrace.toString().split('\n');
      for (var i = 0; i < lines.length && i < 5; i++) {
        debugPrint('│   ${lines[i]}');
      }
    }
  }

  /// Log provider state changes
  static void stateChange(String provider, String state, {String? details}) {
    if (!kDebugMode) return;

    debugPrint('│ 🔄 [$provider] State: $state');
    if (details != null) {
      debugPrint('│ 📝 Details: $details');
    }
  }

  /// Log navigation events
  static void navigation(String from, String to) {
    if (!kDebugMode) return;

    debugPrint('│ 🧭 Navigation: $from → $to');
  }

  /// Get emoji based on log level
  static String _getEmojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.success:
        return '✅';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.debug:
        return '🐛';
    }
  }

  /// Simple log without formatting (for quick debugging)
  static void debug(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}

/// Log levels
enum LogLevel { info, success, warning, error, debug }

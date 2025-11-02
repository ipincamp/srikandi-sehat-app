# Logging Migration Guide

This guide explains how to replace existing `debugPrint` and `print` statements with the centralized `AppLogger` from `lib/utils/logger.dart`.

## Already Completed Files

✅ **Providers:**
- `lib/provider/password_provider.dart`
- `lib/provider/user_data_stats_provider.dart`
- `lib/provider/user_data_provider.dart`
- `lib/provider/cycle_tracking_provider.dart`
- `lib/provider/recommendation_provider.dart`

✅ **Core:**
- `lib/core/auth/notification_service.dart`

## Migration Pattern

### 1. Import Statement

**Before:**
```dart
import 'package:flutter/foundation.dart';
```

**After:**
```dart
import 'package:app/utils/logger.dart';
```

**Note:** Remove `import 'package:flutter/foundation.dart'` if only used for `kDebugMode`.

### 2. Section Logging

**Before:**
```dart
if (kDebugMode) {
  debugPrint('┌─────────────────────────────────────────');
  debugPrint('│ 📊 [ProviderName] Action description');
  debugPrint('│ 🔑 Detail: value');
  debugPrint('└─────────────────────────────────────────');
}
```

**After:**
```dart
AppLogger.startSection('ProviderName - Action description', emoji: '📊');
AppLogger.log('ProviderName', 'Detail: value', emoji: '🔑');
AppLogger.endSection();
```

### 3. API Request Logging

**Before:**
```dart
if (kDebugMode) {
  debugPrint('│ 🔑 Token: ${token.isNotEmpty ? "✓" : "✗"}');
  debugPrint('│ 🌐 API URL: $url');
  debugPrint('│ 📡 Sending request...');
}
```

**After:**
```dart
AppLogger.apiRequest(
  method: 'GET',
  endpoint: '/endpoint/path',
  token: token,
);
```

### 4. API Response Logging

**Before:**
```dart
if (kDebugMode) {
  debugPrint('│ 📊 Response Status: ${response.statusCode}');
  if (response.statusCode == 200) {
    debugPrint('│ ✅ Request successful');
    debugPrint('│ 📦 Data: ${data.length} items');
  } else {
    debugPrint('│ ❌ Request failed');
  }
}
```

**After:**
```dart
AppLogger.apiResponse(
  statusCode: response.statusCode,
  endpoint: '/endpoint/path',
  data: data, // optional
  errorMessage: errorMsg, // optional
);
```

### 5. Simple Logging

**Before:**
```dart
if (kDebugMode) {
  debugPrint('│ ✅ Success message');
}
```

**After:**
```dart
AppLogger.success('Category', 'Success message');
```

Or:
```dart
AppLogger.log('Category', 'Info message', emoji: '💡');
```

### 6. Error/Exception Logging

**Before:**
```dart
if (kDebugMode) {
  debugPrint('│ ❌ Exception caught');
  debugPrint('│ 🔥 Error type: ${e.runtimeType}');
  debugPrint('│ 💬 Message: ${e.toString()}');
}
```

**After:**
```dart
AppLogger.exception(
  category: 'CategoryName',
  error: e,
  stackTrace: stackTrace, // optional
);
```

### 7. State Changes

**Before:**
```dart
if (kDebugMode) {
  debugPrint('│ 🔄 State changed to: $newState');
}
```

**After:**
```dart
AppLogger.stateChange('ProviderName', newState, details: 'Optional details');
```

### 8. Navigation

**Before:**
```dart
if (kDebugMode) {
  debugPrint('│ 🔄 Navigating to: $routeName');
}
```

**After:**
```dart
AppLogger.navigation('CurrentScreen', 'TargetScreen');
```

## Remaining Files to Migrate

### High Priority (Core Providers)
- [ ] `lib/provider/auth_provider.dart`
- [ ] `lib/provider/profile_change_provider.dart`
- [ ] `lib/provider/health_provider.dart`
- [ ] `lib/provider/cycle_provider.dart`
- [ ] `lib/provider/notification_provider.dart`
- [ ] `lib/provider/menstrual_history_provider.dart`
- [ ] `lib/provider/menstrual_history_detail_provider.dart`
- [ ] `lib/provider/symptom_history_provider.dart`
- [ ] `lib/provider/symptom_history_detail_provider.dart`
- [ ] `lib/provider/symptom_log_get_provider.dart`
- [ ] `lib/provider/symptom_log_post_provider.dart`
- [ ] `lib/provider/user_detail_provider.dart`
- [ ] `lib/provider/user_profile_provider.dart`
- [ ] `lib/provider/district_provider.dart`
- [ ] `lib/provider/village_provider.dart`
- [ ] `lib/provider/csv_download_provider.dart`

### Medium Priority (Screens)
- [ ] `lib/screens/auth/login_screen.dart`
- [ ] `lib/screens/auth/register_screen.dart`
- [ ] `lib/screens/splash/splash_screen.dart`
- [ ] `lib/screens/user/main_screen.dart`
- [ ] `lib/screens/user/profile_screen.dart`
- [ ] All other screen files in `lib/screens/`

### Low Priority (Core Auth)
- [ ] `lib/core/auth/auth_guard.dart`
- [ ] `lib/core/auth/auth_wrapper.dart`
- [ ] `lib/core/auth/route_observer.dart`

## Benefits

1. **Centralized Control**: All logging controlled from one place
2. **Production Safety**: Automatically disabled in production (no manual `kDebugMode` checks)
3. **Consistent Format**: Uniform logging format across the app
4. **Better Organization**: Categorized logs make debugging easier
5. **Performance**: Zero overhead in production builds
6. **Cleaner Code**: Less boilerplate, more readable

## Testing

After migration, test by:
1. Running app in debug mode - logs should appear
2. Building release version - no logs should appear
3. Checking all migrated features work as expected

## Example: Complete Provider Migration

**Before:**
```dart
import 'package:flutter/foundation.dart';

class MyProvider {
  Future<void> fetchData() async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📊 [MyProvider] Fetching data');
      debugPrint('│ 🔑 Token: $token');
    }
    
    try {
      final response = await api.get();
      
      if (kDebugMode) {
        debugPrint('│ 📊 Status: ${response.statusCode}');
        debugPrint('│ ✅ Data loaded');
        debugPrint('└─────────────────────────────────────────');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('│ ❌ Error: $e');
        debugPrint('└─────────────────────────────────────────');
      }
    }
  }
}
```

**After:**
```dart
import 'package:app/utils/logger.dart';

class MyProvider {
  Future<void> fetchData() async {
    AppLogger.startSection('MyProvider - Fetching data', emoji: '📊');
    AppLogger.log('MyProvider', 'Token: $token', emoji: '🔑');

    try {
      final response = await api.get();

      AppLogger.apiResponse(
        statusCode: response.statusCode,
        endpoint: '/endpoint',
      );
      AppLogger.success('MyProvider', 'Data loaded');
      AppLogger.endSection();
    } catch (e) {
      AppLogger.exception(category: 'MyProvider', error: e);
      AppLogger.endSection();
    }
  }
}
```

## Notes

- The `AppLogger` automatically handles `kDebugMode` checks internally
- No need to wrap `AppLogger` calls in `if (kDebugMode)` blocks
- Choose appropriate log levels: `info`, `success`, `warning`, `error`
- Use emojis consistently for better visual parsing of logs
- Always call `endSection()` after `startSection()` to close log blocks

## Need Help?

Refer to `lib/utils/logger.dart` for complete API documentation and all available methods.

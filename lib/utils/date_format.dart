import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toLocalIso8601String() {
    final duration = timeZoneOffset;
    final hours = duration.inHours.abs().toString().padLeft(2, '0');
    final minutes = (duration.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = duration.isNegative ? '-' : '+';

    return '${toIso8601String().split('.')[0]}$sign$hours:$minutes';
  }

  String toFormattedDate({bool short = false}) {
    return DateFormat(
      short ? 'dd MMM yyyy' : 'dd MMMM yyyy HH:mm',
      'id_ID',
    ).format(this);
  }
}

class DateFormatter {
  static String format(String? dateString, {bool short = false}) {
    if (dateString == null || dateString.isEmpty) return '-';

    try {
      final dateTime = _parseDateString(dateString);
      return dateTime.toFormattedDate(short: short);
    } catch (e) {
      return _fallbackFormat(dateString, short);
    }
  }

  static DateTime _parseDateString(String dateString) {
    // Handle berbagai format date
    if (dateString.contains('T')) {
      return DateTime.parse(dateString).toLocal();
    } else if (dateString.contains(' ')) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString).toLocal();
    } else {
      return DateFormat('yyyy-MM-dd').parse(dateString).toLocal();
    }
  }

  static String _fallbackFormat(String dateString, bool short) {
    if (dateString.contains('T')) {
      return dateString.split('T')[0];
    } else if (dateString.length > 10) {
      return dateString.substring(0, 10);
    }
    return dateString;
  }
}

String formatNumber(num? value, {String suffix = ''}) {
  if (value == null) return '-$suffix';
  if (value % 1 == 0) return '${value.toInt()}$suffix';
  return '${value.toStringAsFixed(1)}$suffix';
}

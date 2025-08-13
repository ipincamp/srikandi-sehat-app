extension DateTimeExtension on DateTime {
  String toLocalIso8601String() {
    final duration = timeZoneOffset;
    final hours = duration.inHours.abs().toString().padLeft(2, '0');
    final minutes = (duration.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = duration.isNegative ? '-' : '+';

    return '${toIso8601String().split('.')[0]}$sign$hours:$minutes';
  }
}

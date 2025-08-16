extension CapitalizeExtension on String {
  String capitalizeWords() {
    return split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }
}

String formatNumberFormat(num? value, {String suffix = ''}) {
  if (value == null) return '-$suffix';
  if (value % 1 == 0) return '${value.toInt()}$suffix';
  return '${value.toStringAsFixed(1)}$suffix';
}

String ordinalNumberFormat(int number) {
  if (number % 100 >= 11 && number % 100 <= 13) {
    return 'ke-$number';
  }
  switch (number % 10) {
    case 1:
      return 'ke-$number';
    case 2:
      return 'ke-$number';
    case 3:
      return 'ke-$number';
    default:
      return 'ke-$number';
  }
}

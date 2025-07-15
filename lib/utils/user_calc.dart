// lib/utils/user_utils.dart

/// Menghitung IMT (Indeks Massa Tubuh) dari tinggi (cm) dan berat (kg)
double? calculateIMT(double heightCm, double weightKg) {
  if (heightCm <= 0 || weightKg <= 0) return null;
  final heightMeter = heightCm / 100;
  final imt = weightKg / (heightMeter * heightMeter);
  return double.parse(imt.toStringAsFixed(1));
}

/// Mengembalikan usia berdasarkan tanggal lahir dengan format 'YYYY-MM-DD'
int? calculateAgeFromString(String dobStr) {
  try {
    final parts = dobStr.split('-'); // Sesuai format dari backend
    if (parts.length != 3) return null;

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    final dob = DateTime(year, month, day);
    final now = DateTime.now();

    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }

    return age;
  } catch (_) {
    return null;
  }
}

/// Kategori IMT berdasarkan nilai
String getIMTCategory(double imt) {
  if (imt < 18.5) return 'Kurus';
  if (imt < 25) return 'Normal';
  if (imt < 30) return 'Gemuk';
  return 'Obesitas';
}

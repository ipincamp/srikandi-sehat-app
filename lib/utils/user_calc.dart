import 'package:flutter/material.dart';

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

/// Utility functions for BMI (IMT) calculations and classifications

/// Calculates BMI from height (cm) and weight (kg)
double? calculateBMI(double heightCm, double weightKg) {
  if (heightCm <= 0 || weightKg <= 0) return null;
  final heightMeter = heightCm / 100;
  return weightKg / (heightMeter * heightMeter);
}

/// Classifies BMI into categories (Asian standard)
String classifyBMI(double bmi) {
  if (bmi < 18.5) return 'Kurus';
  if (bmi < 22.9) return 'Normal';
  if (bmi < 24.9) return 'Berlebih';
  if (bmi < 29.9) return 'Gemuk';
  return 'Obesitas';
}

/// Gets color representation for BMI category
Color getBMIColor(double bmi) {
  if (bmi < 18.5) return Colors.blue;
  if (bmi < 22.9) return Colors.green;
  if (bmi < 24.9) return Colors.orange;
  if (bmi < 29.9) return Colors.deepOrange;
  return Colors.red;
}

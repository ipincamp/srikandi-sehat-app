import 'package:flutter/material.dart';
import 'package:app/models/education_model.dart';

class EducationData {
  static final List<EducationItem> allEducationItems = [
    EducationItem(
        title: 'Mandi Teratur',
        content: 'Mandi minimal 2 kali sehari dengan sabun.',
        icon: Icons.clean_hands),
    EducationItem(
        title: 'Cuci Tangan',
        content: 'Cuci tangan sebelum makan dan setelah dari toilet.',
        icon: Icons.clean_hands),
    EducationItem(
        title: 'Gosok Gigi',
        content: 'Gosok gigi pagi setelah makan dan malam sebelum tidur.',
        icon: Icons.clean_hands),
    EducationItem(
        title: 'Ganti Pembalut',
        content: 'Ganti pembalut setiap 3-5 jam sekali.',
        icon: Icons.female),
    EducationItem(
        title: 'Jaga Kebersihan Area Kewanitaan',
        content: 'Bersihkan area kewanitaan dengan air bersih.',
        icon: Icons.female),
    EducationItem(
        title: 'Ganti Pakaian Dalam',
        content: 'Ganti pakaian dalam setiap hari.',
        icon: Icons.checkroom),
    EducationItem(
        title: 'Jemur Pakaian',
        content: 'Jemur pakaian di bawah sinar matahari langsung.',
        icon: Icons.checkroom),
    EducationItem(
        title: 'Bersihkan Kamar Tidur',
        content: 'Bersihkan kamar tidur secara rutin.',
        icon: Icons.eco),
    EducationItem(
        title: 'Jaga Sirkulasi Udara',
        content: 'Jaga sirkulasi udara yang baik di kamar.',
        icon: Icons.eco),
  ];
}

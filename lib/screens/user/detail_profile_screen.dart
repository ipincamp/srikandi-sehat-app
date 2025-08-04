import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_profile_provider.dart';
import 'package:srikandi_sehat_app/utils/user_calc.dart';

class DetailProfileScreen extends StatelessWidget {
  const DetailProfileScreen({super.key});

  Widget buildProfileCard({
    required IconData icon,
    required String title,
    required dynamic value,
    required Color color,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProfileProvider>().userData;
    final detail = user['profile'] ?? {};
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Contact Section
              buildSectionHeader('Kontak Pribadi'),
              buildProfileCard(
                icon: Icons.person_outline,
                title: 'Nama Lengkap',
                value: user['name'] ?? 'Belum diisi',
                color: Colors.blueAccent,
              ),
              buildProfileCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: user['email'] ?? 'Belum diisi',
                color: Colors.green,
              ),
              buildProfileCard(
                icon: Icons.phone_android_outlined,
                title: 'Nomor Telepon',
                value: detail['phone'] ?? 'Belum diisi',
                color: Colors.orange,
              ),

              // Personal Information Section
              buildSectionHeader('Informasi Pribadi'),
              buildProfileCard(
                icon: Icons.cake_outlined,
                title: 'Tanggal Lahir',
                value: detail['birthdate'] != null
                    ? '${detail['birthdate']}\n(${calculateAgeFromString(detail['birthdate'])} tahun)'
                    : 'Belum diisi',
                color: Colors.purple,
              ),
              buildProfileCard(
                icon: Icons.height_outlined,
                title: 'Tinggi & Berat Badan',
                value:
                    '${detail['height_cm'] ?? '-'} cm | ${detail['weight_kg'] ?? '-'} kg',
                color: Colors.blue,
              ),
              buildProfileCard(
                icon: Icons.monitor_weight_outlined,
                title: 'Indeks Massa Tubuh (IMT)',
                value: detail['bmi'] != null && detail['bmi'] is num
                    ? '${detail['bmi']} kg/m² (${classifyBMI(detail['bmi'])})'
                    : 'Belum dihitung',
                color: Colors.teal,
              ),
              buildProfileCard(
                icon: Icons.location_on_outlined,
                title: 'Alamat',
                value: detail['address'] ?? 'Belum diisi',
                color: Colors.redAccent,
              ),
              buildProfileCard(
                icon: Icons.category_outlined,
                title: 'Kategori Tempat Tinggal',
                value: 'Belum diisi',
                color: Colors.indigo,
              ),
              buildProfileCard(
                icon: Icons.school_outlined,
                title: 'Pendidikan Terakhir',
                value: detail['last_education'] ?? 'Belum diisi',
                color: Colors.amber,
              ),
              buildProfileCard(
                icon: Icons.wifi_outlined,
                title: 'Akses Internet',
                value: detail['internet_access'] ?? 'Belum diisi',
                color: Colors.lightBlue,
              ),

              // Parent Information Section
              buildSectionHeader('Informasi Orang Tua'),
              buildProfileCard(
                icon: Icons.school_outlined,
                title: 'Pendidikan Terakhir Orang Tua',
                value: detail['last_parent_education'] ?? 'Belum diisi',
                color: Colors.deepOrange,
              ),
              buildProfileCard(
                icon: Icons.work_outline,
                title: 'Pekerjaan Orang Tua',
                value: detail['last_parent_job'] ?? 'Belum diisi',
                color: Colors.brown,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

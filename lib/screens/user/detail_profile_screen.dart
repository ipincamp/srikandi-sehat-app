import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_profile_provider.dart';
import 'package:srikandi_sehat_app/utils/user_calc.dart';
import 'package:srikandi_sehat_app/widgets/title_section_divider.dart';

class DetailProfileScreen extends StatelessWidget {
  const DetailProfileScreen({super.key});

  Widget buildListTile({
    required IconData icon,
    required String title,
    required dynamic subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12, // label kecil
          color: Color.fromARGB(255, 77, 77, 77),
        ),
      ),
      subtitle: Text(
        subtitle.toString(),
        style: const TextStyle(
          fontSize: 14, // isi lebih besar
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProfileProvider>().userData;
    final detail = user['profile'] ?? {};
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionDivider(
                title: 'Kontak Pribadi',
                topSpacing: 16,
                bottomSpacing: 8,
                textSize: 18,
                textColor: Colors.black87,
                lineColor: Colors.grey,
                linePosition: LinePosition.bottom,
              ),
              buildListTile(
                icon: Icons.person,
                title: 'Nama',
                subtitle: user['name'] ?? 'Tidak tersedia',
                color: Colors.blue,
              ),
              buildListTile(
                icon: Icons.email,
                title: 'Email',
                subtitle: user['email'] ?? 'Tidak tersedia',
                color: Colors.green,
              ),
              buildListTile(
                icon: Icons.phone,
                title: 'Telepon',
                subtitle: detail['phone'] ?? 'Tidak tersedia',
                color: Colors.orange,
              ),
              // buildListTile(
              //   icon: Icons.location_on,
              //   title: 'Alamat',
              //   subtitle: detail['address'] ?? 'Tidak tersedia',
              //   color: Colors.red,
              // ),
              const SectionDivider(
                title: 'Informasi Pribadi',
                topSpacing: 24,
                bottomSpacing: 12,
                textSize: 18,
                textColor: Colors.black87,
                lineColor: Colors.grey,
                linePosition: LinePosition.bottom,
              ),
              buildListTile(
                icon: Icons.calendar_month_rounded,
                title: 'Tanggal Lahir',
                subtitle: detail['birthdate'] != null
                    ? '${detail['birthdate']} | ${calculateAgeFromString(detail['birthdate'])} tahun'
                    : 'Tidak tersedia',
                color: Colors.orange,
              ),
              buildListTile(
                icon: Icons.accessibility,
                title: 'Tinggi Badan dan Berat Badan',
                subtitle:
                    '${detail['height_cm']} cm | ${detail['weight_kg']} kg',
                color: Colors.blue,
              ),

              buildListTile(
                icon: Icons.monitor_weight,
                title: 'Indeks Massa Tubuh (BMI)',
                subtitle: detail['bmi'] != null && detail['bmi'] is num
                    ? '${detail['bmi']} kg/m² | ${getIMTCategory(detail['bmi'])}'
                    : 'Tidak tersedia',
                color: Colors.green,
              ),

              buildListTile(
                icon: Icons.location_on,
                title: 'Alamat',
                subtitle: detail['address'] ?? 'Tidak tersedia',
                color: Colors.red,
              ),
              buildListTile(
                icon: Icons.location_on_rounded,
                title: 'Kategori Tempat Tinggal',
                subtitle: 'Tidak tersedia',
                color: Colors.blue,
              ),
              buildListTile(
                icon: Icons.school,
                title: 'Pendidikan Terakhir',
                subtitle: detail['last_education'] ?? 'Tidak tersedia',
                color: Colors.orangeAccent,
              ),
              buildListTile(
                icon: Icons.wifi,
                title: 'Akses Internet',
                subtitle: detail['internet_access'] ?? 'Tidak tersedia',
                color: Colors.greenAccent,
              ),
              const SectionDivider(
                title: 'Informasi Orang Tua',
                topSpacing: 16,
                bottomSpacing: 8,
                textSize: 18,
                textColor: Colors.black87,
                lineColor: Colors.grey,
                linePosition: LinePosition.bottom,
              ),
              buildListTile(
                icon: Icons.school_outlined,
                title: 'Pendidikan Terakhir Orang Tua',
                subtitle: detail['last_parent_education'] ?? 'Tidak tersedia',
                color: Colors.blue,
              ),
              buildListTile(
                icon: Icons.work_outline,
                title: 'Pekerjaan Orang Tua',
                subtitle: detail['last_parent_job'] ?? 'Tidak tersedia',
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

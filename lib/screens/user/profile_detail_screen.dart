import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/profile_change_provider.dart';
import 'package:app/utils/user_calc.dart';
import 'package:app/widgets/connection_error_card.dart';

class DetailProfileScreen extends StatefulWidget {
  const DetailProfileScreen({super.key});

  @override
  State<DetailProfileScreen> createState() => _DetailProfileScreenState();
}

class _DetailProfileScreenState extends State<DetailProfileScreen> {
  bool _initialLoadComplete = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      setState(() => _isRefreshing = true);
      final profileProvider = context.read<ProfileChangeProvider>();
      await profileProvider.fetchProfile();
    } finally {
      if (mounted) {
        setState(() {
          _initialLoadComplete = true;
          _isRefreshing = false;
        });
      }
    }
  }

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

  Widget _buildIncompleteProfileWarning(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                size: 30,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profil Belum Lengkap',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Lengkapi profil Anda untuk mengakses fitur memulai siklus menstruasi dan mendapatkan rekomendasi yang lebih personal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
              child: const Text('Lengkapi Profil Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = context.watch<ProfileChangeProvider>();

    if (!_initialLoadComplete || userProfileProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProfileProvider.errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: const Text(
            'Detail Profil',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Center(
          child: ConnectionErrorWidget(
            message: "Tidak ada koneksi, periksa jaringan anda",
            icon: Icons.wifi_off,
            iconColor: Colors.red,
            iconSize: 60,
            isLoading: _isRefreshing,
            onRetry: _isRefreshing ? null : _fetchProfileData,
            retryText: 'Refresh',
          ),
        ),
      );
    }

    final userData = userProfileProvider.userData;
    final profileData = userData['profile'] ?? {};
    final isProfileComplete = userProfileProvider.profileComplete;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Profil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _fetchProfileData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isProfileComplete) _buildIncompleteProfileWarning(context),

              if (isProfileComplete) ...[
                buildSectionHeader('Kontak Pribadi'),
                buildProfileCard(
                  icon: Icons.person_outline,
                  title: 'Nama Lengkap',
                  value: userData['name'] ?? 'Belum diisi',
                  color: Colors.blueAccent,
                ),
                buildProfileCard(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: userData['email'] ?? 'Belum diisi',
                  color: Colors.green,
                ),
                buildProfileCard(
                  icon: Icons.phone_android_outlined,
                  title: 'Nomor Telepon',
                  value: profileData['phone'] ?? 'Belum diisi',
                  color: Colors.orange,
                ),

                buildSectionHeader('Informasi Pribadi'),
                buildProfileCard(
                  icon: Icons.cake_outlined,
                  title: 'Tanggal Lahir',
                  value: profileData['birthdate'] != null
                      ? '${profileData['birthdate'].toString().split('T')[0]}\n(${calculateAgeFromString(profileData['birthdate'].toString().split('T')[0])} tahun)'
                      : 'Belum diisi',
                  color: Colors.purple,
                ),
                buildProfileCard(
                  icon: Icons.height_outlined,
                  title: 'Tinggi & Berat Badan',
                  value:
                      '${profileData['tb_cm'] ?? '-'} cm | ${profileData['bb_kg'] ?? '-'} kg',
                  color: Colors.blue,
                ),
                buildProfileCard(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Indeks Massa Tubuh (IMT)',
                  value: profileData['bmi'] != null && profileData['bmi'] is num
                      ? '${profileData['bmi']} kg/m² (${classifyBMI(profileData['bmi'])})'
                      : 'Belum dihitung',
                  color: Colors.teal,
                ),
                buildProfileCard(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat',
                  value: profileData['address'] ?? 'Belum diisi',
                  color: Colors.redAccent,
                ),
                buildProfileCard(
                  icon: Icons.school_outlined,
                  title: 'Pendidikan Terakhir',
                  value: profileData['edu_now'] ?? 'Belum diisi',
                  color: Colors.amber,
                ),
                buildProfileCard(
                  icon: Icons.wifi_outlined,
                  title: 'Akses Internet',
                  value: profileData['inet_access'] ?? 'Belum diisi',
                  color: Colors.lightBlue,
                ),

                buildSectionHeader('Informasi Menstruasi'),
                buildProfileCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Usia Saat Menstruasi Pertama',
                  value: profileData['first_haid'] != null
                      ? '${profileData['first_haid']} tahun'
                      : 'Belum diisi',
                  color: Colors.pinkAccent,
                ),

                buildSectionHeader('Informasi Orang Tua'),
                buildProfileCard(
                  icon: Icons.school_outlined,
                  title: 'Pendidikan Terakhir Orang Tua',
                  value: profileData['edu_parent'] ?? 'Belum diisi',
                  color: Colors.deepOrange,
                ),
                buildProfileCard(
                  icon: Icons.work_outline,
                  title: 'Pekerjaan Orang Tua',
                  value: profileData['job_parent'] ?? 'Belum diisi',
                  color: Colors.brown,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

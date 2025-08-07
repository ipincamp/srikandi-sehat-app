import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_detail_provider.dart';
import 'package:srikandi_sehat_app/models/user_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:srikandi_sehat_app/utils/user_calc.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  String formatNumber(num value, {String suffix = ''}) {
    if (value % 1 == 0) {
      return '${value.toInt()}$suffix';
    } else {
      return '${value.toStringAsFixed(1)}$suffix';
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pengguna',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ChangeNotifierProvider(
        create: (_) => UserDetailProvider()..fetchUserDetail(userId),
        child: Consumer<UserDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.userDetail == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  provider.errorMessage,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 16,
                  ),
                ),
              );
            }

            final user = provider.userDetail;
            if (user == null) {
              return const Center(
                child: Text(
                  'Data pengguna tidak ditemukan',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildUserInfoCard(context, user),
                  const SizedBox(height: 16),
                  _buildProfileInfoCard(context, user.profile),
                  const SizedBox(height: 16),
                  _buildCycleHistoryCard(context, user.cycleHistory),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, UserDetail user) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pengguna',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoItem(context, 'Nama', user.name),
            _buildInfoItem(context, 'Email', user.email),
            _buildInfoItem(context, 'Role', user.role),
            _buildInfoItem(
                context, 'Bergabung pada', _formatDate(user.createdAt)),
            if (user.currentCycleNumber != null)
              _buildInfoItem(
                  context, 'Siklus Saat Ini', '${user.currentCycleNumber}'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(BuildContext context, UserProfile profile) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil Pengguna',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoItem(context, 'No. Telepon', profile.phone),
            _buildInfoItem(context, 'Tanggal Lahir', profile.birthdate),
            _buildInfoItem(context, 'Tinggi Badan',
                '${formatNumber(profile.heightCm)} cm'),
            _buildInfoItem(
                context, 'Berat Badan', '${formatNumber(profile.weightKg)} kg'),
            _buildInfoItem(context, 'IMT', formatNumber(profile.bmi)),
            _buildInfoItem(context, 'Kategori IMT', classifyBMI(profile.bmi)),
            _buildInfoItem(
                context, 'Pendidikan Terakhir', profile.lastEducation),
            _buildInfoItem(
                context, 'Pendidikan Orang Tua', profile.lastParentEducation),
            _buildInfoItem(
                context, 'Pekerjaan Orang Tua', profile.lastParentJob),
            _buildInfoItem(context, 'Akses Internet', profile.internetAccess),
            _buildInfoItem(
                context, 'Menarche', '${profile.firstMenstruation} tahun'),
            _buildInfoItem(context, 'Alamat', profile.address),
            _buildInfoItem(
                context, 'Terakhir Diupdate', _formatDate(profile.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleHistoryCard(
      BuildContext context, List<CycleHistory> cycles) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Siklus',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            if (cycles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tidak ada riwayat siklus menstruasi',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ...cycles.map((cycle) => _buildCycleItem(context, cycle)),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleItem(BuildContext context, CycleHistory cycle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoItem(context, 'Tanggal Mulai', cycle.startDate),
          _buildInfoItem(context, 'Tanggal Selesai', cycle.finishDate),
          _buildInfoItem(context, 'Durasi Haid',
              formatNumber(cycle.periodLengthDays.abs())),
          if (cycle.cycleLengthDays != null)
            _buildInfoItem(context, 'Panjang Siklus',
                formatNumber(cycle.cycleLengthDays!.abs())),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

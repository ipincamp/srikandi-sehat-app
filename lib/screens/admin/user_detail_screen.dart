import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_detail_provider.dart';
import 'package:srikandi_sehat_app/models/user_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:srikandi_sehat_app/utils/user_calc.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  String formatNumber(num? value, {String suffix = ''}) {
    if (value == null) return '-$suffix';
    if (value % 1 == 0) return '${value.toInt()}$suffix';
    return '${value.toStringAsFixed(1)}$suffix';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String _formatShortDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String _getOrdinalNumber(int number) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pengguna',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink[600],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ChangeNotifierProvider(
        create: (_) => UserDetailProvider()..fetchUserDetail(userId, context),
        child: Consumer<UserDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                ),
              );
            }
            if (provider.errorMessage.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    provider.errorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (provider.userDetail == null) {
              return const Center(
                child: Text(
                  'Data tidak ditemukan',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final user = provider.userDetail!;
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.pink[600]),
                const SizedBox(width: 8),
                Text(
                  'Informasi Pengguna',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[600],
                  ),
                ),
                if (user.profileComplete)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.verified, color: Colors.green, size: 20),
                  ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoItem(context, 'Nama', user.name),
            _buildInfoItem(context, 'Email', user.email),
            _buildInfoItem(
              context,
              'Role',
              user.role == 'user' ? 'Pengguna' : 'Admin',
              valueColor: user.role == 'user' ? Colors.blue : Colors.pink,
            ),
            _buildInfoItem(
              context,
              'Bergabung pada',
              _formatDate(user.createdAt),
            ),
            if (user.currentCycleNumber != null)
              _buildInfoItem(
                context,
                'Siklus Saat Ini',
                'Siklus ${_getOrdinalNumber(user.currentCycleNumber!)}',
                valueColor: Colors.pink[600],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(BuildContext context, UserProfile profile) {
    final bmiCategory = classifyBMI(profile.bmi);
    Color bmiColor = Colors.grey;
    if (bmiCategory.contains("Kurang")) bmiColor = Colors.blue;
    if (bmiCategory.contains("Normal")) bmiColor = Colors.green;
    if (bmiCategory.contains("Lebih")) bmiColor = Colors.orange;
    if (bmiCategory.contains("Obesitas")) bmiColor = Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_information, color: Colors.pink[600]),
                const SizedBox(width: 8),
                Text(
                  'Profil Kesehatan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoItem(context, 'No. Telepon', profile.phone ?? '-'),
            _buildInfoItem(
              context,
              'Tanggal Lahir',
              _formatShortDate(profile.birthdate),
            ),
            _buildInfoItem(
              context,
              'Tinggi Badan',
              '${formatNumber(profile.heightCm)} cm',
            ),
            _buildInfoItem(
              context,
              'Berat Badan',
              '${formatNumber(profile.weightKg)} kg',
            ),
            _buildInfoItem(context, 'IMT', formatNumber(profile.bmi)),
            _buildInfoItem(
              context,
              'Kategori IMT',
              bmiCategory,
              valueColor: bmiColor,
            ),
            _buildInfoItem(context, 'Pendidikan', profile.lastEducation ?? '-'),
            _buildInfoItem(
              context,
              'Pendidikan Ortu',
              profile.lastParentEducation ?? '-',
            ),
            _buildInfoItem(
              context,
              'Pekerjaan Ortu',
              profile.lastParentJob ?? '-',
            ),
            _buildInfoItem(
              context,
              'Akses Internet',
              profile.internetAccess ?? '-',
            ),
            _buildInfoItem(
              context,
              'Menarche',
              '${formatNumber(profile.firstMenstruation)} tahun',
            ),
            _buildInfoItem(context, 'Alamat', profile.address ?? '-'),
            _buildInfoItem(
              context,
              'Diperbarui',
              _formatDate(profile.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleHistoryCard(
    BuildContext context,
    List<CycleHistory> cycles,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.pink[600]),
                const SizedBox(width: 8),
                Text(
                  'Riwayat Siklus',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[600],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    '${cycles.length} siklus',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.pink[600],
                ),
              ],
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
              ...cycles.asMap().entries.map((entry) {
                final index = entry.key;
                final cycle = entry.value;
                return _buildCycleItem(context, cycle, index + 1);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleItem(
    BuildContext context,
    CycleHistory cycle,
    int cycleNumber,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Siklus ${_getOrdinalNumber(cycleNumber)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pink[600],
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoItem(context, 'Mulai', _formatShortDate(cycle.startDate)),
          _buildInfoItem(
            context,
            'Selesai',
            _formatShortDate(cycle.finishDate),
          ),
          _buildInfoItem(context, 'Durasi', '${cycle.periodLengthDays} hari'),
          if (cycle.cycleLengthDays != null)
            _buildInfoItem(
              context,
              'Panjang Siklus',
              '${cycle.cycleLengthDays} hari',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

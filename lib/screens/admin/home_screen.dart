import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_data_stats_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserDataStatsProvider>(context, listen: false)
          .fetchUserStats(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDataStatsProvider = Provider.of<UserDataStatsProvider>(context);
    final totalUsers = userDataStatsProvider.totalUsers;
    final activeUsers = userDataStatsProvider.activeUsers;
    final urbanCount = userDataStatsProvider.urbanCount;
    final ruralCount = userDataStatsProvider.ruralCount;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Srikandi Sehat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // Stats Overview Cards
            _buildStatsOverview(
                totalUsers: totalUsers,
                activeUsers: activeUsers,
                urbanCount: urbanCount,
                ruralCount: ruralCount),
            const SizedBox(height: 24),

            // Recent Activity
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang Kembali,',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
        const Text(
          'Admin Srikandi!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Apa yang ingin Anda lakukan hari ini?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview({
    required int totalUsers,
    required int activeUsers,
    required int urbanCount,
    required int ruralCount,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Total Pengguna',
          value: '$totalUsers',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Pengguna Aktif',
          value: '$activeUsers',
          icon: Icons.people_alt,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Perkotaan',
          value: '$urbanCount',
          icon: Icons.location_city,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Pedesaan',
          value: '$ruralCount',
          icon: Icons.nature_people,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

}

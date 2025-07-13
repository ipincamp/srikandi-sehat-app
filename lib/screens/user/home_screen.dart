import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/screens/user/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'SriKandi Sehat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Notifikasi
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.pink,
                child: Text(
                  'U',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Sambutan
            Text(
              'Halo, User!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),

            // Kartu Informasi Siklus Saat Ini
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perkiraan Hari Ini:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fase Luteal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Menstruasi Berikutnya dalam:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '5 Hari',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress Bar Lingkaran (Contoh sederhana)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: 0.75, // Contoh progress (0.0 - 1.0)
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.pink.shade100,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.pink,
                              ),
                            ),
                          ),
                          const Text(
                            '75%', // Atau hari ke X dari Y
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bagian Pembaruan Cepat (Quick Actions)
            Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementasi Mulai Menstruasi
                    },
                    icon: const Icon(Icons.water_drop, color: Colors.white),
                    label: const Text(
                      'Mulai',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementasi Akhiri Menstruasi
                    },
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.pink,
                    ),
                    label: const Text(
                      'Akhiri',
                      style: TextStyle(color: Colors.pink),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.pink),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showLogSymptomsBottomSheet(context);
                    },
                    icon: const Icon(Icons.edit_note, color: Colors.white),
                    label: const Text(
                      'Gejala',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bagian Informasi/Tips Harian
            Text(
              'Tips & Edukasi Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 152,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTipCard(
                    context,
                    'Minum Air Cukup',
                    'Hidrasi penting untuk kesehatanmu.',
                    Icons.water_drop,
                    Colors.blue.shade100,
                    Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  _buildTipCard(
                    context,
                    'Peregangan Ringan',
                    'Meredakan kram menstruasi.',
                    Icons.self_improvement,
                    Colors.green.shade100,
                    Colors.green,
                  ),
                  const SizedBox(width: 10),
                  _buildTipCard(
                    context,
                    'Edukasi Baru!',
                    'Mitos dan Fakta Seputar Menstruasi.',
                    Icons.book,
                    Colors.purple.shade100,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bagian Pengingat
            Text(
              'Pengingat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm, color: Colors.teal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Perkiraan menstruasi tanggal 20 Juni!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk Kartu Tips
  Widget _buildTipCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan Bottom Sheet Catat Gejala
  void _showLogSymptomsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bc).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catat Gejala Hari Ini',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  _buildChip('Kram Perut', Icons.medical_services_outlined),
                  _buildChip('Sakit Kepala', Icons.headphones),
                  _buildChip('Mood Swing', Icons.mood),
                  _buildChip('Jerawat', Icons.face),
                  // Tambahkan lebih banyak gejala
                ],
              ),
              const SizedBox(height: 20),
              Text('Mood', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMoodIcon(
                    'Senang',
                    Icons.sentiment_satisfied_alt,
                    Colors.green,
                  ),
                  _buildMoodIcon('Biasa', Icons.sentiment_neutral, Colors.grey),
                  _buildMoodIcon(
                    'Sedih',
                    Icons.sentiment_dissatisfied,
                    Colors.blueGrey,
                  ),
                  _buildMoodIcon(
                    'Marah',
                    Icons.sentiment_very_dissatisfied,
                    Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Simpan data gejala
                    Navigator.pop(bc);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gejala berhasil dicatat!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Simpan Log',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Widget pembantu untuk Chip Gejala
  Widget _buildChip(String label, IconData iconData) {
    return Chip(
      avatar: Icon(iconData, size: 18),
      label: Text(label),
      backgroundColor: Colors.pink.shade50,
      labelStyle: const TextStyle(color: Colors.pink),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }

  // Widget pembantu untuk Mood Icon
  Widget _buildMoodIcon(String label, IconData iconData, Color color) {
    return Column(
      children: [
        Icon(iconData, size: 40, color: color),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

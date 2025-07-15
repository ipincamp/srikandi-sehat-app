import 'package:flutter/material.dart';

class QuickActionButtons extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final bool isMenstruating;

  const QuickActionButtons({
    super.key,
    required this.onStart,
    required this.onEnd,
    required this.isMenstruating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Tombol Mulai
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isMenstruating
                ? null
                : onStart, // hanya aktif jika belum menstruasi
            icon: const Icon(Icons.water_drop, color: Colors.white),
            label: const Text('Mulai', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Tombol Selesai
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isMenstruating
                ? onEnd
                : null, // hanya aktif jika sedang menstruasi
            icon: const Icon(Icons.check_circle_outline, color: Colors.pink),
            label: const Text('Akhiri', style: TextStyle(color: Colors.pink)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.pink),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Tombol Gejala selalu aktif
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showLogSymptomsBottomSheet(context);
            },
            icon: const Icon(Icons.edit_note, color: Colors.white),
            label: const Text('Gejala', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
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

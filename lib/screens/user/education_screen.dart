import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/widgets/accordion_list.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  EdgeInsets get paddingEdgeInsets => const EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.pink,
          title: const Text(
            'Edukasi',
            style: TextStyle(color: Colors.white),
          )),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8),
                KebersihanDiriWidget(),
                SizedBox(height: 24),
                // Add more widgets here if needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KebersihanDiriWidget extends StatelessWidget {
  const KebersihanDiriWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AccordionList(
      title: 'KEBERSIHAN DIRI',
      headerColor: Colors.pink,
      iconColor: Colors.pink,
      initiallyExpandedFirstItem: true,
      items: {
        'Perawatan Dasar': AccordionItem(
          icon: Icons.clean_hands,
          content: [
            'Mandi minimal 2 kali sehari dengan sabun',
            'Cuci tangan sebelum makan dan setelah dari toilet',
            'Gosok gigi pagi setelah makan dan malam sebelum tidur',
            'Potong kuku secara rutin',
          ],
        ),
        'Kebersihan Menstruasi': AccordionItem(
          icon: Icons.female,
          content: [
            'Ganti pembalut setiap 3-5 jam sekali',
            'Bersihkan area kewanitaan dengan air bersih',
            'Cuci tangan sebelum dan sesudah mengganti pembalut',
            'Gunakan celana dalam berbahan katun',
          ],
        ),
        'Perawatan Pakaian': AccordionItem(
          icon: Icons.checkroom,
          content: [
            'Ganti pakaian dalam setiap hari',
            'Cuci pakaian dengan sabun dan air bersih',
            'Jemur pakaian di bawah sinar matahari langsung',
            'Simpan pakaian di tempat kering dan bersih',
          ],
        ),
        'Kebersihan Lingkungan': AccordionItem(
          icon: Icons.eco,
          content: [
            'Bersihkan kamar tidur secara rutin',
            'Jaga sirkulasi udara yang baik',
            'Buang sampah pada tempatnya',
            'Ganti sprei minimal 2 minggu sekali',
          ],
        ),
      },
    );
  }
}

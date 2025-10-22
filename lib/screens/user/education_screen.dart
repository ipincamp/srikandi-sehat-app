import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/recommendation_provider.dart';
import 'package:app/widgets/accordion_list.dart';
import 'package:app/widgets/notification_icon_button.dart';
import 'package:app/widgets/recommendation_widget.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Edukasi', style: TextStyle(color: Colors.white)),
        actions: [NotificationIconButton()],
      ),
      body: ChangeNotifierProvider(
        create: (context) => RecommendationProvider(),
        child: const EducationContent(),
      ),
    );
  }
}

class EducationContent extends StatefulWidget {
  const EducationContent({super.key});

  @override
  State<EducationContent> createState() => _EducationContentState();
}

class _EducationContentState extends State<EducationContent> {
  @override
  void initState() {
    super.initState();
    // Delay fetching to avoid build conflict
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RecommendationProvider>(
        context,
        listen: false,
      );
      if (!provider.hasFetched) {
        provider.fetchRecommendations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recommendationProvider = Provider.of<RecommendationProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            if (recommendationProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (recommendationProvider.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  recommendationProvider.errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
            else if (recommendationProvider.hasRecommendations)
              RecommendationWidget(
                recommendations: recommendationProvider.recommendations,
              ),
            const SizedBox(height: 24),
            const KebersihanDiriWidget(),
          ],
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

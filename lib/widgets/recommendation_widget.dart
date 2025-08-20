import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recommendation_model.dart';

class RecommendationWidget extends StatelessWidget {
  final List<Recommendation> recommendations;

  const RecommendationWidget({super.key, required this.recommendations});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'REKOMENDASI UNTUK ANDA',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 8),
        ...recommendations.map((recommendation) {
          final hasValidSource =
              recommendation.source != null &&
              recommendation.source!.isNotEmpty &&
              _isValidUrl(recommendation.source!);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge untuk gejala
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.pink, width: 1),
                    ),
                    child: Text(
                      recommendation.forSymptom.toUpperCase(),
                      style: TextStyle(
                        color: Colors.pink,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Judul rekomendasi
                  Text(
                    recommendation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Deskripsi
                  if (recommendation.description.isNotEmpty)
                    Text(
                      recommendation.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Tombol sumber (jika valid)
                  if (hasValidSource)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(recommendation.source!),
                        icon: Icon(Icons.open_in_new, size: 16),
                        label: Text('Tonton Tutorial'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  // Tampilkan teks sumber saja jika URL tidak valid
                  if (recommendation.source != null &&
                      recommendation.source!.isNotEmpty &&
                      !hasValidSource)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Sumber: ${recommendation.source}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

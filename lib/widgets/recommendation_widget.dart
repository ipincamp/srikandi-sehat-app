import 'package:flutter/material.dart';
import '../models/recommendation_model.dart';

class RecommendationWidget extends StatelessWidget {
  final List<Recommendation> recommendations;

  const RecommendationWidget({super.key, required this.recommendations});

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
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recommendation.forSymptom,
                          style: TextStyle(
                            color: Colors.pink,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recommendation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (recommendation.description.isNotEmpty)
                    Text(
                      recommendation.description,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  if (recommendation.source != null &&
                      recommendation.source!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Handle source link tap
                        },
                        child: Text(
                          'Sumber: ${recommendation.source}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
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

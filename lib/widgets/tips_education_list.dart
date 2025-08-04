import 'package:flutter/material.dart';

class TipsEducationList extends StatelessWidget {
  const TipsEducationList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            'Peregangan Ringan',
            'Meredakan kram menstruasi.',
            Icons.self_improvement,
            Colors.green.shade100,
            Colors.green,
          ),
          const SizedBox(width: 10),
          // _buildTipCard(
          //   context,
          //   'Edukasi Baru!',
          //   'Mitos dan Fakta Seputar Menstruasi.',
          //   Icons.book,
          //   Colors.purple.shade100,
          //   Colors.purple,
          // ),
        ],
      ),
    );
  }

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
}

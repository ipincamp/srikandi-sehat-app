import 'package:flutter/material.dart';
import 'dart:math';
import 'package:srikandi_sehat_app/data/education_data.dart';
import 'package:srikandi_sehat_app/models/education_model.dart';

class TipsEducationList extends StatefulWidget {
  const TipsEducationList({super.key});

  @override
  State<TipsEducationList> createState() => _TipsEducationListState();
}

class _TipsEducationListState extends State<TipsEducationList> {
  late List<EducationItem> _randomTips;

  @override
  void initState() {
    super.initState();
    _randomTips = _getRandomTips(3);
  }

  List<EducationItem> _getRandomTips(int count) {
    final allItems = EducationData.allEducationItems;
    final random = Random();
    final shuffledList = List<EducationItem>.from(allItems)..shuffle(random);

    return shuffledList.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 152,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _randomTips.length,
        itemBuilder: (context, index) {
          final tip = _randomTips[index];

          return Padding(
            padding: EdgeInsets.only(
                right: index == _randomTips.length - 1 ? 0 : 10),
            child: _buildTipCard(
              context,
              tip.title,
              tip.content,
              tip.icon,
              // You can use a random color generator or predefined colors
              Colors.teal.shade50,
              Colors.teal,
            ),
          );
        },
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

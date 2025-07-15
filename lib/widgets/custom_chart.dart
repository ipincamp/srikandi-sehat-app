import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';

class CustomChart extends StatelessWidget {
  final int urbanCount;
  final int ruralCount;
  final VoidCallback onDownloadPressed;

  const CustomChart({
    super.key,
    required this.urbanCount,
    required this.ruralCount,
    required this.onDownloadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: urbanCount.toDouble(),
                      color: Colors.purple,
                      title: urbanCount.toString(),
                      radius: 40,
                    ),
                    PieChartSectionData(
                      value: ruralCount.toDouble(),
                      color: Colors.redAccent,
                      title: ruralCount.toString(),
                      radius: 40,
                    ),
                  ],
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                ),
              ),
              const CircleAvatar(
                backgroundImage: AssetImage('assets/coffee.png'),
                radius: 30,
              )
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total User:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            CustomButton(
              backgroundColor: Colors.lightGreen,
              onPressed: onDownloadPressed,
              label: 'Download',
            ),
          ],
        )
      ],
    );
  }
}

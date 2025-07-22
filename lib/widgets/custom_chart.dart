import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
    final total = urbanCount + ruralCount;
    final urbanPercentage = total > 0 ? (urbanCount / total * 100).round() : 0;
    final ruralPercentage = total > 0 ? (ruralCount / total * 100).round() : 0;
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust layout based on screen width
    final bool isSmallScreen = screenWidth < 600;
    final double chartSize = isSmallScreen ? 150 : 180;
    final double centerSpaceRadius = isSmallScreen ? 40 : 50;
    final double sectionRadius = isSmallScreen ? 25 : 30;
    final double fontSize = isSmallScreen ? 12 : 14;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Pengguna',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 12),

          // Responsive layout - switches between row and column
          isSmallScreen
              ? _buildSmallLayout(
                  chartSize,
                  centerSpaceRadius,
                  sectionRadius,
                  fontSize,
                  urbanPercentage,
                  ruralPercentage,
                  total,
                )
              : _buildLargeLayout(
                  chartSize,
                  centerSpaceRadius,
                  sectionRadius,
                  fontSize,
                  urbanPercentage,
                  ruralPercentage,
                  total,
                ),
        ],
      ),
    );
  }

  Widget _buildSmallLayout(
    double chartSize,
    double centerSpaceRadius,
    double sectionRadius,
    double fontSize,
    int urbanPercentage,
    int ruralPercentage,
    int total,
  ) {
    return Column(
      children: [
        SizedBox(
          height: chartSize,
          width: chartSize,
          child: PieChart(
            PieChartData(
              sections: _buildSections(sectionRadius, fontSize),
              sectionsSpace: 2,
              centerSpaceRadius: centerSpaceRadius,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegendAndInfo(
          fontSize,
          urbanPercentage,
          ruralPercentage,
          total,
          isSmallScreen: true,
        ),
      ],
    );
  }

  Widget _buildLargeLayout(
    double chartSize,
    double centerSpaceRadius,
    double sectionRadius,
    double fontSize,
    int urbanPercentage,
    int ruralPercentage,
    int total,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: chartSize,
          width: chartSize,
          child: PieChart(
            PieChartData(
              sections: _buildSections(sectionRadius, fontSize),
              sectionsSpace: 2,
              centerSpaceRadius: centerSpaceRadius,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLegendAndInfo(
            fontSize,
            urbanPercentage,
            ruralPercentage,
            total,
            isSmallScreen: false,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(double radius, double fontSize) {
    return [
      PieChartSectionData(
        value: urbanCount.toDouble(),
        color: Colors.blue,
        title: urbanCount.toString(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: ruralCount.toDouble(),
        color: Colors.orange,
        title: ruralCount.toString(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegendAndInfo(
    double fontSize,
    int urbanPercentage,
    int ruralPercentage,
    int total, {
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isSmallScreen
              ? MainAxisAlignment.spaceAround
              : MainAxisAlignment.start,
          children: [
            _buildLegendItem(
              color: Colors.blue,
              label: 'Perkotaan',
              value: '$urbanCount ($urbanPercentage%)',
              fontSize: fontSize,
            ),
            if (!isSmallScreen) const SizedBox(width: 24),
            _buildLegendItem(
              color: Colors.orange,
              label: 'Pedesaan',
              value: '$ruralCount ($ruralPercentage%)',
              fontSize: fontSize,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pengguna:',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.blueGrey,
                ),
              ),
              Text(
                total.toString(),
                style: TextStyle(
                  fontSize: fontSize + 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: isSmallScreen ? Alignment.center : Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onDownloadPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: 8,
              ),
            ),
            icon: Icon(Icons.download, size: isSmallScreen ? 14 : 16, color: Colors.white,),
            label: Text(
              'Download Data',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
    required double fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

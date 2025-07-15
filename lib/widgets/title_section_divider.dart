import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final String title;
  final double topSpacing;
  final double bottomSpacing;
  final double textSize;
  final Color textColor;
  final Color lineColor;
  final EdgeInsetsGeometry? padding;

  const SectionDivider({
    super.key,
    required this.title,
    this.topSpacing = 32,
    this.bottomSpacing = 16,
    this.textSize = 18,
    this.textColor = Colors.black,
    this.lineColor = Colors.pink,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topSpacing),
          Container(
            height: 2,
            width: double.infinity,
            color: lineColor,
            margin: EdgeInsets.symmetric(vertical: bottomSpacing),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: topSpacing),
        ],
      ),
    );
  }
}

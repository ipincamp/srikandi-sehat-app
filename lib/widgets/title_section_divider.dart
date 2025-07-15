import 'package:flutter/material.dart';

enum LinePosition {
  top,
  bottom,
  both,
  none,
}

class SectionDivider extends StatelessWidget {
  final String title;
  final double topSpacing;
  final double bottomSpacing;
  final double textSize;
  final Color textColor;
  final Color lineColor;
  final EdgeInsetsGeometry? padding;
  final LinePosition linePosition;

  const SectionDivider({
    super.key,
    required this.title,
    this.topSpacing = 32,
    this.bottomSpacing = 16,
    this.textSize = 18,
    this.textColor = Colors.black,
    this.lineColor = Colors.pink,
    this.padding,
    this.linePosition = LinePosition.both,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topSpacing),
          if (linePosition == LinePosition.top ||
              linePosition == LinePosition.both)
            Container(
              height: 1,
              width: double.infinity,
              color: lineColor,
              margin: EdgeInsets.only(bottom: bottomSpacing),
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (linePosition == LinePosition.bottom ||
              linePosition == LinePosition.both)
            Container(
              height: 1,
              width: double.infinity,
              color: lineColor,
              margin: EdgeInsets.only(top: bottomSpacing),
            ),
          SizedBox(height: topSpacing),
        ],
      ),
    );
  }
}

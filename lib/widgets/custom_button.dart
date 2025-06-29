import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final bool fullWidth;
  final bool isFullRounded;
  final double? borderRadius;
  final double textSize;
  final bool isLoading;
  final bool isDisabled;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.pink,
    this.textColor = Colors.white,
    this.icon,
    this.fullWidth = false,
    this.isFullRounded = false,
    this.borderRadius,
    this.textSize = 16,
    this.isLoading = false,
    this.isDisabled = false,
    this.fontWeight = FontWeight.w600,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    final double finalBorderRadius = isFullRounded ? 50 : (borderRadius ?? 10);

    final bool finalDisabled = isLoading || isDisabled;

    Widget childContent;

    if (isLoading) {
      childContent = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          color: textColor,
          strokeWidth: 2.5,
        ),
      );
    } else {
      childContent = icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: textSize,
                    fontWeight: fontWeight,
                  ),
                ),
              ],
            )
          : Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: textSize,
                fontWeight: fontWeight,
              ),
            );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: finalDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: finalDisabled
              ? backgroundColor.withOpacity(0.5)
              : backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(finalBorderRadius),
          ),
        ),
        child: childContent,
      ),
    );
  }
}

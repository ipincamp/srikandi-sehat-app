import 'package:flutter/material.dart';

class ConnectionErrorWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final TextStyle? textStyle;
  final double spacing;
  final VoidCallback? onRetry;
  final String retryText;
  final bool isLoading;

  const ConnectionErrorWidget({
    super.key,
    required this.message,
    this.icon = Icons.wifi_off_rounded,
    this.iconColor = Colors.red,
    this.iconSize = 48,
    this.textStyle,
    this.spacing = 16,
    this.onRetry,
    this.retryText = 'Coba Lagi',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  strokeWidth: 3,
                ),
              )
            else
              Icon(icon, color: iconColor, size: iconSize),
            SizedBox(height: spacing),
            Text(
              message,
              style:
                  textStyle ??
                  theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: spacing),
              ElevatedButton(
                onPressed: isLoading ? null : onRetry,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: iconColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(retryText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

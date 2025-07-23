import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback? onPressed;
  final bool isOutline;
  final double size;
  final double iconSize;
  final bool showShadow;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final bool loading;
  final Widget? loadingWidget;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.color = Colors.blue,
    this.isActive = true,
    this.onPressed,
    this.isOutline = false,
    this.size = 56,
    this.iconSize = 28,
    this.showShadow = true,
    this.padding,
    this.labelStyle,
    this.loading = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: (isActive && !loading) ? onPressed : null,
          child: Container(
            width: size,
            height: size,
            padding: padding,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: _getBorder(),
              boxShadow: _getBoxShadow(),
            ),
            child: Center(
              child: loading
                  ? loadingWidget ?? _buildDefaultLoadingWidget()
                  : Icon(
                      icon,
                      size: iconSize,
                      color: _getIconColor(),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: (labelStyle ?? _getLabelStyle()).copyWith(
            color: loading ? Colors.grey : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLoadingWidget() {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: _getIconColor(),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isOutline) return Colors.white;
    if (loading) return color.withOpacity(0.3);
    return isActive ? color.withOpacity(0.9) : color.withOpacity(0.3);
  }

  Border? _getBorder() {
    if (!isOutline) return null;
    return Border.all(
      color: loading
          ? color.withOpacity(0.3)
          : (isActive ? color : color.withOpacity(0.3)),
      width: 1.5,
    );
  }

  List<BoxShadow>? _getBoxShadow() {
    if (!showShadow || !isActive || isOutline || loading) return null;
    return [
      BoxShadow(
        color: color.withOpacity(0.2),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ];
  }

  Color _getIconColor() {
    if (isOutline) {
      return loading
          ? color.withOpacity(0.3)
          : (isActive ? color : color.withOpacity(0.3));
    }
    return loading ? Colors.white.withOpacity(0.7) : Colors.white;
  }

  TextStyle _getLabelStyle() {
    return TextStyle(
      fontSize: 12,
      color: loading ? Colors.grey : Colors.grey[700],
      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
    );
  }
}

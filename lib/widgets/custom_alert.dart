import 'package:flutter/material.dart';

enum AlertType { success, error, info, warning }

class CustomAlert {
  static void show(
    BuildContext context,
    String message, {
    AlertType type = AlertType.info,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    final overlay = Overlay.of(context);
    final color = _getColor(type);
    final icon = _getIcon(type);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: SlideAlert(
          color: color,
          icon: icon,
          message: message,
          duration: duration,
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration + const Duration(milliseconds: 300), () {
      overlayEntry.remove();
    });
  }

  static Color _getColor(AlertType type) {
    switch (type) {
      case AlertType.success:
        return Colors.green;
      case AlertType.error:
        return Colors.red;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.info:
      default:
        return Colors.blue;
    }
  }

  static IconData _getIcon(AlertType type) {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.error;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.info:
      default:
        return Icons.info;
    }
  }
}

class SlideAlert extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String message;
  final Duration duration;

  const SlideAlert({
    super.key,
    required this.color,
    required this.icon,
    required this.message,
    required this.duration,
  });

  @override
  State<SlideAlert> createState() => _SlideAlertState();
}

class _SlideAlertState extends State<SlideAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: widget.color.withOpacity(1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

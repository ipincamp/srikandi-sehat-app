import 'package:flutter/material.dart';

class CycleActionButtons extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final bool isMenstruating;

  const CycleActionButtons({
    super.key,
    required this.onStart,
    required this.onEnd,
    required this.isMenstruating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Start Cycle Button
        Expanded(
          child: _buildActionButton(
            icon: Icons.water_drop,
            label: 'Mulai Siklus',
            color: Colors.pink,
            isActive: !isMenstruating,
            onPressed: onStart,
          ),
        ),

        const SizedBox(width: 12),

        // End Cycle Button
        Expanded(
          child: _buildActionButton(
            icon: Icons.check_circle_outline,
            label: 'Akhiri Siklus',
            color: Colors.pink,
            isActive: isMenstruating,
            onPressed: onEnd,
            isOutline: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onPressed,
    bool isOutline = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: isActive ? onPressed : null,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isOutline
                  ? Colors.white
                  : isActive
                      ? color.withOpacity(0.9)
                      : color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOutline
                    ? isActive
                        ? color
                        : color.withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                if (isActive && !isOutline)
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Icon(
              icon,
              size: 28,
              color: isOutline
                  ? isActive
                      ? color
                      : color.withOpacity(0.3)
                  : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

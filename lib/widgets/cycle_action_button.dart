import 'package:flutter/material.dart';
import 'package:app/widgets/action_button.dart';

class CycleActionButtons extends StatelessWidget {
  final VoidCallback? onStart;
  final VoidCallback? onEnd;
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
          child: ActionButton(
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
          child: ActionButton(
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
}

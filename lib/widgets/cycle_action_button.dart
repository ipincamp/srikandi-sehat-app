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
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isMenstruating ? null : onStart,
            icon: const Icon(Icons.water_drop, color: Colors.white),
            label: const Text('Mulai', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isMenstruating ? onEnd : null,
            icon: const Icon(Icons.check_circle_outline, color: Colors.pink),
            label: const Text('Akhiri', style: TextStyle(color: Colors.pink)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.pink),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

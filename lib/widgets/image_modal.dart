import 'package:flutter/material.dart';

class ImageModal extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final VoidCallback? onClose;

  const ImageModal({
    super.key,
    required this.imageUrl,
    this.width = 300,
    this.height = 400,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: width,
              height: height,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                if (onClose != null) onClose!();
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> show(BuildContext context, String imageUrl,
      {double width = 300, double height = 400, VoidCallback? onClose}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ImageModal(
        imageUrl: imageUrl,
        width: width,
        height: height,
        onClose: onClose,
      ),
    );
  }
}

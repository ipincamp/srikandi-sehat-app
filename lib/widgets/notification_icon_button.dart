import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/notification_provider.dart';

class NotificationIconButton extends StatefulWidget {
  const NotificationIconButton({super.key});

  @override
  State<NotificationIconButton> createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton> {
  @override
  void initState() {
    super.initState();
    // Only load initial notifications once, not on every widget rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadInitialNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        // Use cached unreadCount instead of recalculating
        final unreadCount = provider.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/notification-history');
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

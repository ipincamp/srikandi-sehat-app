import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:srikandi_sehat_app/provider/notification_provider.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Notifikasi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text('Tidak ada notifikasi.'));
          }

          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notif = provider.notifications[index];
              return ListTile(
                leading: Icon(
                  notif.isRead ? Icons.notifications_none : Icons.notifications,
                  color: notif.isRead ? Colors.grey : Colors.pink,
                ),
                title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(notif.body),
                trailing: Text(
                  DateFormat('dd MMM, HH:mm').format(notif.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  // Tambahkan logika untuk menandai sebagai sudah dibaca
                },
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Removed the actions icon to avoid duplication
      ),
      body: const NotificationList(),
    );
  }
}

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Progress Update',
      message: 'Ahmed completed his speech training session successfully!',
      time: '10 minutes ago',
      icon: Icons.celebration_outlined,
      iconColor: Colors.green,
      isRead: false,
    ),
    NotificationItem(
      title: 'Safe Zone Alert',
      message: 'Child has entered the safe zone',
      time: '1 hour ago',
      icon: Icons.location_on_outlined,
      iconColor: Colors.blue,
      isRead: true,
    ),
    NotificationItem(
      title: 'Weekly Report',
      message: 'Weekly progress report is ready to view',
      time: '2 hours ago',
      icon: Icons.assessment_outlined,
      iconColor: Colors.orange,
      isRead: true,
    ),
    NotificationItem(
      title: 'Therapy Reminder',
      message: 'Body training session starts in 30 minutes',
      time: '5 hours ago',
      icon: Icons.access_time_outlined,
      iconColor: Colors.purple,
      isRead: true,
    ),
    NotificationItem(
      title: 'Achievement Unlocked',
      message: 'Great progress in communication skills!',
      time: '1 day ago',
      icon: Icons.emoji_events_outlined,
      iconColor: Colors.amber,
      isRead: true,
    ),
  ];

  void _markAsRead(int index) {
    setState(() {
      notifications[index].isRead = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const EmptyNotifications();
    }

    return Column(
      children: [
        // Mark all as read button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, size: 20),
            label: const Text('Mark all as read'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
              elevation: 0,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return NotificationCard(
                notification: notifications[index],
                onTap: () => _markAsRead(index),
                onDelete: () => _deleteNotification(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.isRead,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: notification.iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(notification.icon, color: notification.iconColor),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              notification.time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onDelete,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
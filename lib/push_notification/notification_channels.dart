import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChennels {
  // high importance channel
  static const AndroidNotificationChannel highInportanceChannel =
      AndroidNotificationChannel(
    'high_importance_channel', // id
    'Chat Notifications', // title
    importance: Importance.max,
    description: 'Show chat notifications',
  );

  // low importance channel
  static const AndroidNotificationChannel lowInportanceChannel =
      AndroidNotificationChannel(
    'low_importance_channel', // id
    'Request Notification', // title
    importance: Importance.min,
    description: 'Show request notifications',
  );
}

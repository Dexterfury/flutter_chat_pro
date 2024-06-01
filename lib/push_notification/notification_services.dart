import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_pro/push_notification/notification_channels.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> createNotificationChannelAndInitialize() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
          NotificationChennels.highInportanceChannel);
      await androidImplementation
          .createNotificationChannel(NotificationChennels.lowInportanceChannel);
    }
  }

  static displayNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = notification?.android;

    String channelId = android?.channelId ?? 'default_channel';

    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
          channelId, // Channel id.
          findChannelName(channelId), // Channel name.
          importance: Importance.max,
          playSound: true,
          icon: android?.smallIcon, // Optional icon to use.
        )));
  }

  static String findChannelName(String channelId) {
    switch (channelId) {
      case 'high_importance_channel':
        return NotificationChennels.highInportanceChannel.name;
      case 'low_importance_channel':
        return NotificationChennels.lowInportanceChannel.name;
      default:
        return NotificationChennels.highInportanceChannel.name;
    }
  }
}

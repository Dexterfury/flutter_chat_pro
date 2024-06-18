import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_pro/push_notification/navigation_controller.dart';
import 'package:flutter_chat_pro/push_notification/notification_channels.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> createNotificationChannelAndInitialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

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

  static Future<void> onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // handle notification taps here on IOS
    log('Body: $body');
    log('payload: $payload');
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationRespons) {
    log('onDidReceiveNotificationResponse : $notificationRespons');
    final payload = notificationRespons.payload;
    if (payload != null) {
      // convert payload to remoteMessage and handle interaction
      final message = RemoteMessage.fromMap(jsonDecode(payload));
      log('message: $message');
      navigationControler(
          context: navigatorKey.currentState!.context, message: message);
    }
  }

  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse notificationRespons) {
    log('BackgroundPayload : $notificationRespons');
  }

  static displayNotification(RemoteMessage message) {
    log('display notification: $message');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = notification?.android;
    AppleNotification? apple = notification?.apple;

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
        ),
        iOS: DarwinNotificationDetails(
          sound: apple?.sound?.name,
          presentSound: true,
          presentBadge: true,
          presentAlert: true,
        ),
      ),
      payload: jsonEncode(message.toMap()),
    );
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

import 'package:driver_application/pages/validate_driver.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String? driveruid;

  // Initialize the notifications plugin
  Future<void> initNotifications() async {
    // Initialize the notification plugin
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Remove onSelectNotification from initialization settings
    final InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);

    // Initialize Flutter Local Notifications without onSelectNotification
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // Request permissions for iOS
    await _firebaseMessaging.requestPermission();

    // Get the FCM token
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');

    // Background notifications handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Foreground notifications handler (when the app is in the foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleForegroundMessage(message);
      // Show a local notification when the app is in the foreground
      _showLocalNotification(message);
    });

    // Handle notification when the app is opened from a notification (foreground to background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message);
    });

    // Handle the initial message when the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        handleNotificationTap(message);
      }
    });
  }

  // Handle background and terminated notifications
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');

    driveruid = message.data['driverUid'] ?? '';
  }

  // Handle notifications when the app is in the foreground
  Future<void> handleForegroundMessage(RemoteMessage message) async {
    print('Foreground notification received');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');

    driveruid = message.data['driverUid'] ?? '';

    // Optionally handle further tasks here
  }

  // Handle when the notification is tapped (opened from background/terminated state)
  Future<void> handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');

    driveruid = message.data['driverUid'] ?? '';

    // Navigate to ValidateDriverPage with driverUid if needed
    if (driveruid != null) {
      // For demonstration purposes:
      print("Navigating to the ValidateDriverPage with driverUid: $driveruid");
/*
      // Use navigatorKey to navigate
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ValidateDriverPage(driverUid: driveruid!),
        ),
      );

 */
    }
  }

  // Method to show a local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: message.data.toString(),
    );
  }

  // Called when the user taps on the notification
  Future<void> onNotificationTapped(String? payload) async {
    if (payload != null) {
      print("Notification tapped with payload: $payload");
      handleNotificationTap(RemoteMessage(data: {'driverUid': payload}));
    }
  }
}
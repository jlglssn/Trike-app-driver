import 'package:firebase_messaging/firebase_messaging.dart';

// Subscribe to the "drivers" topic
Future<void> subscribeDriverToTopic() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    // Replace "drivers" with the topic you want (e.g., all drivers)
    await messaging.subscribeToTopic('active_drivers');
    print('Driver subscribed to topic: active_drivers');
  } catch (e) {
    print('Failed to subscribe driver to topic: $e');
  }
}

Future<void> subscribeDriverToAdminTopic() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    // Replace "drivers" with the topic you want (e.g., all drivers)
    await messaging.subscribeToTopic('admin');
    print('Driver subscribed to topic: admin');
  } catch (e) {
    print('Failed to subscribe driver to topic: $e');
  }
}

// Unsubscribe from the "drivers" topic
Future<void> unsubscribeDriverFromTopic() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    await messaging.unsubscribeFromTopic('active_drivers');
    print('Driver unsubscribed from topic: active_drivers');
  } catch (e) {
    print('Failed to unsubscribe driver from topic: $e');
  }
}
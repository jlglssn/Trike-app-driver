import 'package:driver_application/admin_pages/admin_panel_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


class NotificationService {
  static void initialize(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Check if the notification has a body
      if(message.data['page'] == 'pending_driver'){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdminPanelPage(),
          ),
        );
      }
      else if (message.data['notifType'] == 'ride_request'){
        if (message.notification != null) {
          _showDialog(context, message.notification!.title, message.notification!.body, message.data);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate to AnotherPage when notification is clicked
      if(message.data['page'] == 'pending_driver'){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdminPanelPage(),
          ),
        );
      }else if (message.data['notifType'] == 'ride_request'){
        if (message.notification != null) {
          _showDialog(context, message.notification!.title, message.notification!.body, message.data);
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('Handling background message: ${message.notification?.title}');
    // Handle background message logic here
  }

  static void _showDialog(BuildContext context, String? title, String? body, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(body ?? 'You have a new notification.'),
              SizedBox(height: 10),
              Text('Passenger: ${data['passenger']}'),
              Text('Pick Up Address: ${data['pickUpAddress']}'),
              Text('Drop Off Address: ${data['dropOffAddress']}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
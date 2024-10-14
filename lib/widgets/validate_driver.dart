import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ValidateDriver extends StatefulWidget {
  final String driverToken;

  const ValidateDriver({super.key,
    required this.driverToken
  });

  @override
  _ValidateDriverState createState() => _ValidateDriverState();
}

class _ValidateDriverState extends State<ValidateDriver> {
  String driverToken = 'No driver token received';



  @override
  void initState() {
    super.initState();

    // Setup Firebase Cloud Messaging
    setupFCM();
  }

  void setupFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // This is triggered when the app is in the foreground
      print('Notification Title: ${message.notification?.title}');
      print('Notification Body: ${message.notification?.body}');

      if (message.data.isNotEmpty) {
        // Access the custom data
        String token = message.data['driverToken'] ?? 'No driver token found';

        // Update the UI with the driver token
        setState(() {
          driverToken = token;
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // This is triggered when the app is opened from the background
      if (message.data.isNotEmpty) {
        String token = message.data['driverToken'] ?? 'No driver token found';

        // Update the UI with the driver token
        setState(() {
          driverToken = token;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Data Display'),
      ),
      body: Center(
        child: Text(
          'Driver Token: $driverToken',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
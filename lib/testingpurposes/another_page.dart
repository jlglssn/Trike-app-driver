import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AnotherPage extends StatelessWidget {
  final RemoteMessage message;

  AnotherPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Another Page')),
      body: Center(
        child: Text('Notification Clicked: ${message.notification?.title}'),
      ),
    );
  }
}

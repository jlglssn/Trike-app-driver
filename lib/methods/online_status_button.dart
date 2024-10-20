import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class OnlineStatusButton extends StatefulWidget {
  @override
  _OnlineStatusButtonState createState() => _OnlineStatusButtonState();
}

class _OnlineStatusButtonState extends State<OnlineStatusButton> {
  bool isOnline = false;

  void toggleOnlineStatus() {
    setState(() {
      isOnline = !isOnline;
    });

    if (isOnline) {
      subscribeDriverToTopic();
    } else {
      unsubscribeDriverFromTopic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: expandBottomTopSheet,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 20),
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey.shade200,
              ),
              child: OutlinedButton(
                onPressed: () {
                  toggleOnlineStatus();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: isOnline
                      ? Color.fromARGB(255, 255, 87, 34)
                      : Color.fromARGB(255, 75, 201, 104),
                  side: BorderSide(
                    color: isOnline
                        ? Color.fromARGB(150, 255, 87, 34)
                        : Color.fromARGB(150, 75, 201, 104),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isOnline ? "Go Offline" : "Go Online",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void subscribeDriverToTopic() {
    FirebaseMessaging.instance.subscribeToTopic('drivers');
    print('Driver is now online and subscribed to the topic.');
  }

  void unsubscribeDriverFromTopic() {
    FirebaseMessaging.instance.unsubscribeFromTopic('drivers');
    print('Driver is now offline and unsubscribed from the topic.');
  }

  // Dummy method for the expandBottomTopSheet action
  void expandBottomTopSheet() {
    // Your expand action goes here
  }
}

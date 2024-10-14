import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AccessData extends StatefulWidget {
  @override
  _AccessDataState createState() => _AccessDataState();
}

class _AccessDataState extends State<AccessData> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  String? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Method to access certain data from Firebase Realtime Database
  void _getUserData() async {
    String userId = '1KQqBphSMdRNb5nqjoKdc6hstIX2'; // Replace with your user ID or logic to get the user ID

    try {
      DatabaseReference userRef = _databaseRef.child('users').child(userId);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> user = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          userData = user['name']; // Replace 'name' with the key you want to access
        });
      } else {
        print('No data available');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Realtime Database'),
      ),
      body: Center(
        child: userData != null ? Text('User Data: $userData') : CircularProgressIndicator(),
      ),
    );
  }
}

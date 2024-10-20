import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../methods/fetchUserData.dart';
import '../methods/push_notification_service.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  Future<void> updateStatus(String driverUid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('drivers').child(driverUid);
    String userName = await fetchUserData.fetchUserName();
    String? token = await fetchUserData.getDriverToken(driverUid);

    ref.update({
      'accountStatus': 'approved', // Update accountStatus to approved
    }).then((_) {
      // Success message or additional actions
      print('Account status updated successfully.');
    }).catchError((error) {
      // Handle any errors
      print('Failed to update account status: $error');
    });

    if (token != null) {
      PushNotificationService.sendNewDriverAccountStatusNotification(token, true, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("First Page"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to SecondPage when button is pressed
            updateStatus('fRPgcykGRZOLMrVkfR6P2d:APA91bE6GXM35vJoforBD5F8QvDPZA5xoqCo-Kgrq2KDAc_dmHPbi5p_ZLK_XWGWPowT-W-wk9AmE6xyL3co-bhKc-u_dbWFq0D1uhLFFQGetmqdP9SqD2IrnVzvQZjrewkSxm3LW_eD');
          },
          child: Text('Update status'),
        ),
      ),
    );
  }
}

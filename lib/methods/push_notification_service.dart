import 'dart:convert';
import 'dart:developer';
import 'package:driver_application/methods/fetchUserData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize local notifications for displaying in foreground
  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "trike-toda-application",
      "private_key_id": "547c09337479b98dbb84e616499dbd0497cc38a5",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDnxFXViNQ63Hkj\nIwPbUCvSBs6aeEUXH4Uj4ZMRJvUgC8lqzuA/wWpKNJ0lT2On2/kBmQKlKLcLmAoi\neyWDJxjCgi71XOjGJXOmPZ5ogU+YLP/EgnfyT/bmpCFlDmcoaAXwbVIh92FZRgn+\n9RYMHBJW5ei4TEFh/vw+L5vI/BwPhXT8qnjFySGvJJbvkC85iNv2+lZj7/DtZ6Ku\nsBtmoxaxkd1wxBoKAi2bSYoVLTfoXjZXzhBd4m/uf+MkZyfD6RA3vLvMxC6AYkd2\nYwNTKZi9pAY1YDAFh2XDlQ4Kzfp6kPYtIyA1UNAOF2f3fUxx1DEv7wKRMqFcl3fa\nRsmmfMDXAgMBAAECggEAB1uYTf+2CthWInW3QjMmg0Yi59WmMriWBXmX0jndP3fE\n5cRMtIKX/dHzf8e6k+kVAF0gVF8ZYtaN9z2yvge83FkZHItLsafUcBRabMgOKIqc\nCKULtBLErGyoW+Rgl7mDaQqYk8XCvo7Nhd1ulAmN0loiLBeoy7jImmVePnKigWuU\nUKoxcreDqGVJxKGG1qIrZi/RpX0SIuxzdyqURzeVb2FbNWSD2+YcqrhJKMH3S04/\nGCwb9gYIy9DmuQOMBdUD5d7LUKNf1I+9IDvakE9MWCOrLCN0z1b+lzN3fORKuXge\n7NWFHSzLBzDcsLzgxYp8DCPFk/eo8rJO2zvOg5JWAQKBgQD6bkkEhUg5XzFAdkd7\nxrBwgZjISNFy0KAzxSpIikn13EveNjEJhVvR+30rJYkjFN72SC49D6A6o6y9N5B1\nDf/q6LvKqc3yIeKLUkaN5V9OAL8SHQH2oUxmjOr05C9rJ0GoBS8kRCFRCocoHU4/\npe0V3QNjiXA63v2XkHG0I2tHwQKBgQDs68u23VFd4d5merTnUWTuVSJv2itn0yCA\n9W9SiMQhc+bUbFFhmvoZJh1QHONIswj5YfxEYjEymo8OfLIUV7UvOAhRvhZPXF9T\nPctl8MKeMfWhpRZSE/XI8e3T69306wp+RX+7fMxVZGTz7mF82tRrb6EXgQh1G0IU\nDt2oZYDulwKBgGm4s0SgS7xErpMrG8RqPcRRQcGT1DAnWOpiGxaiotSTWsgFkrAV\nR40fIVlcsEdKIVJRaIvIk/kNbfg3g9mWvmpaNCU7iEDnAy+T3Us8AP76G6+25URM\nFefZJ7uYtVgEK5iWD6+8v1/qFOLfdFA0aSFou2yC8gk4aFBa31WP+lNBAoGBAOPr\nZzvRJ8CgVLrTmwrZU7awMgPWp2EnS6Kj+mc06TGhdVOvrI6wb58X+qUiVUiP67c1\nm2ER8XBUHgF61joZslTtm5s/uei43X+P+AdmmWNkfn/1+EYXq6CXlQsFYq6GGr8l\nDt+IDG6tuSytjB13y1hbuGaLHF7ETUpMjtK8a0+bAoGBAOidoGRhRnJDOLh3O/iY\nydYGkognOCAKn+uNw8OoDyiaQaKEd1JQQcSSp1yLXTT++85AA8CCmHFA2lf/FdOm\nH3aTMsCfvg1qRqTg1+JxPY8HchoDhFi1rdJDj8AsM3tAa4F+431RA+FgK/Z9o6Ga\n4qwMEKvFfa7NSK5fvoX+oSbr\n-----END PRIVATE KEY-----\n",
      "client_email": "trike-app@trike-toda-application.iam.gserviceaccount.com",
      "client_id": "102947107974353290789",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/trike-app%40trike-toda-application.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // get the access token
    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    client.close();

    return credentials.accessToken.data;
  }

  static String getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;  // This returns the UID of the currently authenticated user
    } else {
      return "No user is currently signed in.";
    }
  }

  static sendNewDriverRegisteredNotification(String deviceToken,
      BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    String? token = await messaging.getToken();

    final String serverAccessToken = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/trike-toda-application/messages:send';

    final name = await fetchUserData.fetchUserName();

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "New Driver Registered!",
          'body': "$name registered as a new driver."
        },
        'data': {
          'newDriverRegistered' : '$name',
          'driverToken': token,
          'driverUid' : getCurrentUserUid()
        }
      }
    };

    final response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessToken',
      },
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      // Notification sent successfully
      print('Notification sent to driver successfully.');
    } else {
      // Handle failure
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  static sendNewDriverAccountStatusNotification(
      String deviceToken,
      bool isValidated,
      BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    String? token = await messaging.getToken();

    final String serverAccessToken = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/trike-toda-application/messages:send';

    final name = await fetchUserData.fetchUserName();

    // Define the message content based on validation status
    String notificationTitle;
    String notificationBody;
    String newDriverStatus;

    if (isValidated) {
      notificationTitle = "Driver Account Approved!";
      notificationBody = "Your account has been validated and approved as a new driver.";
      newDriverStatus = 'approved';
    } else {
      notificationTitle = "Driver Account Not Approved";
      notificationBody = "Your account has not been approved due to some incorrect data submitted.";
      newDriverStatus = 'not_approved';
    }

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': notificationTitle,
          'body': notificationBody,
        },
        'data': {
          'newDriverRegistered': name,
          'driverToken': token,
          'driverUid': getCurrentUserUid(),
          'driverStatus': newDriverStatus,
        }
      }
    };

    final response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessToken',
      },
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      // Notification sent successfully
      print('Notification sent to driver successfully.');
    } else {
      // Handle failure
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
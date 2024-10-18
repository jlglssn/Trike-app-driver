import 'dart:io';
import 'package:driver_application/api/firebase_api.dart';
import 'package:driver_application/pages/home_page.dart';
import 'package:driver_application/pages/validate_driver.dart';
import 'package:driver_application/testingpurposes/access_data.dart';
import 'package:driver_application/widgets/bottom_navigation_bar.dart';
import 'package:driver_application/widgets/setup_token.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'appInfo/app_info.dart';
import 'authentication/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBl0OTiZegcNeX0wbNFmFXbUyoUtTLzGRo",
          authDomain: "trike-toda-application.firebaseapp.com",
          projectId: "trike-toda-application",
          storageBucket: "trike-toda-application.appspot.com",
          messagingSenderId: "654955706625",
          databaseURL: 'https://trike-toda-application-default-rtdb.asia-southeast1.firebasedatabase.app',
          appId: "1:654955706625:web:4cb1e2dd4dfdd09d4b4300",
          measurementId: "G-SN0HRBL5ZH",
        ),
      );
    } else {
      await Firebase.initializeApp();
      await FirebaseApi().initNotifications();
    }
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  await _checkAndRequestLocationPermission();

  runApp(const MyApp());
}

Future<void> _checkAndRequestLocationPermission() async {
  final status = await Permission.locationWhenInUse.status;
  if (status.isDenied) {
    await Permission.locationWhenInUse.request();
  } else if (status.isPermanentlyDenied) {
    // Open app settings if permission is permanently denied
    await openAppSettings();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _driverToken;

  @override
  void initState() {
    super.initState();

    _submitTokenToDatabase(context);
  }

  // When notification tapped, pass the context
  void onNotificationTapped(String payload) {
    // Navigate to your desired screen here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ValidateDriverPage(driverUid: payload)),
    );
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      // Navigate to the desired screen using the payload
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ValidateDriverPage(driverUid: payload)),
      );
    }
  }

  Future<void> _submitTokenToDatabase(BuildContext context) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      String? token = await messaging.getToken();

      FirebaseAuth auth = FirebaseAuth.instance;
      User? firebaseUser = auth.currentUser;

      if (firebaseUser != null) {
        // Storing token in Firebase Realtime Database
        Map<String, String> tokenDataMap = {
          "token": token!,
        };

        await FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(firebaseUser.uid)
            .update(tokenDataMap); // Use `update` to avoid overwriting other data

        print("Token: $token updated");
      }
    } catch (e) {
      print("Error during token submission: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Users App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffefefef)),
          useMaterial3: true,
          fontFamily: 'Roboto', // Set default font family
        ),
        debugShowCheckedModeBanner: false,
        home: AuthCheck(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => MainScreen(),
          // Other routes can be added here
        },
      ),
    );
  }
}

// New widget to check user authentication status
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking auth status
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          // User is logged in, navigate to home screen
          return MainScreen();
        } else {
          // User is not logged in, navigate to login screen
          return const LoginScreen();
        }
      },
    );
  }
}

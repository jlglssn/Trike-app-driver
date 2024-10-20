import 'dart:io';
import 'package:driver_application/api/firebase_api.dart';
import 'package:driver_application/methods/fetchUserData.dart';
import 'package:driver_application/methods/topic_subscription.dart';
import 'package:driver_application/pages/home_page.dart';
import 'package:driver_application/authentication/login_screen.dart';
import 'package:driver_application/admin_pages/pending_drivers_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'appInfo/app_info.dart';
import 'methods/notification_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

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
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    NotificationService.initialize(context);
    _submitTokenToDatabase(context);
    _printToken(context);
    _subsribeToAdmin(context);
  }

  Future<void> _subsribeToAdmin(BuildContext context) async{
    if(await fetchUserData.fetchIsAdmin()){
      subscribeDriverToAdminTopic();
    }
  }

  Future<void> _printToken(BuildContext context) async{
    await messaging.requestPermission();

    String? token = await messaging.getToken();

    print('Token: $token');
  }

  Future<void> _submitTokenToDatabase(BuildContext context) async {
    try {
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
            .child("drivers")
            .child(firebaseUser.uid)
            .update(tokenDataMap);

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
        navigatorKey: navigatorKey,  // Set the navigator key here
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffefefef)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
        home: AuthCheck(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => HomePage(),
          '/pending_drivers': (context) => PendingDriversPage(),
        },
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          return HomePage();  // User is logged in, navigate to home
        } else {
          return const LoginScreen();  // Not logged in, navigate to login
        }
      },
    );
  }
}
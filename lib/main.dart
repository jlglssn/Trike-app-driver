import 'dart:io';
import 'package:driver_application/widgets/bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'appInfo/app_info.dart';
import 'authentication/login_screen.dart';

void main() async{
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
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
        routes: {
          '/home': (context) => MainScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

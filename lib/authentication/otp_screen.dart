import 'package:driver_application/authentication/upload_driverfiles.dart';
import 'package:driver_application/pages/home_page.dart';
import 'package:driver_application/widgets/bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:driver_application/authentication/login_screen.dart';

import '../global.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final bool isSignup; // Flag to determine signup or login
  final String? name;
  final String? phoneNumber;
  final String? password;

  OtpScreen({
    required this.verificationId,
    required this.isSignup,
    this.name,
    this.phoneNumber,
    this.password,
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}


class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isPasswordVisible = false; // Add this boolean to track the password visibility

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _submitOTP(BuildContext context) async {
    String otp = _otpController.text.trim();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      await _firebaseMessaging.requestPermission();
      final token = await _firebaseMessaging.getToken();

      if (firebaseUser != null) {
        if (widget.isSignup) {
          // Store user information in Firebase Realtime Database for signup
          Map<String, String> userDataMap = {
            "name": widget.name!,
            "phone": "+63${widget.phoneNumber!}",
            "password": widget.password!,
            "id": firebaseUser.uid,
            "accountStatus": "pending",
            "token": token!,
          };

          Map<String, bool> adminDataMap = {
            "isAdmin": false
          };

          await FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(firebaseUser.uid)
              .set(userDataMap);

          await FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(firebaseUser.uid)
              .update(adminDataMap);


          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UploadDriverFilesScreen()),
          );
        } else {
          // Just sign in the user for login without saving extra info

          // Fetch user information from Firebase to check if they are admin
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(firebaseUser.uid);

          DataSnapshot snapshot = await userRef.get();
          if (snapshot.exists) {
              // User is not an admin
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()), // Normal user screen
              );
          }
        }
      }
    } catch (e) {
      print("Error during OTP verification: ${e.toString()}");
      showErrorDialog(context, "OTP verification failed. Please try again.");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Phone Number Verification",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/images/otp.png',
                width: double.infinity,
                fit: BoxFit.cover,  // Optional: Adjust the fit as per your requirement
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  label: const Text("OTP Code"),
                  prefixIcon: const Icon(Icons.password_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 204, 245, 215), width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 204, 245, 215), width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    _submitOTP(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 75, 201, 104),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: const Text("Verify"),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
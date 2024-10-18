import 'package:driver_application/authentication/otp_screen.dart';
import 'package:driver_application/authentication/upload_driverfiles.dart';
import 'package:driver_application/methods/fetchUserData.dart';
import 'package:driver_application/widgets/bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:driver_application/authentication/passwordreset_screen.dart';
import 'package:driver_application/authentication/registration_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:driver_application/widgets/error_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../methods/phonenum_formatter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// Error dialog
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => ErrorDialog(messageTxt: message),
  );
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  String? token;

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  bool isPasswordVisible = false; // Add this boolean to track the password visibility


  String phoneNumberError = '';
  String passwordError = '';

  void initState() {
    super.initState();

    // Initialize local notifications for showing foreground notifications
    var androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: androidSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permissions
    _firebaseMessaging.requestPermission();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification received: ${message.notification?.title}");
      _showNotification(message);
    });
  }

  ///FOR FOREGROUND NOTIFICATION
  Future<void> _showNotification(RemoteMessage message) async {
    var androidDetails = const AndroidNotificationDetails(
      'channel_id', 'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  validateLogInForm() async {
    final String password = passwordTextEditingController.text.trim();
    String phoneNumber = "+63" + _phoneNumberController.text.trim();  // Assuming you have a phone controller

    // RegEx patterns
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~])(?=.*[0-9])(?=.*[a-z]).{8,}$');

    setState(() {
      passwordError = '';
      phoneNumberError = '';
    });

    bool hasError = false;

    // Password validation
    if (!passwordRegExp.hasMatch(password)) {
      setState(() {
        passwordError = "Invalid password.";
      });
      hasError = true;
    }

    if (!hasError) {
      try {
        // Fetch all drivers' data from Firebase
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child('drivers');
        DataSnapshot snapshot = await userRef.get();

        // Ensure snapshot exists and contains data
        if (snapshot.exists) {
          // Manually cast the snapshot value to a Map<String, dynamic>
          Map<String, dynamic> driversData = Map<String, dynamic>.from(snapshot.value as Map);

          // Iterate over each driver (using their UID)
          for (String uid in driversData.keys) {
            // Cast each driver's data to a Map<String, dynamic>
            Map<String, dynamic> driverData = Map<String, dynamic>.from(driversData[uid]);

            // Check if the phone number matches the input
            if (driverData.containsKey('phone') && driverData['phone'] == phoneNumber) {

              // Retrieve account status and password
              String accountStatus = driverData['accountStatus'] ?? '';
              String dbPassword = driverData['password'] ?? '';

              // Check account status and password
              if (accountStatus == 'pending') {
                // Show dialog for pending validation
                showPendingValidationDialog();
              } else if (accountStatus == 'approved') {
                // If the account is approved, check the password
                if (dbPassword == password) {
                  // If passwords match, proceed with login
                  _submitPhoneNumber(context);
                } else {
                  setState(() {
                    passwordError = "Password is incorrect.";
                  });
                }
              } else {
                // Handle other account statuses if necessary
                setState(() {
                  phoneNumberError = "Account is not valid. Please contact support.";
                });
              }
              break;  // Exit the loop once the matching phone number is found
            }
          }
        } else {
          // Handle case where no user data is found in the database
          setState(() {
            phoneNumberError = "No data found for phone number $phoneNumber.";
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            phoneNumberError = "Couldn't find your Trike Account.";
          } else if (e.code == 'wrong-password') {
            passwordError = "Incorrect password.";
          } else {
            phoneNumberError = "An error occurred. Please try again.";
          }
        });
      }
    }
  }

  void showPendingValidationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pending Account Validation"),
          content: Text("The admin is still validating your account."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPhoneNumber(BuildContext context) async {
    String phoneNumber = "+63" + _phoneNumberController.text.trim();  // Ensure the phone number includes the country code
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Handle automatic verification (optional)
        try {
          await auth.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } catch (e) {
          print("Error during automatic sign-in: ${e.toString()}");
          showErrorDialog(context, "Error during automatic sign-in. Please try again.");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
        print("Verification failed: ${e.message}");
        showErrorDialog(context, e.message ?? "Verification failed. Please try again.");
      },
      codeSent: (String verificationId, int? resendToken) {
        // OTP code has been sent, navigate to the OTP screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              verificationId: verificationId,
              isSignup: false, // Login flag
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle auto-retrieval timeout
        print("Auto-retrieval timeout: $verificationId");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center( // Center the content vertically
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              // Center the Column's children vertically
              children: [
                const SizedBox(height: 52),
                Image.asset(
                  'assets/images/Login.png',
                  width: double.infinity,
                  fit: BoxFit.cover,  // Optional: Adjust the fit as per your requirement
                ),
                const Text(
                  "Hello!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  "Sign in to your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0, horizontal: 16.0),
                  child: Column(
                    children: [
                      // Email Text Field
                      TextField(
                        controller: _phoneNumberController,
                        keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                        inputFormatters: [
                          //PhoneNumberDisplayFormatter(),
                          LengthLimitingTextInputFormatter(10)
                        ],
                        decoration: InputDecoration(
                          prefixText: "+63 ",
                          labelText: "Phone Number",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          errorText: phoneNumberError.isEmpty? null
                              : phoneNumberError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password Text Field
                      TextField(
                        obscureText: !isPasswordVisible,
                        controller: passwordTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          errorText: passwordError.isEmpty
                              ? null
                              : passwordError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 1),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible ? Icons.visibility : Icons
                                  .visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),


                      const SizedBox(height: 10),
                      // Forgot Password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (
                                  context) => const PasswordResetScreen()),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Log in button
                      OutlinedButton(
                        onPressed: () {
                          validateLogInForm();
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Color.fromARGB(255, 75, 201, 104),
                          side: const BorderSide(
                              color: Color.fromARGB(150, 75, 201, 104), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Sign up link
                      TextButton(
                        onPressed: null,
                        // No action needed for the button itself
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              color: Colors
                                  .grey, // Style for the first part of the text
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Register",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 75, 201, 104),
                                  // Different color for the clickable text
                                  fontWeight: FontWeight
                                      .bold, // Make the text bold
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (
                                            c) => const RegistrationScreen()));
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

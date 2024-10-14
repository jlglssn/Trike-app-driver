import 'package:driver_application/authentication/upload_driverfiles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:driver_application/authentication/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../methods/phonenum_formatter.dart';
import 'otp_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  String nameError = '';
  String phoneError = '';
  String emailError = '';
  String passwordError = '';
  String confirmPasswordError = '';


  Future<bool> _validateSignupFields() async {
    String fullName = _nameController.text.trim();
    String phoneNumber = "+63" + _phoneNumberController.text.trim();  // Ensure phone number includes country code
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    final RegExp nameRegExp = RegExp(r'^[a-zA-Z ]{3,}$');
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~])(?=.*[0-9])(?=.*[a-z]).{8,}$');

    setState(() {
      nameError = '';
      phoneError = '';
      passwordError = '';
      confirmPasswordError = '';
    });

    bool hasError = false;

    // Check if the phone number already exists in the database
    bool isNumberUsed = await isPhoneNumberUsed(phoneNumber);

    // Name validation
    if (!nameRegExp.hasMatch(fullName)) {
      setState(() {
        nameError = "Name must be at least 3 letters or more characters.";
      });
      hasError = true;
    }

    // Phone number validation
    if (isNumberUsed) {
      setState(() {
        phoneError = "Phone number already exists.";
      });
      hasError = true;
    }

    // Password validation
    if (!passwordRegExp.hasMatch(password)) {
      setState(() {
        passwordError = "Password should be: "
            "\nAt least 8 characters long "
            "\nMinimum one uppercase"
            "\nMinimum one lowercase"
            "\nMinimum one number"
            "\nMinimum one symbol";
      });
      hasError = true;
    }

    // Confirm password validation
    if (confirmPassword.isEmpty || password != confirmPassword) {
      setState(() {
        confirmPasswordError = "Passwords do not match";
      });
      hasError = true;
    }

    return !hasError;  // Return false if any validation failed
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Method to check if phone number exists in the database
  Future<bool> isPhoneNumberUsed(String phoneNumber) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('drivers');
    DataSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      // Cast the snapshot value to a Map<String, dynamic>
      Map<String, dynamic> driversData = Map<String, dynamic>.from(snapshot.value as Map);

      // Iterate over each driver and check if the phone number matches
      for (String uid in driversData.keys) {
        Map<String, dynamic> driverData = Map<String, dynamic>.from(driversData[uid]);

        // Check if the phone number matches the one in the database
        if (driverData.containsKey('phone') && driverData['phone'] == phoneNumber) {
          return true;  // Phone number already exists
        }
      }
    }

    return false;  // Phone number does not exist
  }

  // Method for signing up the user with phone number
  Future<void> _submitSignUp(BuildContext context) async {
    if (await _validateSignupFields() == false) {
      return; // Stop further execution if validation fails
    }

    String phoneNumber = "+63" + _phoneNumberController.text.trim();

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await auth.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UploadDriverFilesScreen()),
          );
        } catch (e) {
          print("Error during automatic sign-in: ${e.toString()}");
          showErrorDialog(context, "Error during automatic sign-in. Please try again.");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
        showErrorDialog(context, e.message ?? "Verification failed. Please try again.");
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              verificationId: verificationId,
              isSignup: true, // Sign-up flag
              name: _nameController.text.trim(),
              phoneNumber: _phoneNumberController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Auto-retrieval timeout: $verificationId");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 52,),
              const Text(
                "Hello!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900
                ),
              ),
              const Text(
                "Create new Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300
                ),
              ),
              const SizedBox(height: 16,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
                child: Column(
                  children: [
                    // Username Text Field
                    TextField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        errorText: nameError.isEmpty ? null : nameError,
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
                    const SizedBox(height: 16,),
                    // User Phone Text Field
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
                        errorText: phoneError.isEmpty ? null : phoneError,
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
                    const SizedBox(height: 16,),
                    // Password Text Field
                    TextField(
                      obscureText: true,
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        errorText: passwordError.isEmpty ? null : passwordError,
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
                    const SizedBox(height: 16,),
                    // Confirm Password Text Field
                    TextField(
                      obscureText: true,
                      controller: _confirmPasswordController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        errorText: confirmPasswordError.isEmpty ? null : confirmPasswordError,
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
                    const SizedBox(height: 16,),
                    // Register button
                    ElevatedButton(
                      onPressed: () {
                        _submitSignUp(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // Full width
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                          "Next",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 0.1),

              //Text Button that redirects users with existing account to log in screen
              TextButton(
                onPressed: null, // No action needed for the button itself
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(
                      color: Colors.grey, // Style for the first part of the text
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Login",
                        style: const TextStyle(
                          color: Colors.blue, // Different color for the clickable text
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

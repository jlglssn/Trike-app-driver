import 'package:driver_application/authentication/upload_driverfiles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/content/v2_1.dart' as googleapis; // Alias for the googleapis import
import 'package:driver_application/authentication/login_screen.dart';
import 'package:driver_application/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:driver_application/widgets/loading_dialog.dart';
import 'package:driver_application/pages/home_page.dart';

import '../methods/signInWithGoogle.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();

  final PageController _pageController = PageController();

  String nameError = '';
  String phoneError = '';
  String emailError = '';
  String passwordError = '';
  String confirmPasswordError = '';

  validateSignUpForm() {
    final String name = userNameTextEditingController.text.trim();
    final String phone = userPhoneTextEditingController.text.trim();
    final String email = emailTextEditingController.text.trim();
    final String password = passwordTextEditingController.text.trim();
    final String confirmPassword = confirmPasswordTextEditingController.text.trim();


    // RegEx patterns
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z ]{3,}$');
    final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~])(?=.*[0-9])(?=.*[a-z]).{8,}$');

    setState(() {
      nameError = '';
      phoneError = '';
      emailError = '';
      passwordError = '';
      confirmPasswordError = '';
    });

    bool hasError = false;

    if (!nameRegExp.hasMatch(name)) {
      setState(() {
        nameError = "Name must be at least 3 letters or more characters.";
      });
      hasError = true;
    }

    if (phone.length != 11) {
      setState(() {
        phoneError = "Invalid phone number. Must be exactly 11 digits.";
      });
      hasError = true;
    }

    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        emailError = "Invalid email address.";
      });
      hasError = true;
    }

    if (!passwordRegExp.hasMatch(password)) {
      setState(() {
        passwordError = "Password should be: "
            "\nAt least 8 characters long "
            "\nMinimum one uppercase"
            "\nMinimum one number"
            "\nMinimum one symbol";
      });
      hasError = true;
    }

    if(confirmPassword.isEmpty){
      confirmPasswordError = "Passwords do not match";
      hasError = true;
    }
    else if(password != confirmPassword){
      setState(() {
        confirmPasswordError = "Passwords do not match";
      });
      hasError = true;
    }

    if (!hasError) {
      signUpUserNow();
    }
  }

  signUpUserNow() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageTxt: "Please wait..."),
    );

    try {
      final User? firebaseUser = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      )).user;

      Map userDataMap = {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": firebaseUser!.uid,
        "blockStatus": "no",
        "role": "driver",
      };

      await FirebaseDatabase.instance.ref().child("users").child(firebaseUser.uid).set(userDataMap);

      Navigator.pop(context);
      snackBar.showSnackBarMsg("Account created successfully", context);

      // Redirects user to homepage if user's account is valid
      Navigator.push(context, MaterialPageRoute(builder: (c) => const UploadDriverFilesScreen()));
    } on FirebaseAuthException catch (ex) {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      setState(() {
        emailError = ex.message ?? "An error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                      controller: userNameTextEditingController,
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
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
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
                    // Email Text Field
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        errorText: emailError.isEmpty ? null : emailError,
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
                      controller: passwordTextEditingController,
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
                      controller: confirmPasswordTextEditingController,
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
                        validateSignUpForm();
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
                        text: "Login here",
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0), // Adds padding around the entire Column
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Divider with "Or"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey[400],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Or",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Google Login Button
                    OutlinedButton(
                      onPressed: () {
                        AuthService.signInWithGoogle(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // Full width
                        side: const BorderSide(
                          color: Colors.grey, // Border color
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Centers the text & icon
                        children: [
                          // Google logo on the left
                          Image.asset(
                            "assets/images/google_icon.webp",
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8), // Space between the icon and text
                          const Expanded(
                            child: Align(
                              alignment: Alignment.center, // Center the text within the button
                              child: Text(
                                "Login with Google",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

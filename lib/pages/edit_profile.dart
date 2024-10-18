import 'dart:io';
import 'dart:typed_data';
import 'package:driver_application/pages/validate_driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:driver_application/authentication/passwordreset_screen.dart';
import 'package:driver_application/methods/push_notification_service.dart';
import '../methods/custom_page_route.dart';
import '../methods/fetchUserData.dart';
import '../widgets/error_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Error dialog
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => ErrorDialog(messageTxt: message),
  );
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? adminUid;
  String? adminToken;
  String? userName;
  String? dbPassword;
  String? bodyNum;
  String? plateNum;


  Future<void> fetchUID () async {
    String? uid = await fetchUserData.fetchAdminUID();

    adminUid = uid;
  }

  Future<void> fetchToken () async {
    fetchUID();
    userName = await fetchUserData.fetchUserName();
    String? token = await fetchUserData.getDriverToken(adminUid!);

    adminToken = token;
    print(token);
  }

  bool isPasswordVisible = false; // Track password visibility

  File? _imageFile; // File to store the selected image
  String? profileUrl; // URL for profile image from Firebase Storage


  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bodyNumController = TextEditingController();
  final TextEditingController _plateNumController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {

    super.initState();
    fetchUserData.fetchUserName().then((name) {
      _nameController.text = name;
    });
    fetchUserData.fetchUserNumber().then((phone) {
      _phoneController.text = phone;
    });
    fetchUserData.fetchPic().then((url) {
      setState(() {
        profileUrl = url;
      });
    });
    fetchUserData.fetchUserPassword().then((password) {
      setState(() {
        dbPassword = password;
      });
    });
    fetchUserData.fetchBodyNumber().then((bodyNumber) {
      _bodyNumController.text = bodyNumber;
    });
    fetchUserData.fetchPlateNumber().then((plateNumber) {
      _plateNumController.text = plateNumber;
    });
  }

  var auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser;


  changePassword({email, oldPassword, newPassword}) async{
    var cred = EmailAuthProvider.credential(email: email, password: oldPassword);

    await currentUser!.reauthenticateWithCredential(cred).then((value){
      currentUser!.updatePassword(newPassword);
    }).catchError((error){
      print(error.toString());
    });
  }

  //Function's Working
  void selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _imageFile = File(image.path); // Set _imageFile only if image is not null
        });
        // Log the path safely
        if (_imageFile != null) {
          print("Selected image: ${_imageFile!.path}");
        } else {
          print("Image file is null after setting.");
        }
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e"); // Log any error that occurs
    }
  }

  //For Profile Picture -- Still not working
  Future<void> _pickAndUploadProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload image to Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}.jpg');

        try {
          await storageRef.putFile(_imageFile!);
          String downloadUrl = await storageRef.getDownloadURL();

          // Update user's profile picture URL in Firebase Database
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(user.uid);

          await userRef.update({'profileUrl': downloadUrl});

          // Set the new profile URL in the app
          setState(() {
            profileUrl = downloadUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        } catch (e) {
          showErrorDialog(context, "Failed to upload profile picture: $e");
        }
      }
    }
  }

  Future<void> _showPasswordDialogAndSave() async {
    TextEditingController passwordController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevents dialog dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter your password to confirm changes.'),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                String password = passwordController.text.trim();

                if (password.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Re-authenticate user with email and password
                    try {
                      if(password == dbPassword){
                        print("Re-authentication successful");

                        // Call the method to save the updated user information
                        await _updateUserInfo();

                        // Close the dialog after success
                        Navigator.of(context).pop();
                      }
                    } on FirebaseAuthException catch (e) {
                      // Handle incorrect password
                      print("Re-authentication failed: ${e.message}");
                      showErrorDialog(context, "Incorrect password. Please try again.");
                    }
                  }
                } else {
                  // If password field is empty
                  showErrorDialog(context, "Please enter your password.");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not logged in
      showErrorDialog(context, "User is not logged in.");
      return;
    }

    try {
      final User? curuser = FirebaseAuth.instance.currentUser;

      // Reference to Firebase Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);

      // Update user information in the database
      await userRef.update({
        'name': _nameController.text,
        'phone': _phoneController.text,
      });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      // Handle errors
      print("Error updating profile: $e");
      showErrorDialog(context, "Error updating profile. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconBGColor = const Color.fromARGB(255, 204, 245, 215);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // Navigate back to the previous page
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes default back button
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // -- IMAGE with ICON
              Center(
                  child: Column(
                      children:[
                        CircleAvatar(
                          radius: 65.0,
                          backgroundImage: profileUrl != null ? NetworkImage(profileUrl!) // Load the image from the network
                              : const AssetImage('assets/images/driver.png') as ImageProvider, // Fallback to a local image if URL is null or empty
                        ),
                      ]
                  )
              ),

              const SizedBox(height: 50),
              // -- Form Fields
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  label: const Text("Name"),
                  prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.green, width: 2.0), // Green when focused
                  ),
                ),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  label: const Text("Phone"),
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: Colors.grey,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.green, width: 2.0), // Green when focused
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyNumController,
                decoration: InputDecoration(
                  label: const Text("Body Number"),
                  prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.green, width: 2.0), // Green when focused
                  ),
                ),
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _plateNumController,
                decoration: InputDecoration(
                  label: const Text("Plate Number"),
                  prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0), // Default gray color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.green, width: 2.0), // Green when focused
                  ),
                ),
              ),
              const SizedBox(height: 100),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showPasswordDialogAndSave, // Show password dialog and save
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 75, 201, 104), // Background color of the button
                    foregroundColor: Colors.white, // Color of the text and icon on the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Padding inside the button
                  ),
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
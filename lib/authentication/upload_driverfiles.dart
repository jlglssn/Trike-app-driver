import 'dart:io';
import 'package:driver_application/authentication/login_screen.dart';
import 'package:driver_application/methods/push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../global.dart';
import '../methods/fetchUserData.dart';
import 'package:driver_application/widgets/loading_dialog.dart';
import 'package:dotted_border/dotted_border.dart';

import '../widgets/progress_bar.dart';

class UploadDriverFilesScreen extends StatefulWidget {
  const UploadDriverFilesScreen({super.key});

  @override
  State<UploadDriverFilesScreen> createState() => _UploadDriverFilesScreenState();
}

class _UploadDriverFilesScreenState extends State<UploadDriverFilesScreen> {
  TextEditingController bodyNumberTextEditingController = TextEditingController();
  TextEditingController plateNumberTextEditingController = TextEditingController();

  String bodyNumber = "";
  String plateNumber = "";

  String bodyNumberError = '';
  String plateNumberError = '';

  bool isPicBtnEnabled = true;
  bool isLicenseBtnEnabled = true;
  bool isPermitBtnEnabled = true;

  String driverName = 'Unknown User'; // Class-level variable to store the email

  @override
  void initState() {
    super.initState();
    fetchAndStoreName(); // Fetch the email when the widget is initialized
  }

  Future<void> fetchAndStoreName() async {
    String fetchedName = await fetchUserData
        .fetchUserName(); // Fetch the email from the database
    setState(() {
      driverName = fetchedName; // Update the class-level variable
    });
  }

  bool isPicUploaded = false;
  bool isLicenseUploaded = false;
  bool isPermitUploaded = false;


  XFile? pickedFile;
  UploadTask? uploadPicTask;
  UploadTask? uploadLicenseTask;
  UploadTask? uploadPermitTask;


  String picFileName = "";
  String licenseFileName = "";
  String permitFileName = "";

  String picUrl = "";
  String licenseUrl = "";
  String permitUrl = "";

  int index = 0;

  Future<void> uploadUrlToDatabase(String url) async {
    // Get a reference to the database
    final databaseReference = FirebaseDatabase.instance.ref();

    // Get the current user's UID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently signed in.');
      return; // Handle the case when there is no authenticated user
    }

    final String userId = user.uid; // Get the UID of the current user
    final String fileType = '1x1Picture'; // Example file type

    // Set or update the URL in the database
    await databaseReference.child('drivers/$userId/$fileType').set({
      'downloadLink': url,
      'uploadedAt': DateTime.now().toIso8601String(), // Optional: timestamp
    }).then((_) {
      print('URL added to the database successfully!');
    }).catchError((error) {
      print('Failed to add URL: $error');
    });
  }

  Future<void> uploadFile(int index) async {
    if (pickedFile == null) return;
    final fileExtension = pickedFile!
        .name
        .split('.')
        .last;
    final file = File(pickedFile!.path!);
    String path = "";
    switch (index){
      case 0: //1x1 Pic
        try{
          path = 'Driver-Files/$driverName/${driverName}_1x1Picture.$fileExtension';
          picFileName = '${driverName}_1x1Picture.$fileExtension';

          final ref = FirebaseStorage.instance.ref().child(path);

          setState(() {
            uploadPicTask = ref.putFile(file);
          });

          final snapshot = await uploadPicTask!.whenComplete(() {});

          final urlDownload = await snapshot.ref.getDownloadURL();
          print('Download Link: $urlDownload');
          picUrl = urlDownload;

          await uploadUrlToDatabase(urlDownload);

          setState(() {
            uploadPicTask = null;
          });

          isPicUploaded = true;
        } catch (e) {
          Navigator.of(context).pop(); // Dismiss the loading dialog
          _showErrorDialog("An error occurred. Please try again.\n\nError code: $e");
        }


        break;
      case 1: //License
        try{
          path = 'Driver-Files/$driverName/${driverName}_d-license.$fileExtension';
          licenseFileName = '${driverName}_d-license.$fileExtension';

          final ref = FirebaseStorage.instance.ref().child(path);

          setState(() {
            uploadLicenseTask = ref.putFile(file);
          });

          final snapshot = await uploadLicenseTask!.whenComplete(() {});

          final urlDownload = await snapshot.ref.getDownloadURL();
          print('Download Link: $urlDownload');
          licenseUrl = urlDownload;

          await uploadUrlToDatabase(urlDownload);

          setState(() {
            uploadLicenseTask = null;
          });
          isLicenseUploaded = true;
        } catch (e) {
          Navigator.of(context).pop(); // Dismiss the loading dialog
          _showErrorDialog("An error occurred. Please try again.\n\nError code: $e");
        }
        break;
      case 2: //Permit
        try {
          path =
          'Driver-Files/$driverName/${driverName}_op-permit.$fileExtension';
          permitFileName = '${driverName}_op-permit.$fileExtension';

          final ref = FirebaseStorage.instance.ref().child(path);

          setState(() {
            uploadPermitTask = ref.putFile(file);
          });

          final snapshot = await uploadPermitTask!.whenComplete(() {});

          final urlDownload = await snapshot.ref.getDownloadURL();
          print('Download Link: $urlDownload');
          permitUrl = urlDownload;

          await uploadUrlToDatabase(urlDownload);

          setState(() {
            uploadPermitTask = null;
          });

          isPermitUploaded = true;
        } catch (e) {
          Navigator.of(context).pop(); // Dismiss the loading dialog
          _showErrorDialog("An error occurred. Please try again.\n\nError code: $e");
        }
        break;
    }
  }

  void showUploadSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Complete'),
          content: const Text(
              'Your files have been uploaded successfully. Please wait while the TODA Admin validates your account.\n\nYou will receive a notification once the validation is complete'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> submit() async {
    if(isPicUploaded == true && isLicenseUploaded == true && isPermitUploaded == true){
      var userName = await fetchUserData.fetchUserName();
      var adminUid = await fetchUserData.fetchAdminUID();
      final token = await fetchUserData.getDriverToken(adminUid!);

      PushNotificationService.sendNewDriverRegisteredNotification(token!, context);
      showUploadSuccessDialog(context);

      _insertData(context);
    }
    else{
      _showErrorDialog("Please upload all the required images.");
    }
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Please double check your personal information is correct before confirmation.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and allow modifications
                Navigator.of(context).pop();
              },
              child: const Text('Modify'),
            ),
            TextButton(
              onPressed: () {
                // Call the confirmAction method
                Navigator.of(context).pop();
                submit();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _insertData(BuildContext context) async {
    final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
    String bodyNumber = bodyNumberTextEditingController.text.trim();
    String plateNumber = plateNumberTextEditingController.text.trim();

    String? userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      // Reference to the 'users' node
      DatabaseReference usersRef = _databaseRef.child('drivers').child(userId!);

      // Data to be inserted
      Map<String, dynamic> userData = {
        'bodyNumber': bodyNumber,
        'plateNumber': plateNumber,
        'picUrl' : picUrl,
        'licenseUrl' : licenseUrl,
        'permitUrl' : permitUrl
      };

      // Insert data
      await usersRef.update(userData);

      print("User data inserted successfully!");
    } catch (e) {
      print("Failed to insert user data: $e");
    }
  }

  Future<void> upload(String fileName, UploadTask? taskName) async {
    if (pickedFile == null) return;
    final fileExtension = pickedFile!
        .name
        .split('.')
        .last;
    final file = File(pickedFile!.path!);
    String path = "";
    path = 'Driver-Files/$driverName/${driverName}_1x1Picture.$fileExtension';
    picFileName = '${driverName}${fileName}.$fileExtension';
  }

  Future<void> selectFile(int index) async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage;

    // Pick an image from the gallery or take a new one
    pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    // Check if an image was picked
    if (pickedImage == null) return;

    setState(() {
      pickedFile = pickedImage; // Store the picked image file
    });

    // Perform actions based on the index
    switch (index) {
      case 0:
        isPicBtnEnabled = false;
        uploadFile(0);
        break;
      case 1:
        isLicenseBtnEnabled = false;
        uploadFile(1);
        break;
      case 2:
        isPermitBtnEnabled = false;
        uploadFile(2);
        break;
    }
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  validateTrikeInfo() {
    final String bodyNumber = bodyNumberTextEditingController.text.trim();
    final String plateNumber = plateNumberTextEditingController.text.trim();

    // RegEx patterns
    final RegExp bnumRegExp = RegExp(r'^\d{1}-\d{4}$');
    final RegExp pnumRegExp = RegExp(r'^[A-Z]{3}[0-9]{3}$');

    setState(() {
      bodyNumberError = '';
      plateNumberError = '';
    });

    bool hasError = false;

    if (!bnumRegExp.hasMatch(bodyNumber)) {
      setState(() {
        bodyNumberError = "Invalid Body Number";
      });
      hasError = true;
    }

    if (!pnumRegExp.hasMatch(plateNumber)) {
      setState(() {
        plateNumberError = "Invalid Plate Number\n\nPlease follow this format:\nABC 123";
      });
      hasError = true;
    }

    if (!hasError) {
      showConfirmationDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Additional Driver Information",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      // Added an AppBar for better UX
      body: SingleChildScrollView( // Enable scrolling for the entire body
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column( // Change to Column to stack children vertically
            children: [
              // Container for Pic Btn
              Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: bodyNumberTextEditingController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Body Number",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: "1-2345",  // Hint for expected input
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          errorText: bodyNumberError.isEmpty ? null : bodyNumberError,
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
                      SizedBox(height: 20,),
                      TextField(
                        controller: plateNumberTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Plate Number",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: "ABC123",  // Hint for expected input
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          errorText: plateNumberError.isEmpty ? null : plateNumberError,
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
                    ],
                  )
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: DottedBorder(
                  borderType: BorderType.Rect,
                  color: Colors.grey, // Border color
                  strokeWidth: 1.3, // Width of the dashed line
                  dashPattern: [5, 5], // Length of dash and gap
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isPicBtnEnabled
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Submit your 1x1 Picture", // Label text
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10), // Space before the label
                            const Icon(
                              Icons.photo_library_outlined,
                              size: 30,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Your photo should be clear and make sure your face is facing front.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10), // Space before the button
                            OutlinedButton(
                              onPressed: () {
                                selectFile(0);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(50, 50),
                                backgroundColor: Color.fromARGB(150, 75, 201, 104),
                                side: const BorderSide(
                                    color: Color.fromARGB(150, 75, 201, 104), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                "Select File",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Icon for file upload
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 204, 245, 215),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.upload_file,
                                      color: Color.fromARGB(150, 75, 201, 104),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Space between icon and file name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          picFileName, // Display file name
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Progress bar with percentage text
                                        ProgressBar(uploadTask: uploadPicTask),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Container for Driver's License Btn
              Container(
                padding: EdgeInsets.all(15),
                child: DottedBorder(
                  borderType: BorderType.Rect,
                  color: Colors.grey, // Border color
                  strokeWidth: 1.3, // Width of the dashed line
                  dashPattern: [5, 5], // Length of dash and gap
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLicenseBtnEnabled
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Submit your Driver's License", // Label text
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10), // Space before the label
                            const Icon(
                              Icons.photo_library_outlined,
                              size: 30,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Your ID Card photo should be original and not modified in any form.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10), // Space before the button
                            OutlinedButton(
                              onPressed: () {
                                selectFile(1);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(50, 50),
                                backgroundColor: Color.fromARGB(150, 75, 201, 104),
                                side: const BorderSide(
                                    color: Color.fromARGB(150, 75, 201, 104), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                "Select File",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Icon for file upload
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 204, 245, 215),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.upload_file,
                                      color: Color.fromARGB(150, 75, 201, 104),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Space between icon and file name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          licenseFileName, // Display file name
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Progress bar with percentage text
                                        ProgressBar(uploadTask: uploadLicenseTask),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //Container for Permit Btn
              Container(
                padding: EdgeInsets.all(15),
                child: DottedBorder(
                  borderType: BorderType.Rect,
                  color: Colors.grey, // Border color
                  strokeWidth: 1.3, // Width of the dashed line
                  dashPattern: [5, 5], // Length of dash and gap
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isPermitBtnEnabled
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Submit your Operating Permit", // Label text
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10), // Space before the label
                            const Icon(
                              Icons.photo_library_outlined,
                              size: 30,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Your photo should be clear and readable.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10), // Space before the button
                            OutlinedButton(
                              onPressed: () {
                                selectFile(2);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(50, 50),
                                backgroundColor: Color.fromARGB(150, 75, 201, 104),
                                side: const BorderSide(
                                    color: Color.fromARGB(150, 75, 201, 104), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                "Select File",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Icon for file upload
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 204, 245, 215),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.upload_file,
                                      color: Color.fromARGB(150, 75, 201, 104),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Space between icon and file name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          permitFileName, // Display file name
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Progress bar with percentage text
                                        ProgressBar(uploadTask: uploadPermitTask),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal:  20),
                child: OutlinedButton(
                  onPressed: () {
                    validateTrikeInfo();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Color.fromARGB(150, 75, 201, 104),
                    side: const BorderSide(
                        color: Color.fromARGB(150, 75, 201, 104), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
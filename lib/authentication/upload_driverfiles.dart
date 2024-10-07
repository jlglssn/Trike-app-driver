import 'dart:io';
import 'package:driver_application/authentication/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../methods/fetchUserData.dart';
import 'package:driver_application/authentication/upload_driverfiles.dart';

import '../widgets/progress_bar.dart';

class UploadDriverFilesScreen extends StatefulWidget {
  const UploadDriverFilesScreen({super.key});

  @override
  State<UploadDriverFilesScreen> createState() => _UploadDriverFilesScreenState();
}

class _UploadDriverFilesScreenState extends State<UploadDriverFilesScreen> {
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
          path = 'Driver-Files/$driverName/${driverName}_driversLicense.$fileExtension';
          licenseFileName = '${driverName}_driversLicense.$fileExtension';

          final ref = FirebaseStorage.instance.ref().child(path);

          setState(() {
            uploadLicenseTask = ref.putFile(file);
          });

          final snapshot = await uploadLicenseTask!.whenComplete(() {});

          final urlDownload = await snapshot.ref.getDownloadURL();
          print('Download Link: $urlDownload');

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
          'Driver-Files/$driverName/${driverName}_operatingPermit.$fileExtension';
          permitFileName = '${driverName}_operatingPermit.$fileExtension';

          final ref = FirebaseStorage.instance.ref().child(path);

          setState(() {
            uploadPermitTask = ref.putFile(file);
          });

          final snapshot = await uploadPermitTask!.whenComplete(() {});

          final urlDownload = await snapshot.ref.getDownloadURL();
          print('Download Link: $urlDownload');

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

  void submit(){
    if(isPicUploaded == true && isLicenseUploaded == true && isPermitUploaded == true){
      showUploadSuccessDialog(context);
    }
    else{
      _showErrorDialog("Please upload all the required images.");
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

  Future<void> _showSuccessDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Driver Files")),
      // Added an AppBar for better UX
      body: SingleChildScrollView( // Enable scrolling for the entire body
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column( // Change to Column to stack children vertically
            children: [
              const SizedBox(height: 16,),
              // Container for Pic Btn
              Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: isPicBtnEnabled
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "1x1 Picture", // Label text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: (){
                          selectFile(0);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color.fromARGB(150, 75, 201, 104), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Select Image File",
                          style: TextStyle(
                            color: Color.fromARGB(150, 75, 201, 104),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "1x1 Picture", // Label text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color.fromARGB(150, 75, 201, 104)),
                          borderRadius: BorderRadius.circular(15),
                        ),
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
                ),
              ),
              // Container for Driver's License Btn
              Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: isLicenseBtnEnabled
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Driver's License", // Label text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: (){
                          selectFile(1);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color.fromARGB(150, 75, 201, 104), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Select Image File",
                          style: TextStyle(
                            color: Color.fromARGB(150, 75, 201, 104),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Driver's License", // Label text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color.fromARGB(150, 75, 201, 104)),
                          borderRadius: BorderRadius.circular(15),
                        ),
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
                ),
              ),
              //Container for Permit Btn
              Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: isPermitBtnEnabled
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Operating Permit (Prangkisa)", // Label text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: (){
                          selectFile(2);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color.fromARGB(150, 75, 201, 104), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Select Image File",
                          style: TextStyle(
                            color: Color.fromARGB(150, 75, 201, 104),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Operating Permit (Prangkisa)", // Label text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color.fromARGB(150, 75, 201, 104)),
                          borderRadius: BorderRadius.circular(15),
                        ),
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
                ),
              ),
              SizedBox(height: 15,),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal:  100),
                child: ElevatedButton(
                  onPressed: (){
                    submit();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Color.fromARGB(150, 75, 201, 104),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Submit",
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
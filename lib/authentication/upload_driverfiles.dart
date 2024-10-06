import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../methods/fetchUserData.dart';

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

  XFile? pickedFile;
  UploadTask? uploadTask;

  String picFileName = "";
  String licenseFileName = "";
  String permitFileName = "";
  int index = 0;

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
        path = 'Driver-Files/$driverName/${driverName}_1x1Picture.$fileExtension';
        picFileName = '${driverName}_1x1Picture.$fileExtension';
        break;
      case 1: //License
        path = 'Driver-Files/$driverName/${driverName}_driversLicense.$fileExtension';
        licenseFileName = '${driverName}_driversLicense.$fileExtension';
        break;
      case 2: //Permit
        path = 'Driver-Files/$driverName/${driverName}_operatingPermit.$fileExtension';
        permitFileName = '${driverName}_operatingPermit.$fileExtension';
        break;
    }

    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    setState(() {
      uploadTask = null;
    });
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
                          ElevatedButton(
                            onPressed: (){
                              selectFile(0);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Color.fromARGB(150, 75, 201, 104),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
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
                                    buildProgress(),
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
                        ElevatedButton(
                          onPressed: (){
                            selectFile(1);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Color.fromARGB(150, 75, 201, 104),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
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
                                    buildProgress(),
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
                        ElevatedButton(
                          onPressed: (){
                            selectFile(2);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Color.fromARGB(150, 75, 201, 104),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
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
                                      buildProgress(),
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
            ],
          ),
        ),
      ),
    );
  }


  Widget buildProgress() =>
      StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final progress = data.bytesTransferred / data.totalBytes;

            return SizedBox(
              height: 13,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ClipRRect to create rounded corners for the progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    // Adjust the radius as needed
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Color.fromARGB(255, 204, 245, 215),
                      color: Color.fromARGB(150, 75, 201, 104),
                    ),
                  ),
                  // Align the text on the right side
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      // Align text to the right
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        // Add padding to the right
                        child: Text(
                          '${(100 * progress).round()}%',
                          // Display progress percentage
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox(
                height: 50); // Placeholder when no data is available
          }
        },
      );
}
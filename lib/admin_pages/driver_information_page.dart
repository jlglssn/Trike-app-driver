import 'package:driver_application/methods/fetchUserData.dart';
import 'package:driver_application/methods/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverInformationPage extends StatefulWidget {
  final String driverUid;

  const DriverInformationPage({Key? key, required this.driverUid}) : super(key: key);

  @override
  _DriverInformationPageState createState() => _DriverInformationPageState();
}

class _DriverInformationPageState extends State<DriverInformationPage> {
  // Stream for the driver's information
  Stream<DatabaseEvent> getDriverDataStream() {
    return FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(widget.driverUid)
        .onValue;  // Listen for changes in the driver data
  }

  Future<void> updateStatus(String driverUid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('drivers').child(driverUid);
    String userName = await fetchUserData.fetchUserName();
    String? token = await fetchUserData.getDriverToken(widget.driverUid);
    ref.update({
      'accountStatus': 'approved', // Update blockStatus to false
    }).then((_) {
      // Success message or additional actions
      print('Account status updated successfully.');
    }).catchError((error) {
      // Handle any errors
      print('Failed to update account status: $error');
    });
    PushNotificationService.sendNewDriverAccountStatusNotification(token!, true, context);
  }


  // Function to show dialog with full-size image
  void showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog on image tap
                },
                child: Image.network(
                  imageUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.6,
                  fit: BoxFit.contain, // Prevent cropping, maintain aspect ratio
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          "Driver Information",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: getDriverDataStream(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Check for data availability
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('No Data Available'));
          }

          // Extract driver data from the snapshot
          Map<dynamic, dynamic> driverData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Column(
                          children:[
                            CircleAvatar(
                              radius: 65.0,
                              backgroundImage: driverData['picUrl'] != null && driverData['picUrl'].isNotEmpty
                                  ? NetworkImage(driverData['picUrl']) // Load the image from the network
                                  : const AssetImage('assets/images/driver.png') as ImageProvider, // Fallback to a local image if URL is null or empty
                            ),
                            const SizedBox(height: 8),
                            Text('${driverData['name'] ?? 'N/A'}', style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                            )
                          ]
                      )
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.0), // Adjust padding to control the space around the icon
                        child: const Icon(
                          Icons.person,
                          size: 30, // Icon size
                          color: Colors.black, // Icon color
                        ),
                      ),
                      const SizedBox(width: 16.0), // Adds space between the avatar and the text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //const SizedBox(height: 2.0), // Adds space between the two text fields
                          Text('${driverData['name'] ?? 'N/A'}', style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.0), // Adjust padding to control the space around the icon

                        child: const Icon(
                          Icons.phone,
                          size: 30, // Icon size
                          color: Colors.black, // Icon color
                        ),
                      ),
                      const SizedBox(width: 16.0), // Adds space between the avatar and the text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //const SizedBox(height: 2.0), // Adds space between the two text fields
                          Text('${driverData['phone'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Container(
                        width: 40.0, // Width of the container (same size as the icon would have been)
                        height: 40.0, // Height of the container (same size as the icon would have been)
                        child: Image.asset(
                          'assets/images/PLATE_NUMBER.png', // Replace with the image path you want to use
                          fit: BoxFit.cover, // Ensures the image covers the container properly
                        ),
                      ),
                      const SizedBox(width: 16.0), // Adds space between the image and the text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plate Number',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${driverData['plateNumber'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Container(
                        width: 40.0, // Width of the container (same size as the icon would have been)
                        height: 40.0, // Height of the container (same size as the icon would have been)
                        child: Image.asset(
                          'assets/images/BODY_NUMBER.png', // Replace with the image path you want to use
                          fit: BoxFit.cover, // Ensures the image covers the container properly
                        ),
                      ),
                      const SizedBox(width: 16.0), // Adds space between the image and the text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Body Number',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${driverData['bodyNumber'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Image Files', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      if (driverData['picUrl'] != null) {
                        showFullImage(driverData['picUrl']); // Show the full image on tap
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Optional background color
                        borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                      ),
                      child: Row(
                        children: [
                          driverData['picUrl'] != null
                              ? const Icon(Icons.image, size: 40) // Use an icon or thumbnail
                              : const Text('No 1x1 Picture'),
                          const SizedBox(width: 16.0), // Adds space between the image and the text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '1x1 Picture',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${driverData['name'] + '_1x1Picture.png' ?? 'N/A'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      if (driverData['permitUrl'] != null) {
                        showFullImage(driverData['permitUrl']); // Show the full image on tap
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Optional background color
                        borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                      ),
                      child: Row(
                        children: [
                          driverData['permitUrl'] != null
                              ? const Icon(Icons.image, size: 40) // Use an icon or thumbnail
                              : const Text('No Operating Permit Picture'),
                          const SizedBox(width: 16.0), // Adds space between the image and the text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Operating Permit',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${driverData['name'] + '_op-permit.png' ?? 'N/A'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      if (driverData['licenseUrl'] != null) {
                        showFullImage(driverData['licenseUrl']); // Show the full image on tap
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Optional background color
                        borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                      ),
                      child: Row(
                        children: [
                          driverData['licenseUrl'] != null
                              ? const Icon(Icons.image, size: 40) // Use an icon or thumbnail
                              : const Text('No License Picture'),
                          const SizedBox(width: 16.0), // Adds space between the image and the text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Driver\'s License',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${driverData['name'] + '_d-license.png' ?? 'N/A'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

              ),
            ),
          );
        },
      ),
    );
  }
}
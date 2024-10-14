import 'package:driver_application/admin_pages/driver_information_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../authentication/login_screen.dart';
import '../widgets/error_dialog.dart'; // Assuming you have this widget

class ApprovedDriversPage extends StatefulWidget {
  const ApprovedDriversPage({Key? key}) : super(key: key);

  @override
  _ApprovedDriversPageState createState() => _ApprovedDriversPageState();
}

class _ApprovedDriversPageState extends State<ApprovedDriversPage> {
  List<Map<String, dynamic>> approvedDrivers = [];

  @override
  void initState() {
    super.initState();
    _fetchApprovedDrivers(); // Fetch the approved drivers on page load
  }

  Future<void> _fetchApprovedDrivers() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instance.ref().child('drivers');

      DataSnapshot snapshot = await database.get();

      if (snapshot.value != null) {
        Map<dynamic, dynamic> driversMap = snapshot.value as Map<dynamic, dynamic>;

        // Clear the list before populating it
        approvedDrivers.clear();

        // Iterate through the drivers map and find those with accountStatus = approved
        driversMap.forEach((key, value) {
          if (value['accountStatus'] == 'approved') {
            approvedDrivers.add({
              'name': value['name'], // Assuming the name field exists
              'phoneNumber': value['phone'], // Assuming the phone number field exists
              'accountStatus': value['accountStatus'], // Assuming the account status field exists
              'id': key, // Use the key as the UID
            });
          }
        });

        // Refresh the UI
        setState(() {});
      }
    } catch (error) {
      // Show error dialog if there's an issue with fetching data
      showErrorDialog(context, 'Error fetching approved drivers: $error');
    }
  }

  void _onDriverTap(String driverName, String uid) {
    // Handle the tap on the driver, e.g., show details

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DriverInformationPage(driverUid: uid))
    );
    // Navigate to the driver details page if you have one
    // Navigator.push(context, MaterialPageRoute(builder: (context) => DriverDetailsPage(driverName: driverName, uid: uid)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes default back button
        title: const Text(
          "Approved Drivers",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      backgroundColor: Colors.white,
      body: approvedDrivers.isEmpty
          ? const Center(child: Text('No approved drivers found.'))
          : ListView.builder(
        itemCount: approvedDrivers.length,
        itemBuilder: (context, index) {
          final driver = approvedDrivers[index];
          return GestureDetector(
            onTap: () => _onDriverTap(driver['name']!, driver['id']!), // Handle tap
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.black, // Change this to the desired border color
                  width: 1.0, // Change this to the desired border width
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    driver['name'],
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phone: ${driver['phoneNumber']}',
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  Text(
                    'Status: ${driver['accountStatus']}',
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
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
import 'package:driver_application/pages/validate_driver.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../authentication/login_screen.dart';
import '../widgets/error_dialog.dart';
import 'driver_information_page.dart'; // Assuming you have this widget

class PendingDriversPage extends StatefulWidget {
  const PendingDriversPage({Key? key}) : super(key: key);

  @override
  _PendingDriversPageState createState() => _PendingDriversPageState();
}

class _PendingDriversPageState extends State<PendingDriversPage> {
  List<Map<String, String>> pendingDrivers = []; // Change to store name and uid

  @override
  void initState() {
    super.initState();
    _fetchPendingDrivers(); // Fetch the pending drivers on page load
  }

  Future<void> _fetchPendingDrivers() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instance.ref().child('drivers');

      DataSnapshot snapshot = await database.get();

      if (snapshot.value != null) {
        Map<dynamic, dynamic> driversMap = snapshot.value as Map<dynamic, dynamic>;

        // Clear the list before populating it
        pendingDrivers.clear();

        // Iterate through the drivers map and find those with accountStatus = approved
        driversMap.forEach((key, value) {
          if (value['accountStatus'] == 'pending') {
            pendingDrivers.add({
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
        MaterialPageRoute(builder: (context) => ValidateDriverPage(driverUid: uid))
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
            Navigator.pop(context);  // Navigate back to the previous page
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes default back button
        title: const Text(
          "Pending Drivers",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      backgroundColor: Colors.white,
      body: pendingDrivers.isEmpty
          ? const Center(child: Text('No pending drivers found.'))
          : ListView.builder(
        itemCount: pendingDrivers.length,
        itemBuilder: (context, index) {
          final driver = pendingDrivers[index];
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
                    driver['name']!,
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
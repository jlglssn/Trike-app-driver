import 'package:driver_application/widgets/error_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'driver_information_page.dart';

class DriversListPage extends StatefulWidget {
  final VoidCallback? onRefresh; // Callback for refreshing data

  const DriversListPage({Key? key, this.onRefresh}) : super(key: key);

  @override
  _DriversListPageState createState() => _DriversListPageState();
}

class _DriversListPageState extends State<DriversListPage> {
  List<Map<dynamic, dynamic>> driversList = [];

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instance.ref().child('drivers');
      DataSnapshot snapshot = await database.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> driversMap = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          driversList = driversMap.entries
              .map((entry) => {'key': entry.key, ...entry.value})
              .toList();
        });
      } else {
        showErrorDialog('No driver data found.');
      }
    } catch (error) {
      showErrorDialog('Error fetching driver data: $error');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _onDriverTap(String driverName, String uid) {
    // Handle the tap on the driver, e.g., show details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverInformationPage(driverUid: uid),
      ),
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
          "Drivers List",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchDrivers(); // Fetch drivers when the refresh button is clicked
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: driversList.isEmpty
          ? const Center(child: Text('No drivers found.'))
          : ListView.builder(
        itemCount: driversList.length,
        itemBuilder: (context, index) {
          final driver = driversList[index];
          return GestureDetector(
            onTap: () {
              _onDriverTap(driver['name'], driver['id']);
            },
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
                    driver['name'] ?? 'Unknown Driver',
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${driver['accountStatus'] ?? 'N/A'}',
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
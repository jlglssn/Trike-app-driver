import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../authentication/login_screen.dart';
import '../widgets/error_dialog.dart'; // Assuming you have this widget

class ManageFarePage extends StatefulWidget {
  const ManageFarePage({Key? key}) : super(key: key);

  @override
  _ManageFarePageState createState() => _ManageFarePageState();
}

class _ManageFarePageState extends State<ManageFarePage> {
  final TextEditingController _minFareController = TextEditingController();
  final TextEditingController _additionalFareController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  bool _isSaving = false; // To show progress indicator during saving

  @override
  void initState() {
    super.initState();
    _fetchFareSettings(); // Fetch fare settings when the page loads
  }

  @override
  void dispose() {
    _minFareController.dispose();
    _additionalFareController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _fetchFareSettings() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instance.ref().child('fareSettings');
      DataSnapshot snapshot = await database.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> fareData = snapshot.value as Map<dynamic, dynamic>;

        // Update the controllers with fetched values
        _minFareController.text = fareData['minFare']?.toString() ?? '';
        _additionalFareController.text = fareData['additionalFare']?.toString() ?? '';
        _distanceController.text = fareData['distance']?.toString() ?? '';
      } else {
        print('FareSettings data does not exist in the database');
        // Optionally, show a dialog if no fare settings are found
        showErrorDialog(context, 'No fare settings found in the database.');
      }
    } catch (error) {
      print('Error fetching fare settings: $error');
      showErrorDialog(context, 'Error fetching fare settings: $error');
    }
  }

  Future<void> _saveFareSettings() async {
    if (_minFareController.text.isEmpty ||
        _additionalFareController.text.isEmpty ||
        _distanceController.text.isEmpty) {
      showErrorDialog(context, 'All fields must be filled.');
      return;
    }

    try {
      setState(() {
        _isSaving = true; // Show loading indicator
      });

      final DatabaseReference database = FirebaseDatabase.instance.ref().child('fareSettings');

      // Save the values to Firebase
      await database.set({
        'minFare': double.parse(_minFareController.text),
        'additionalFare': double.parse(_additionalFareController.text),
        'distance': double.parse(_distanceController.text),
      });

      setState(() {
        _isSaving = false; // Hide loading indicator
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fare settings saved successfully!')),
      );
    } catch (error) {
      setState(() {
        _isSaving = false; // Hide loading indicator
      });

      // Show error dialog if there's an issue with saving data
      showErrorDialog(context, 'Error saving fare settings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Fare'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            TextFormField(
              controller: _minFareController,
              keyboardType: const TextInputType.numberWithOptions(signed: false),
              decoration: InputDecoration(
                label: const Text("Minimum Fare"),
                prefixIcon: const Icon(
                    Icons.attach_money_outlined,
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
            const SizedBox(height: 24),
            TextFormField(
              controller: _additionalFareController,
              keyboardType: const TextInputType.numberWithOptions(signed: false),
              decoration: InputDecoration(
                label: const Text("Aditional Fare"),
                prefixIcon: const Icon(
                    Icons.money,
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
            const SizedBox(height: 24),
            TextFormField(
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(signed: false),
              decoration: InputDecoration(
                label: const Text("Distance (km)"),
                prefixIcon: const Icon(
                    Icons.location_on_outlined,
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
            const SizedBox(height: 32),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : Center(
              child: OutlinedButton(
                onPressed: () {
                  _saveFareSettings();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Color.fromARGB(255, 75, 201, 104),
                  side: const BorderSide(
                      color: Color.fromARGB(150, 75, 201, 104), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

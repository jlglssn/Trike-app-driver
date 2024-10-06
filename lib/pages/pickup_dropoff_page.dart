import 'package:flutter/material.dart';

class PickupDropoffPage extends StatelessWidget {
  final TextEditingController _pickUpPointController = TextEditingController();
  final TextEditingController _dropOffPointController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Pickup and Dropoff Points
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  /// Pickup Point
                  Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _pickUpPointController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Pickup Point",
                            prefixIcon: const Icon(Icons.pin),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color.fromARGB(255, 204, 245, 215), width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color.fromARGB(255, 204, 245, 215), width: 2.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  /// Dropoff Point
                  Row(
                    children: [
                      const Icon(Icons.place, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _dropOffPointController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Drop-off Point",
                            prefixIcon: const Icon(Icons.pin_drop),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color.fromARGB(255, 204, 245, 215), width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Color.fromARGB(255, 204, 245, 215), width: 2.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          // Action for Add (+) button
                        },
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Saved Places Section
            GestureDetector(
              onTap: () {
                // Navigate to saved places
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bookmark, color: Colors.green),
                      SizedBox(width: 10),
                      Text(
                        'Saved Places',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// List of Saved Places
            Expanded(
              child: ListView(
                children: [
                  buildSavedPlaceTile('Home', '521 Thornridge Cir. Syracause, C...'),
                  buildSavedPlaceTile('Home', '626 Ryan Park dge Cir. Syracause...'),
                  buildSavedPlaceTile('Work', '339 North Garden Level'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable method to build each saved place
  Widget buildSavedPlaceTile(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.home, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
    );
  }
}
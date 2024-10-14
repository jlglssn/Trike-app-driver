import 'package:driver_application/admin_pages/manage_fare_page.dart';
import 'package:driver_application/admin_pages/pending_drivers_page.dart';
import 'package:driver_application/widgets/error_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'approved_drivers_page.dart';
import 'drivers_list_page.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  Future<Map<String, dynamic>> _fetchDriverData() async {
    int totalDrivers = 0;
    int totalPendingDrivers = 0;
    int totalApprovedDrivers = 0;

    try {
      final DatabaseReference database = FirebaseDatabase.instance.ref().child('drivers');
      DataSnapshot snapshot = await database.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> driversMap = snapshot.value as Map<dynamic, dynamic>;

        driversMap.forEach((key, value) {
          totalDrivers++; // Count all drivers
          if (value['accountStatus'] != null) {
            if (value['accountStatus'] == 'pending') {
              totalPendingDrivers++;
            } else if (value['accountStatus'] == 'approved') {
              totalApprovedDrivers++;
            }
          } else {
            print('Missing accountStatus for driver $key');
          }
        });
      }
    } catch (error) {
      print('Error fetching driver data: $error');
      // Return a default value to prevent infinite loading
      return {
        'totalDrivers': totalDrivers,
        'totalPendingDrivers': totalPendingDrivers,
        'totalApprovedDrivers': totalApprovedDrivers,
      };
    }

    return {
      'totalDrivers': totalDrivers,
      'totalPendingDrivers': totalPendingDrivers,
      'totalApprovedDrivers': totalApprovedDrivers,
    };
  }

  Future<double> _fetchMinFare() async {
    double minFare = 0.0; // Default value

    try {
      final DatabaseReference database = FirebaseDatabase.instance.ref().child('fareSettings');
      DataSnapshot snapshot = await database.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> fareData = snapshot.value as Map<dynamic, dynamic>;
        if (fareData.containsKey('minFare')) {
          minFare = fareData['minFare']?.toDouble() ?? 0.0;
        }
      }
    } catch (error) {
      print('Error fetching minimum fare: $error');
      // Returning default value to avoid infinite loading
    }
    return minFare; // Return the fetched fare or the default
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Admin Panel",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _fetchDriverData(),
            builder: (context, driverSnapshot) {
              if (driverSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (driverSnapshot.hasError) {
                return Center(child: Text('Error fetching driver data: ${driverSnapshot.error}'));
              }

              // Extract driver data
              int totalDrivers = driverSnapshot.data?['totalDrivers'] ?? 0;
              int totalPendingDrivers = driverSnapshot.data?['totalPendingDrivers'] ?? 0;
              int totalApprovedDrivers = driverSnapshot.data?['totalApprovedDrivers'] ?? 0;

              return FutureBuilder<double>(
                future: _fetchMinFare(),
                builder: (context, fareSnapshot) {
                  if (fareSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (fareSnapshot.hasError) {
                    return Center(child: Text('Error fetching fare data: ${fareSnapshot.error}'));
                  }

                  double minFare = fareSnapshot.data ?? 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 2.8 / 2,
                          padding: const EdgeInsets.all(15.0),
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                          children: [
                            _buildStatCard('Total Drivers', totalDrivers.toString(), Colors.green, () {
                              if (totalDrivers == 0) {
                                showNoDriversDialog(context, 'No Drivers Registered', 'There are currently no drivers registered yet.');
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DriversListPage(),
                                  ),
                                ).then((_) {
                                  setState(() {});
                                });
                              }
                            }),
                            _buildStatCard('Pending Drivers', totalPendingDrivers.toString(), Colors.red, () {
                              if (totalPendingDrivers == 0) {
                                showNoDriversDialog(context, 'No Pending Drivers', 'There are currently no pending drivers yet.');
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PendingDriversPage(),
                                  ),
                                ).then((_) {
                                  setState(() {});
                                });
                              }
                            }),
                            _buildStatCard('Approved Drivers', totalApprovedDrivers.toString(), Colors.blue, () {
                              if (totalApprovedDrivers == 0) {
                                showNoDriversDialog(context, 'No Approved Drivers', 'There are currently no approved drivers yet.');
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ApprovedDriversPage(),
                                  ),
                                ).then((_) {
                                  setState(() {});
                                });
                              }
                            }),
                            _buildStatCard('Minimum Fare', 'PHP $minFare', Colors.blue, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ManageFarePage()),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showNoDriversDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
}

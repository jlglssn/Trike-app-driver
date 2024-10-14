import 'package:driver_application/admin_pages/admin_panel_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../methods/fetchUserData.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/trips_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool isAdmin = false; // Store the admin status

  // List of pages to switch between
  final List<Widget> _pages = [
    const HomePage(),
    const TripsPage(),
    const ProfilePage(),
    const AdminPanelPage(),
  ];

  // Function to fetch isAdmin status once when the widget is initialized
  @override
  void initState() {
    super.initState();
    _fetchIsAdmin();
  }

  Future<void> _fetchIsAdmin() async {
    try {
      bool adminStatus = await fetchUserData.fetchIsAdmin();
      setState(() {
        isAdmin = adminStatus;
        // Add the Admin Panel page to the list if the user is an admin
        if (isAdmin && !_pages.contains(const AdminPanelPage())) {
          _pages.add(const AdminPanelPage());
        }
        // Ensure the _selectedIndex is within valid range
        if (_selectedIndex >= _pages.length) {
          _selectedIndex = 0; // Reset to the first index if it exceeds the new list length
        }
      });
    } catch (e) {
      print("Error fetching admin status: $e");
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Display the current page based on index
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x18000018), // Shadow color
              blurRadius: 8.0, // Blur radius
              spreadRadius: 3.0, // Spread radius
              offset: Offset(0, 4), // Offset of the shadow
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              label: 'Trips',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profile',
            ),
            if (isAdmin) // Conditionally add the admin item
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings_rounded),
                label: 'Admin',
              ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          enableFeedback: false,
        ),
      ),
    );
  }
}
